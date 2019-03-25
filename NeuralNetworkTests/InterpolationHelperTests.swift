//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

@testable import NeuralNetwork
import XCTest

class InterpolationHelperTests: XCTestCase {
    func testInterpolateWithIndices() {
        let input: [[Double]] = [[0, 2, 4], [0, 2, 4]]
        let expectedOutput: [Double] = [0, 1, 2, 3, 4]
        let realOutput = InterpolationHelper.interpolate(values: input[0], indices: input[1])
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testInterpolateWithIndicesNotStartingFromZero() {
        let input: [[Double]] = [[5, 7, 9], [0, 2, 4]]
        let expectedOutput: [Double] = [5, 6, 7, 8, 9]
        let realOutput = InterpolationHelper.interpolate(values: input[0], indices: input[1])
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testInterpolateWithIndicesWithScaleFactor() {
        let input: [Double] = [0, 2, 4, 6]
        let expectedOutput: [Double] = [0, 1, 2, 3, 4, 5, 6]
        let realOutput = InterpolationHelper.interpolate(values: input, scaleFactor: 2)
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testInterpolate2DWithScaleFactor() {
        let input: [[Double]] = Mat(shape: (3, 3), values: [0, 2, 4, 10, 12, 14, 20, 22, 24]).values2D
        let expectedOutput: [[Double]] = [[0, 1, 2, 3, 4], [5, 6, 7, 8, 9], [10, 11, 12, 13, 14], [15, 16, 17, 18, 19], [20, 21, 22, 23, 24]]
        let realOutput = InterpolationHelper.interpolate2D(values: input, scaleFactor: 2)
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testInterpolate2DWithIndices() {
        let input: [[Double]] = [[0, 2, 4], [10, 12, 14], [20, 22, 24]]
        let expectedOutput: [[Double]] = [[0, 1, 2, 3, 4], [5, 6, 7, 8, 9], [10, 11, 12, 13, 14], [15, 16, 17, 18, 19], [20, 21, 22, 23, 24]]
        let realOutput = InterpolationHelper.interpolate2D(values: input, indices: [[0, 2, 4], [0, 2, 4], [0, 2, 4]])
        XCTAssertEqual(expectedOutput, realOutput)
    }
}
