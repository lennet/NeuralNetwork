//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import NeuralNetwork
import XCTest

class DataSetTests: XCTestCase {
    func testSplit() {
        let dataSet = IrisDataSet()
        let (a, b) = dataSet.split(ratio: 0.1)

        XCTAssertEqual(a.input.shape.rows, 135)
        XCTAssertEqual(a.output.shape.rows, 135)

        XCTAssertEqual(b.input.shape.rows, 15)
        XCTAssertEqual(b.output.shape.rows, 15)
    }

    func testIrisDataSetTotalCount() {
        let dataSet = IrisDataSet()
        XCTAssertEqual(dataSet.input.shape.rows, 150)
        XCTAssertEqual(dataSet.output.shape.rows, 150)
    }
}
