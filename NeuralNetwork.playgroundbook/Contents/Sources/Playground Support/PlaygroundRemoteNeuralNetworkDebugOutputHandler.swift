//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation
import PlaygroundSupport

public class PlaygroundRemoteNeuralNetworkDebugOutputHandler: NeuralNetworkDebugOutputHandler {
    public init() {}

    public func didFinishedIteration(epochReport: EpochReport, networkRepresentation: NetworkModel) {
        let playgroundValue = NetworkVisualisationState(epochReport: epochReport, networkRepresentation: networkRepresentation).playgroundValue
        PlaygroundPage.current.proxy?.send(playgroundValue)
    }

    public func startedTraining(with dataSet: DataSetProtocol) {
        let dataSetInstace = DataSet(input: dataSet.input, output: dataSet.output, inputLabels: dataSet.inputLabels)

        PlaygroundPage.current.proxy?.send(StartedTrainingPlaygroundMessage(dataSet: dataSetInstace).playgroundValue)
    }

    public func didFinishTraining() {}

    public var debugOutputFrequency: Int {
        return 10
    }
}
