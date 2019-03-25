//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public class IrisDataSet: CSVDataSet {
    public init() {
        let path = Bundle.main.path(forResource: "iris", ofType: "csv")!
        super.init(path: path) { row in
            let input = row[0 ..< 4].compactMap(Double.init)
            let output: [Double]
            switch row[4] {
            case "Iris-setosa":
                output = [1, 0, 0]
            case "Iris-versicolor":
                output = [0, 1, 0]
            default:
                output = [0, 0, 1]
            }
            return (input, output)
        }
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
