//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public protocol NeuralNetworkDebugOutputHandler: class {
    func didFinishedIteration(epochReport: EpochReport, networkRepresentation: NetworkModel)
    func startedTraining(with dataSet: DataSetProtocol)
    func didFinishTraining()
    var debugOutputFrequency: Int { get }
}

public class NeuralNetwork {
    // TODO: batch size support
    public let learningRate: Double
    public let epochs: Int
    public var debugOutputHandler: NeuralNetworkDebugOutputHandler?
    public var errorFunction: ErrorFunction = .squared
    private(set) var layers: [Layer] = []

    public init(learningRate: Double, epochs: Int) {
        self.learningRate = learningRate
        self.epochs = epochs
    }

    /// Restores a Network from a model
    ///
    /// - Parameters:
    ///   - model: the model contains information about the layer, activation functions, weights and other information that are needed to create the Network
    ///   - learningRate: The learning rate determines how quickly the network changes the weights based on the loss
    ///   - epochs: The number of iterations that are used for pass the training data through the network
    public convenience init(model: NetworkModel, learningRate: Double = 0, epochs: Int = 0) {
        self.init(learningRate: learningRate, epochs: epochs)
        model.layer
            .map(Layer.init)
            .forEach(add)
    }

    deinit {
        for layer in layers {
            layer.next = nil
            layer.previous = nil
        }
    }

    /// Adds  a layer to the network
    ///
    /// - Parameter layer
    public func add(layer: Layer) {
        layer.previous = layers.last
        layers.last?.next = layer
        layers.append(layer)
    }

    /// Predicts a value for a given input
    ///
    /// - Parameter input
    /// - Returns: The output of the network after forwarding the input through the layers
    public func predict(input: Mat) -> Mat {
        return layers.reduce(input) { currentInput, layer in
            layer.process(input: currentInput)
        }
    }

    /// Performs asynchronously a full training of the Network for a given input and the expected output.
    /// Training means passing the input through the network and back propagate the the error to update the weights and biases for the layers
    ///
    /// - Parameters:
    ///   - input
    ///   - expectedOutput
    ///   - completion: The completion closure gets called after the training has been finished
    public func train(input: Mat, expectedOutput: Mat, completion: (() -> Void)? = nil) {
        guard layers[0].nodes == input.shape.rows else {
            fatalError("The number of input nodes doesnt match the number of input parameters. The number of nodes must be \(input.shape.rows)")
        }
        guard layers.last!.nodes == expectedOutput.shape.rows else {
            fatalError("The number of output nodes doesnt match the number of possible classes. The number of nodes must be \(expectedOutput.shape.rows)")
        }

        DispatchQueue.global().async {
            (0 ... self.epochs).forEach { epoch in
                let output = self.predict(input: input)
                self.backpropagate(expectedOutput: expectedOutput)
                if let debugOutputFrequency = self.debugOutputHandler?.debugOutputFrequency,
                    epoch % debugOutputFrequency == 0 {
                    DispatchQueue.main.sync {
                        self.notifyDebugDelegateIfNeeded(epoch: epoch, output: output, expectedOutput: expectedOutput)
                    }
                }
            }
            DispatchQueue.main.async {
                self.debugOutputHandler?.didFinishTraining()
                completion?()
            }
        }
    }

    /// Performs synchronously a full training of the Network for a given input and the expected output.
    /// Training means passing the input through the network and back propagate the the error to update the weights and biases for the layers
    ///
    /// - Parameters:
    ///   - input
    ///   - expectedOutput
    public func train(input: Mat, expectedOutput: Mat) {
        (0 ... epochs).forEach { _ in
            _ = self.predict(input: input)
            backpropagate(expectedOutput: expectedOutput)
        }
    }

