/*:
 # Data Preprocessing

 An important part of machine learning is the data and especially how it is structured. If the data contains an incorrect representation, such as noise, this can have a negative effect on the results.

 In addition to the correctness of the data, scaling and distribution also plays an important role.
 In this chapter we have an example data set where the data points are distributed between 0 and 100.

 This means that the given network cannot achieve good results. However, if the data points are normalized between 0 and 1, it achieves good results, since the deviation due to big numbers is no longer so significant.

 You can get a normalized version of a DataSet with:

 `data = data.normalized()`
 */
//#-hidden-code
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//#-code-completion(identifier, hide, DecisionBoundaryView, Constants, DecisionBoundaryPlotView, NetworkVisualisationViewController, PlaygroundNetworkVisualisationViewController, PlaygroundLiveViewController, PlaygroundLiveViewSessionManager, PlaygroundStore, PlaygroundPageSessionManager, PlaygroundRemoteNeuralNetworkDebugOutputHandler)
//#-code-completion(identifier, hide, evaluate(result:), outputView)

//#-end-hidden-code
let network = NeuralNetwork(learningRate: /*#-editable-code */0.03/*#-end-editable-code */, epochs: /*#-editable-code */2000/*#-end-editable-code */)

//#-editable-code
network.add(layer: Layer(nodesCount: 2))
network.add(layer: Layer(nodesCount: 4, activationFunction: .tanh))
network.add(layer: Layer(nodesCount: 4, activationFunction: .linear))
//#-end-editable-code
var data = ArtificalDataSets.fourCorners()
//#-editable-code
// Perform preprocessing

//#-end-editable-code
//#-hidden-code
let outputView = PlaygroundNetworkVisualisationViewController()
outputView.page = 3
network.debugOutputHandler = outputView

func evaluate(result: TestReport) {
    if result.classifications.accuracy == 1 {
        PlaygroundPage.current.assessmentStatus = .pass(message: "Yeah 🎉")
    } else {
        PlaygroundPage.current.assessmentStatus = .fail(hints: ["The current accuracy is at \(Int(result.classifications.accuracy * 100))%. The Goal is 90%"], solution: "Normalize the data with the `data = data.normalized()` method")
    }
}

//#-end-hidden-code

let (train, test) = data.split(ratio: 0.1)
network.trainAndTest(trainData: train, testData: test) { result in
    print(result)
    evaluate(result: result)
}

/*:
 * Callout(Task):
 Optimize the dataset to achieve a training accuracy of more than 90%
 */
//#-hidden-code
PlaygroundPage.current.liveView = outputView
//#-end-hidden-code
