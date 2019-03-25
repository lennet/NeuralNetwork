//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

// This ViewController is a helper to test a Network outside of Swift Playgrounds
class ViewController: UIViewController {
    lazy var networkVisualisation: NetworkVisualisationViewController = {
        let controller = NetworkVisualisationViewController()
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChild(controller)
        view.addSubview(controller.view)
        return controller
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        performCustom()
//        performIris()
//        performFourCorners()
//        performXOR()
    }

    private func performXOR() {
        let network = NeuralNetwork(learningRate: 0.3, epochs: 5000)
        network.add(layer: Layer(nodesCount: 2))
        network.add(layer: Layer(nodesCount: 2, activationFunction: .sigmoid))
        network.add(layer: Layer(nodesCount: 2, activationFunction: .linear))

        network.debugOutputHandler = networkVisualisation

        let data = DataSet(values: [[0, 0]: 0,
                                    [0, 1]: 1,
                                    [1, 0]: 1,
                                    [1, 1]: 0])

        network.trainAndTest(trainData: data, testData: data) { report in
            print(report)
        }
    }

    private func performFourCorners() {
        let network = NeuralNetwork(learningRate: 0.03, epochs: 5000)
        network.add(layer: Layer(nodesCount: 2))
        network.add(layer: Layer(nodesCount: 5, activationFunction: .tanh))
        network.add(layer: Layer(nodesCount: 4))

        network.debugOutputHandler = networkVisualisation

        let data = ArtificalDataSets.fourCorners().normalized()
        networkVisualisation.decisionPlotView.plotPoints(dataSet: data)
        let (train, test) = data.split(ratio: 0.1)
        network.trainAndTest(trainData: train, testData: test) { report in
            print(report)
        }
    }

    private func performCustom() {
        let network = NeuralNetwork(learningRate: 0.03, epochs: 5000)
        network.add(layer: Layer(nodesCount: 2))
        network.add(layer: Layer(nodesCount: 4, activationFunction: .tanh))
        network.add(layer: Layer(nodesCount: 2, activationFunction: .linear))

        network.debugOutputHandler = networkVisualisation

        let data = ArtificalDataSets.circular()
        let (train, test) = data.split(ratio: 0.1)
        network.trainAndTest(trainData: train, testData: test) { report in
            print(report)
        }
    }

    private func performIris() {
        let irisDataSet = IrisDataSet()
        let network = NeuralNetwork(learningRate: 0.03, epochs: 2000)
        network.add(layer: Layer(nodesCount: 4))
        network.add(layer: Layer(nodesCount: 5, initialWeightsRange: 0 ..< 0.01, activationFunction: .tanh))
        network.add(layer: Layer(nodesCount: 4, initialWeightsRange: 0 ..< 0.01, activationFunction: .tanh))
        network.add(layer: Layer(nodesCount: 3, activationFunction: .linear))

        network.debugOutputHandler = networkVisualisation

        let (train, test) = irisDataSet.split(ratio: 0.1)
        network.trainAndTest(trainData: train, testData: test) { report in
            print(report)
        }
    }
}
