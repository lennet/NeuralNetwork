/*:
 # Playground

 You've learned about some fundamentals about working with Neural Networks. In this page, you can experiment on our own without restrictions

 As a starting point here is a real world example for the classification of iris flowers using the input features petal length, petal width, sepal length and sepal width.
 - Note:
 The decision boundary visualisation is only available for networks that work with 2 input features
 */
//#-hidden-code
import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true
//#-code-completion(identifier, hide, DecisionBoundaryView, Constants, DecisionBoundaryPlotView, NetworkVisualisationViewController, PlaygroundNetworkVisualisationViewController, PlaygroundLiveViewController, PlaygroundLiveViewSessionManager, PlaygroundStore, PlaygroundPageSessionManager, PlaygroundRemoteNeuralNetworkDebugOutputHandler)
//#-code-completion(identifier, hide, outputView)

//#-end-hidden-code
let network = NeuralNetwork(learningRate: /*#-editable-code */0.03/*#-end-editable-code */, epochs: /*#-editable-code */2000/*#-end-editable-code */)
//#-hidden-code
let outputView = PlaygroundNetworkVisualisationViewController()
outputView.page = 4
network.debugOutputHandler = outputView
PlaygroundPage.current.liveView = outputView
//#-end-hidden-code

//#-editable-code
network.add(layer: Layer(nodesCount: 4))
// we are initialising the layers weights randomly between 0 and 0.01 instead of 0 and 1
network.add(layer: Layer(nodesCount: 5, initialWeightsRange: 0 ..< 0.01, activationFunction: .tanh))
network.add(layer: Layer(nodesCount: 4, initialWeightsRange: 0 ..< 0.01, activationFunction: .tanh))
network.add(layer: Layer(nodesCount: 3))

let filePath = Bundle.main.path(forResource: "iris", ofType: "csv")!
// Load dataset from CSV file
let data = CSVDataSet(path: filePath) { columns in
    // preprocess csv columns
    let input = columns[0 ..< 4].compactMap(Double.init)
    // create output vector based on the last column
    let output: [Double]
    switch columns[4] {
    case "Iris-setosa":
        output = [1, 0, 0]
    case "Iris-versicolor":
        output = [0, 1, 0]
    default:
        output = [0, 0, 1]
    }
    return (input, output)
}

let (train, test) = data.split(ratio: 0.1)
network.trainAndTest(trainData: train, testData: test) { result in
    print(result.classifications.accuracy)
    print(result)
}

//#-end-editable-code
