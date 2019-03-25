//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public class Layer {
    private(set)
    var nodes: UInt
    var weights: Mat?
    var biases: Mat?

    private var output: Mat?
    private(set)
    var activatedOutput: Mat?

    let activationFunction: ActivationFunction
    private let initialWeightsRange: Range<Double>

    var previous: Layer? {
        didSet {
            initWeightsAndBiasIfNeeded()
        }
    }

    var next: Layer?

    public init(nodesCount: UInt, initialWeightsRange: Range<Double> = 0 ..< 1, activationFunction: ActivationFunction = .linear) {
        nodes = nodesCount
        self.activationFunction = activationFunction
        self.initialWeightsRange = initialWeightsRange
    }

    convenience init(model: LayerModel) {
        self.init(nodesCount: UInt(model.neurons.count), activationFunction: .activationFunction(for: model.activationFunction!))
        let weightsValue = model.neurons.compactMap { $0.weigths }
        if !weightsValue.isEmpty {
            weights = Mat(values: weightsValue)
        }
        let biasesModel = model.neurons.compactMap { $0.bias }
        if !biasesModel.isEmpty {
            biases = Mat(shape: (nodes, 1), values: biasesModel)
        }
    }

    public func modelRepresentation() -> LayerModel {
        let weights = self.weights?.values ?? []
        let biases = self.biases?.values ?? []
        let numberOfNodes = Int(nodes)
        let numberOfWeightsPerNode = weights.count / numberOfNodes
        let nodesRepresentation: [NeuronModel] = (0 ..< numberOfNodes).map { nodeIndex in
            let startIndex = nodeIndex * numberOfWeightsPerNode
            let bias = biases.isEmpty ? nil : biases[nodeIndex]
            let weightRange = startIndex ..< startIndex + numberOfWeightsPerNode
            let neuronWeights = weightRange.isEmpty ? nil : Array(weights[weightRange])
            return NeuronModel(weigths: neuronWeights, bias:
                bias)
        }
        return LayerModel(neurons: nodesRepresentation, activationFunction: activationFunction.name)
    }

    func process(input: Mat) -> Mat {
        if let weights = weights,
            let biases = biases {
            output = weights.dot(input) + biases
            activatedOutput = activationFunction.function(output!)
        } else {
            activatedOutput = input
        }
        return activatedOutput!
    }

    func updateForOutputLayer(error: Mat, m: Double, learningRate: Double) {
        update(error: error, m: m, learningRate: learningRate)
    }

    func updateForHiddenLayer(m: Double, learningRate: Double, nextError: Mat) -> Mat {
        let error = next!.weights!.transposed().dot(nextError) * activationFunction.functionDerivative(output!)
        update(error: error, m: m, learningRate: learningRate)
        return error
    }

    private func update(error: Mat, m: Double, learningRate: Double) {
        let factor = (1.0 / m)
        let dw = factor * error.dot(previous!.activatedOutput!.transposed())
        let db = factor * error.sumRows()

        weights! -= learningRate * dw
        biases! -= learningRate * db
    }

    private func initWeightsAndBiasIfNeeded() {
        guard let previous = previous else { return }
        if weights == nil {
            let randomWeights = (0 ..< nodes * previous.nodes).map { _ in Double.random(in: initialWeightsRange) }
            weights = Mat(shape: (nodes, previous.nodes), values: randomWeights)
        }
        if biases == nil {
            biases = Mat(shape: (nodes, 1), values: [Double](repeating: 0, count: Int(nodes)))
        }
    }
}
