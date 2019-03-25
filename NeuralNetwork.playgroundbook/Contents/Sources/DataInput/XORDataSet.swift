//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public struct XORDataSet: DataSetProtocol {
    public let input: Mat
    public let output: Mat
    public let inputLabels: [String]?

    public init() {
        input = Mat(values: [[0, 0],
                             [1, 0],
                             [0, 1],
                             [1, 1]])
        output = Mat(values: [[0, 1],
                              [1, 0],
                              [1, 0],
                              [0, 1]])
        inputLabels = ["A", "B"]
    }
}
