//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

@testable import NeuralNetwork
import XCTest

class MatTests: XCTestCase {
    func testNegate() {
        let input = Mat(shape: (2, 2), values: [1, 1, 1, 1])
        let expectedOutput = Mat(shape: (2, 2), values: [-1, -1, -1, -1])

        XCTAssertEqual(input.negate(), expectedOutput)
    }

    func testSumrows() {
        let input = Mat(shape: (2, 2), values: [1, 1, 1, 1])
        let expectedOutput = Mat(shape: (2, 1), values: [2, 2])

        XCTAssertEqual(input.sumRows(), expectedOutput)
    }

    func testTransposed() {
        let input = Mat(shape: (2, 3), values: [1, 2, 3, 4, 5, 6])
        let expectedOutput = Mat(shape: (3, 2), values: [1, 4, 2, 5, 3, 6])

        XCTAssertEqual(input.transposed(), expectedOutput)
    }

    func testSum() {
        let input = Mat(shape: (2, 3), values: [1, 2, 3, 4, 5, 6])
        let expectedOutput: Double = 21

        XCTAssertEqual(input.sum(), expectedOutput)
    }

    func testValueAtIndex() {
        let mat = Mat(shape: (3, 3), values: [1, 2, 3, 4, 5, 6, 7, 8, 9])
        XCTAssertEqual(mat.value(row: 0, column: 0), 1)
        XCTAssertEqual(mat.value(row: 0, column: 1), 2)
        XCTAssertEqual(mat.value(row: 0, column: 2), 3)
        XCTAssertEqual(mat.value(row: 1, column: 0), 4)
        XCTAssertEqual(mat.value(row: 1, column: 1), 5)
        XCTAssertEqual(mat.value(row: 1, column: 2), 6)
        XCTAssertEqual(mat.value(row: 2, column: 0), 7)
        XCTAssertEqual(mat.value(row: 2, column: 1), 8)
        XCTAssertEqual(mat.value(row: 2, column: 2), 9)
    }

    func testValues2D() {
        let input = Mat(shape: (3, 3), values: [0, 2, 4, 5, 7, 9, 10, 12, 14])
        let expectedOutput: [[Double]] = [[0, 2, 4], [5, 7, 9], [10, 12, 14]]
        let realOutput = input.values2D
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testReshape() {
        let input = Mat(shape: (1, 9), values: [0, 2, 4, 5, 7, 9, 10, 12, 14])
        let expectedOutput: [[Double]] = [[0, 2, 4], [5, 7, 9], [10, 12, 14]]
        let realOutput = input.reshape(to: Shape(rows: 3, cols: 3))?.values2D
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testMax() {
        let input = Mat(shape: (1, 9), values: [0, 2, 4, 5, 7, 9, 10, 12, 14])
        let expectedOutput = Mat(shape: (1, 9), values: [4, 4, 4, 5, 7, 9, 10, 12, 14])
        let realOutput = input.max(4)
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testMin() {
        let input = Mat(shape: (1, 9), values: [0, 2, 4, 5, 7, 9, 10, 12, 14])
        let expectedOutput = Mat(shape: (1, 9), values: [0, 2, 4, 5, 7, 7, 7, 7, 7])
        let realOutput = input.min(7)
        XCTAssertEqual(expectedOutput, realOutput)
    }

    func testClamp() {
        let input = Mat(shape: (1, 9), values: [-100, 2, 4, 5, 7, 9, 10, 12, 14])
        let expectedOutput = Mat(shape: (1, 9), values: [4, 4, 4, 5, 7, 7, 7, 7, 7])
        let realOutput = input.clamp(min: 4, max: 7)
        XCTAssertEqual(expectedOutput, realOutput)
    }
}
