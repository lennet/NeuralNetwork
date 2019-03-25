/*:

 # Introduction to Neural Networks

 Neural network is a machine learning strategy whose structure is loosely based on the structure of a brain's neurons.

 The network consists of several layers of neurons. All neurons are connected to all neurons from the previous and preceding layers. If the network is fed with data, the connections that lead to a correct response are strengthened and connections that lead to errors are weakened.

 Here is an example Network. In the following chapters, you will learn about some details of Neural Networks and develop your own networks.
 */
//#-hidden-code
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

func evaluate(result _: TestReport) {
    PlaygroundPage.current.assessmentStatus = .pass(message: "[Lets get started and with the \"Hello World\" of Neural Networks](Hello%20World/XOR)")
}

//#-code-completion(identifier, hide, DecisionBoundaryView, Constants, DecisionBoundaryPlotView, NetworkVisualisationViewController, PlaygroundNetworkVisualisationViewController, PlaygroundLiveViewController, PlaygroundLiveViewSessionManager, PlaygroundStore, PlaygroundPageSessionManager, PlaygroundRemoteNeuralNetworkDebugOutputHandler)
//#-code-completion(identifier, hide, evaluate(result:), outputView)
//#-end-hidden-code
let network = NeuralNetwork(learningRate: /*#-editable-code */0.3/*#-end-editable-code */, epochs: /*#-editable-code */1000/*#-end-editable-code */)
//#-hidden-code
let outputView = PlaygroundNetworkVisualisationViewController()
outputView.page = 0
outputView.setDeciscionBoundaryColorOffset(value: 0)
network.debugOutputHandler = outputView
//#-end-hidden-code
//#-editable-code
network.add(layer: Layer(nodesCount: 2))
network.add(layer: Layer(nodesCount: 4, activationFunction: .tanh))
network.add(layer: Layer(nodesCount: 2))

let data = ArtificalDataSets.circular()
let (train, test) = data.split(ratio: 0.1)
network.trainAndTest(trainData: train, testData: test) { result in
    print(result)
    evaluate(result: result)
}

//#-end-editable-code
/*:
 During execution, a plot of the loss function is displayed below the network. The loss function contains the difference between the actual and expected output of the Neural Network. Next to it is a representation of the decision boundary.

 * Callout(Task):
 Execute the code
 */
//#-hidden-code
PlaygroundPage.current.liveView = outputView
//#-end-hidden-code
