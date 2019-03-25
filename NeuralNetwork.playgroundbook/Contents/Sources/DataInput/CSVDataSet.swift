//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public class CSVDataSet: DataSetProtocol, CustomPlaygroundDisplayConvertible {
    public var inputLabels: [String]?
    public let input: Mat
    public let output: Mat

    public init(path: String, inputLabels: [String]? = nil, preprocessingBlock: ([Substring.SubSequence]) -> ([Double], [Double])) {
        let csv = try! String(contentsOfFile: path)
        let csvRows = csv.split(separator: "\n").map { $0.split(separator: ",") }

        let (inputValues, outputValues) = csvRows.shuffled().map(preprocessingBlock).reduce(into: ([[Double]](), [[Double]]())) { result, data in
            result.0.append(data.0)
            result.1.append(data.1)
        }

        input = Mat(values: inputValues)
        output = Mat(values: outputValues)
        self.inputLabels = inputLabels
    }
}
