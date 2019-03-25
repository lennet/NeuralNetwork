//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public struct ClassificationReport: Codable {
    public let prediction: [Double]
    public let real: [Double]
}

public extension Array where Element == ClassificationReport {
    /// The percentage of predictions that are correct
    var accuracy: Float {
        let numberOfHits = Float(filter { $0.prediction == $0.real }.count)
        let numberOfElements = Float(count)
        return numberOfHits / numberOfElements
    }
}

public struct TestReport {
    public let classifications: [ClassificationReport]
}

extension TestReport: CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return description
    }

    public var description: String {
        var result = "Testing\n-------------------------\n"
        result += classifications.map { report in
            let label: String
            if report.prediction == report.real {
                label = "✅"
            } else {
                label = "❌"
            }
            return "\(label) Prediction: \(report.prediction), Real: \(report.real)"
        }.joined(separator: "\n")
        result += "\nAccuracy: \(classifications.accuracy)%\n"
        result += ""
        return result
    }
}
