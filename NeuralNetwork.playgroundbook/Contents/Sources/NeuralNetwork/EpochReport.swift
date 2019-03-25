//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public struct EpochReport: Codable {
    public let epochIndex: Int
    public let classifications: [ClassificationReport]
    public let loss: Double
}

extension EpochReport: CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return description
    }

    public var description: String {
        var result = ""
        result += "Epoch: \(epochIndex)\n"
        result += "-------------------------\n"
        result += "Accuracy: \(classifications.accuracy)%\n"
        result += "loss: \(loss)\n"
        result += "-------------------------"
        return result
    }
}
