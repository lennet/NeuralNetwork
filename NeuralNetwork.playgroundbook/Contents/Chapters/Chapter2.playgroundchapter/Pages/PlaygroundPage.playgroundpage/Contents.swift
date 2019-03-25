/*:
 # Epochs, Learning Rate and Activation Functions

 Besides the number of nodes and layers there are other parameters to influence the success of the network.

 ## Epochs
 The number of iterations that are used for pass the training data through the network. More complex DataSets often and number of hidden layers require more epochs.

 ## Learning Rate
 The learning rate determines how quickly the network changes the weights based on the loss.

 ## Activation Function
 The activation function defines the output of a node for an input value. It can also be used to set the value to a certain range (e.g. between 0 and 1).
 */
//#-hidden-code
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//#-code-completion(identifier, hide, DecisionBoundaryView, Constants, DecisionBoundaryPlotView, NetworkVisualisationViewController, PlaygroundNetworkVisualisationViewController, PlaygroundLiveViewController, PlaygroundLiveViewSessionManager, PlaygroundStore, PlaygroundPageSessionManager, PlaygroundRemoteNeuralNetworkDebugOutputHandler)
//#-code-completion(identifier, hide, evaluate(result:), outputView)
//#-end-hidden-code
let network = NeuralNetwork(learningRate: /*#-editable-code */0.1/*#-end-editable-code */, epochs: /*#-editable-code */2000/*#-end-editable-code */)
/*:
 * Note:
 Debug-quicklooks might help to get a better understanding of an activation function. Tap one the icon next to the activation function variable after you've run the playground once to get a plot representation.
 */
//#-editable-code
network.add(layer: Layer(nodesCount: 2))
let activationFunction: ActivationFunction = .sigmoid
network.add(layer: Layer(nodesCount: 4, activationFunction: activationFunction))
network.add(layer: Layer(nodesCount: 2))
//#-end-editable-code

let data = ArtificalDataSets.circular()

//#-hidden-code
let outputView = PlaygroundNetworkVisualisationViewController()
outputView.setDeciscionBoundaryColorOffset(value: 0)
outputView.page = 2
network.debugOutputHandler = outputView

func evaluate(result: TestReport) {
    if result.classifications.accuracy > 0.9,
        network.epochs <= 1000 {
        PlaygroundPage.current.assessmentStatus = .pass(message: "You did it!")
    } else {
        PlaygroundPage.current.assessmentStatus = .fail(hints: ["The current accuracy is at \(Int(result.classifications.accuracy * 100))% for \(network.epochs) epochs. The Goal is 90% in less than 1000 epochs"], solution: "Try using tanh as an activation function for the hidden layer and set the number of epochs to 1000")
    }
}

//#-end-hidden-code
/*:
 - Note:
 We divide the data set into test and training data. It is important not to use the same data points for testing, as it could be that the model has developed a bias towards the training data.
 */
let (train, test) = data.split(ratio: 0.1)
network.trainAndTest(trainData: train, testData: test) { result in
    print(result)
    evaluate(result: result)
}

/*:
 * Callout(Task):
 Experiment with the amount of Layers and activation functions to create a Network that achieves an accuracy of more than 90% with less than 1000 training epochs
 */
//#-hidden-code
PlaygroundPage.current.liveView = outputView
//#-end-hidden-code