    /// Performs asynchronously a full training of the Network with a dataset.
    /// Training means passing the input through the network and back propagate the the error to update the weights and biases for the layers
    ///
    /// - Parameters:
    ///   - input
    ///   - expectedOutput
    ///   - completion: The completion closure gets called after the training has been finished
    public func train(dataSet: DataSetProtocol, completion: (() -> Void)?) {
        let input = dataSet.input.transposed()
        let output = dataSet.output.transposed()

        train(input: input, expectedOutput: output, completion: completion)
        debugOutputHandler?.startedTraining(with: dataSet)
    }

    /// Tests the correctness of a Networkwith with a given input and the expected output.
    ///
    /// - Parameters:
    ///   - input
    ///   - expectedOutput
    /// - Returns: The TestReport contains the classification results
    public func test(input: Mat, expectedOutput: Mat) -> TestReport {
        let prediction = predict(input: input)
        let classifications = classificationReports(for: prediction, expectedOutput: expectedOutput)
        return TestReport(classifications: classifications)
    }

    /// Tests the correctness of a Networkwith with a DataSet.
    ///
    /// - Parameters:
    ///   - input
    ///   - expectedOutput
    /// - Returns: The TestReport contains the classification results
    public func test(dataSet: DataSetProtocol) -> TestReport {
        let input = dataSet.input.transposed()
        let output = dataSet.output.transposed()

        return test(input: input, expectedOutput: output)
    }

    /// Performs asynchronously a training and testing  of of the Network with a dataset.
    ///
    /// - Parameters:
    ///   - input
    ///   - expectedOutput
    ///   - completion: The completion closure gets called after the training and testing has been finished
    public func trainAndTest(trainData: DataSetProtocol, testData: DataSetProtocol, completion: ((TestReport) -> Void)?) {
        train(dataSet: trainData) {
            completion?(self.test(dataSet: testData))
        }
    }

    ///
    ///
    /// - Returns: A model representation of the network. The model can be used to save the model to disk and recreate the Network. It can also be used to inspect internal parameters such as weights and biases of the layer
    public func model() -> NetworkModel {
        let layerRepresentation = layers.map { $0.modelRepresentation() }
        return NetworkModel(layer: layerRepresentation)
    }

    private func backpropagate(expectedOutput: Mat) {
        let reversedLayers = layers.reversed().dropLast()
        guard let outputLayer = reversedLayers.first else {
            fatalError()
        }
        let error = errorFunction.functionDerivative(outputLayer.activatedOutput!, expectedOutput)
        let outputClassesCount: Double = Double(expectedOutput.shape.cols)
        outputLayer.updateForOutputLayer(error: error, m: outputClassesCount, learningRate: learningRate)
        _ = reversedLayers.dropFirst().reduce(error) { nextError, layer in
            layer.updateForHiddenLayer(m: outputClassesCount, learningRate: learningRate, nextError: nextError)
        }
    }

    private func notifyDebugDelegateIfNeeded(epoch: Int, output: Mat, expectedOutput: Mat) {
        guard let debugOutputHandler = debugOutputHandler else {
            return
        }
        let loss = errorFunction.function(output, expectedOutput).sum() / Double(output.values.count)
        let report = EpochReport(epochIndex: epoch, classifications: classificationReports(for: output, expectedOutput: expectedOutput), loss: loss)
        debugOutputHandler.didFinishedIteration(epochReport: report, networkRepresentation: model())
    }

    private func classificationReports(for output: Mat, expectedOutput: Mat, discrete: Bool = true) -> [ClassificationReport] {
        return zip(output.transposed().values2D, expectedOutput.transposed().values2D)
            .map { arg in
                let (predictedValue, realValue) = arg
                let prediction: [Double]
                if discrete {
                    let maxValue = predictedValue.max() ?? 0
                    prediction = predictedValue.map { value in
                        value == maxValue ? 1.0 : 0.0
                    }
                } else {
                    prediction = predictedValue
                }
                return ClassificationReport(prediction: prediction, real: realValue)
            }
    }
}
