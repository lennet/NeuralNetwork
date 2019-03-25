//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

@testable import NeuralNetwork
import XCTest

class NetworkModelTests: XCTestCase {
    func testModelForLayerWithWeights() {
        let layer = Layer(nodesCount: 3, activationFunction: .sigmoid)
        layer.weights = Mat(values: [[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        layer.biases = Mat(values: [[1], [2], [3]])
        let output = layer.modelRepresentation()
        let expectedOuput = LayerModel(neurons: [NeuronModel(weigths: [1, 2, 3], bias: 1), NeuronModel(weigths: [4, 5, 6], bias: 2), NeuronModel(weigths: [7, 8, 9], bias: 3)], activationFunction: "sigmoid")
        XCTAssertEqual(output, expectedOuput)
    }

    func testInitLayerWithModel() {
        let model = LayerModel(neurons: [NeuronModel(weigths: [1, 2, 3], bias: 1), NeuronModel(weigths: [4, 5, 6], bias: 2), NeuronModel(weigths: [7, 8, 9], bias: 3)], activationFunction: "tanh")
        let layer = Layer(model: model)
        let ouput = layer.modelRepresentation()
        XCTAssertEqual(model, ouput)
    }

    func testInitNetworkFromFile() {
        let url = Bundle(for: NetworkModelTests.self).url(forResource: "testModel", withExtension: "json")!
        let model = try! NetworkModel.load(from: url)
        let network = NeuralNetwork(model: model)
        let output = network.model()

        XCTAssertEqual(model, output)
    }

    func testInitNetworkAndTestFromFile() {
        let url = Bundle(for: NetworkModelTests.self).url(forResource: "testModel", withExtension: "json")!
        let model = try! NetworkModel.load(from: url)
        let network = NeuralNetwork(model: model)
        let dataSet = ArtificalDataSets.circular(numberOfPointsPerClass: 250).split(ratio: 0.1).1
        let report = network.test(dataSet: dataSet)

        XCTAssertGreaterThan(report.classifications.accuracy, 0.90)
    }
}
