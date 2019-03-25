/*:
 # Hello World – XOR

 The layout of a Neural Network depends on the data it is working with and the problem it is supposed to solve.

 - Note:
 The input is formated as a Matrix where every  row represents an instance and the columns are representing the input features
 */
// The input and expected class for the Neural Network
let data = DataSet(values: [[0, 0]: 0,
                            [0, 1]: 1,
                            [1, 0]: 1,
                            [1, 1]: 0])
/*:
 # XOR

 The initialized dataset is the data for the XOR operation and is one of the smallest non trivial tasks for a Neural Network.

 XOR (exclusive Or) is a logic gate that outputs 1 when exactly one of the two inputs is 1.

 ![XOR Gatter](XOR@2x.png)

 In the current code the input nodes are directly compared to the output nodes. For the network to be able to process and "understand" the input information it needs nodes between input and output, the so-called [hidden layer](glossary://Hidden%20layer). The number of neccesary hidden layers, depennds on the complexity of the problem.
 */
//#-hidden-code
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//#-code-completion(identifier, hide, DecisionBoundaryView, Constants, DecisionBoundaryPlotView, NetworkVisualisationViewController, PlaygroundNetworkVisualisationViewController, PlaygroundLiveViewController, PlaygroundLiveViewSessionManager, PlaygroundStore, PlaygroundPageSessionManager, PlaygroundRemoteNeuralNetworkDebugOutputHandler)
//#-code-completion(identifier, hide, evaluate(result:), outputView)
//#-end-hidden-code
let network = NeuralNetwork(learningRate: /*#-editable-code */0.3/*#-end-editable-code */, epochs: /*#-editable-code */3000/*#-end-editable-code */)

//#-editable-code
// The input layer
network.add(layer: Layer(nodesCount: 2))

// "Hidden" layer
// uncomment to add the Layer to the Network
// network.add(layer: Layer(nodesCount: 2, activationFunction: .sigmoid))

// The output layer
network.add(layer: Layer(nodesCount: 2, activationFunction: .linear))
//#-end-editable-code
//#-hidden-code
let outputView = PlaygroundNetworkVisualisationViewController()
outputView.page = 1
network.debugOutputHandler = outputView

func evaluate(result: TestReport) {
    if result.classifications.accuracy == 1 {
        PlaygroundPage.current.assessmentStatus = .pass(message: "Good job!")
    } else {
        PlaygroundPage.current.assessmentStatus = .fail(hints: ["The current accuracy is at \(Int(result.classifications.accuracy * 100))%. The Goal is 100%"], solution: "Uncomment the hidden layer or add your own  hidden layer")
    }
}

//#-end-hidden-code

network.trainAndTest(trainData: data, testData: data) { result in
    print(result)
    evaluate(result: result)
}

/*:
 * Callout(Task):
 Create a Network that can perform the XOR operation with 100% accuracy
 */
//#-hidden-code
PlaygroundPage.current.liveView = outputView

//#-end-hidden-code
