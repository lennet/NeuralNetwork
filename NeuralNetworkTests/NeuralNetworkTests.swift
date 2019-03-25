//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import NeuralNetwork
import XCTest

class NeuralNetworkTests: XCTestCase {
    func testTrainCircularDataSet() {
        let network = NeuralNetwork(learningRate: 0.03, epochs: 1700)
        network.add(layer: Layer(nodesCount: 2))
        network.add(layer: Layer(nodesCount: 4, activationFunction: .relu))
        network.add(layer: Layer(nodesCount: 1, activationFunction: .sigmoid))

        let data = ArtificalDataSets.circular(numberOfPointsPerClass: 200)

        let input = data.input.transposed()
        let output = data.output.transposed()

        network.train(input: input, expectedOutput: output)

        let report = network.test(dataSet: data)
        XCTAssertGreaterThanOrEqual(report.classifications.accuracy, 0.95)
    }

    func testTrainIrisDataSet() {
        let exp = expectation(description: "Wait for training")
        let irisDataSet = IrisDataSet()
        let network = NeuralNetwork(learningRate: 0.03, epochs: 5000)
        network.add(layer: Layer(nodesCount: 4))
        network.add(layer: Layer(nodesCount: 5, initialWeightsRange: 0 ..< 0.01, activationFunction: .tanh))
        network.add(layer: Layer(nodesCount: 3, activationFunction: .linear))

        let (train, test) = irisDataSet.split(ratio: 0.1)
        network.trainAndTest(trainData: train, testData: test) { report in
            XCTAssertGreaterThanOrEqual(report.classifications.accuracy, 0.90)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testTrainXORDataSet() {
        let exp = expectation(description: "Wait for training")
        let network = NeuralNetwork(learningRate: 0.3, epochs: 5000)
        network.add(layer: Layer(nodesCount: 2))
        network.add(layer: Layer(nodesCount: 2, activationFunction: .sigmoid))
        network.add(layer: Layer(nodesCount: 2, activationFunction: .linear))

        let data = XORDataSet()

        network.trainAndTest(trainData: data, testData: data) { report in
            XCTAssertGreaterThanOrEqual(report.classifications.accuracy, 0.90)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

    func testPerformanceCircularDataSet100Epochs() {
        let network = NeuralNetwork(learningRate: 0.03, epochs: 100)
        network.add(layer: Layer(nodesCount: 2))
        network.add(layer: Layer(nodesCount: 4, activationFunction: .relu))
        network.add(layer: Layer(nodesCount: 2, activationFunction: .sigmoid))

        let data = ArtificalDataSets.circular(numberOfPointsPerClass: 200)

        let input = data.input.transposed()
        let output = data.output.transposed()

        measure {
            network.train(input: input, expectedOutput: output)
        }
    }
}
