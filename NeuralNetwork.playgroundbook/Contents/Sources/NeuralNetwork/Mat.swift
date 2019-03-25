//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Accelerate

public struct Shape: Codable, Equatable {
    public let rows: UInt
    public let cols: UInt
}

public struct Mat: Equatable, Codable {
    public let shape: Shape
    let values: [Double]

    init(shape: (UInt, UInt), values: [Double]) {
        self.init(shape: Shape(rows: shape.0, cols: shape.1), values: values)
    }

    init(shape: Shape, values: [Double]) {
        self.shape = shape
        self.values = values
    }

    init(ones shape: Shape) {
        self.shape = shape
        let numberOfElements = Int(shape.cols * shape.rows)
        values = [Double](repeating: 1, count: numberOfElements)
    }

    init(zeros shape: Shape) {
        self.shape = shape
        let numberOfElements = Int(shape.cols * shape.rows)
        values = [Double](repeating: 0, count: numberOfElements)
    }

    public init(values: [[Double]]) {
        self.values = values.reduce([Double](), +)
        shape = Shape(rows: UInt(values.count), cols: UInt(values[0].count))
    }

    var values2D: [[Double]] {
        return (0 ..< shape.rows).map(row)
    }

    func column(at index: UInt) -> [Double] {
        return transposed().row(at: index)
    }

    func columns(in range: ClosedRange<UInt>) -> Mat {
        let t = transposed()
        return Mat(values: range.map(t.row)).transposed()
    }

    func value(row: UInt, column: UInt) -> Double {
        let index = Int(row * shape.rows + column)
        return values[index]
    }

    func row(at index: UInt) -> [Double] {
        return Array(values[Int(index * shape.cols) ..< Int((index + 1) * shape.cols)])
    }

    public static func == (lhs: Mat, rhs: Mat) -> Bool {
        return lhs.shape == rhs.shape && lhs.values == rhs.values
    }

    public func broadcast(to newShape: Shape) -> Mat? {
        // TODO: Test
        if newShape.rows == shape.rows,
            newShape.cols % shape.cols == 0 {
            let amount = Int(newShape.cols / shape.cols)
            let newValues: [Double] = Array(values.lazy.map { value in
                [Double](repeating: value, count: amount)
            }.joined())
            return Mat(shape: newShape, values: newValues)
        } else if newShape.cols == shape.cols,
            newShape.rows % shape.rows == 0 {
            let newValues = Array([[Double]].init(repeating: values, count: Int(newShape.rows / shape.rows))
                .joined())
            return Mat(shape: newShape, values: newValues)
        }
        return nil
    }

    func reshape(to newShape: Shape) -> Mat? {
        guard newShape.cols * newShape.rows == shape.rows * shape.cols else {
            return nil
        }
        return Mat(shape: newShape, values: values)
    }

    func dot(_ mat: Mat) -> Mat {
        var result = [Double](repeating: 0.0, count: Int(shape.rows * mat.shape.cols))
        vDSP_mmulD(values, 1, mat.values, 1, &result, 1, shape.rows, mat.shape.cols, shape.cols)
        return Mat(shape: (shape.rows, mat.shape.cols), values: result)
    }

    func add(_ mat: Mat) -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_vaddD(values, 1, mat.values, 1, &result, 1, vDSP_Length(values.count))
        return Mat(shape: shape, values: result)
    }

    func add(_ scalar: Double) -> Mat {
        var scalar = scalar
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_vsaddD(values, 1, &scalar, &result, 1, shape.rows * shape.cols)
        return Mat(shape: shape, values: result)
    }

    func subtract(_ mat: Mat) -> Mat {
        return self + mat.negate()
    }

    func mult(_ mat: Mat) -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_vmulD(values, 1, mat.values, 1, &result, 1, vDSP_Length(values.count))
        return Mat(shape: shape, values: result)
    }

    func mult(_ scalar: Double) -> Mat {
        var sc = scalar
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_vsmulD(values, 1, &sc, &result, 1, vDSP_Length(result.count))
        return Mat(shape: shape, values: result)
    }

    func divide(_ mat: Mat) -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_vdivD(mat.values, 1, values, 1, &result, 1, vDSP_Length(values.count))
        return Mat(shape: shape, values: result)
    }

    func negate() -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        let input = values
        vDSP_vnegD(input, 1, &result, 1, vDSP_Length(values.count))
        return Mat(shape: shape, values: result)
    }

    func sumRows() -> Mat {
        let results: [Double] = (0 ..< shape.rows).map { rowIndex in
            let row = self.row(at: rowIndex)
            var result = 0.0
            vDSP_sveD(Array(row), 1, &result, vDSP_Length(row.count))
            return result
        }
        return Mat(shape: (shape.rows, 1), values: results)
    }

    public func transposed() -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_mtransD(values, 1, &result, 1, shape.cols, shape.rows)
        return Mat(shape: (shape.cols, shape.rows), values: result)
    }

    public func sum() -> Double {
        var result = 0.0
        vDSP_sveD(values, 1, &result, vDSP_Length(values.count))
        return result
    }

    public static func + (lhs: Mat, rhs: Mat) -> Mat {
        if lhs.shape == rhs.shape {
            return lhs.add(rhs)
        } else if let broadcasted = lhs.broadcast(to: rhs.shape) {
            return broadcasted.add(rhs)
        } else if let broadcasted = rhs.broadcast(to: lhs.shape) {
            return lhs.add(broadcasted)
        } else {
            fatalError("You can't add matrices of shape \(lhs.shape) and \(rhs.shape)")
        }
    }

    public static func + (lhs: Mat, rhs: Double) -> Mat {
        return lhs.add(rhs)
    }

    public static func + (lhs: Double, rhs: Mat) -> Mat {
        return rhs.add(lhs)
    }

    public static func - (lhs: Mat, rhs: Double) -> Mat {
        return lhs + (-rhs)
    }

    public static func - (lhs: Mat, rhs: Mat) -> Mat {
        return lhs.subtract(rhs)
    }

    public static func -= (lhs: inout Mat, rhs: Mat) {
        lhs = lhs - rhs
    }

    public static func - (lhs: Double, rhs: Mat) -> Mat {
        return lhs + rhs.negate()
    }

    public static func * (lhs: Mat, rhs: Double) -> Mat {
        return lhs.mult(rhs)
    }

    public static func * (lhs: Double, rhs: Mat) -> Mat {
        return rhs.mult(lhs)
    }

    public static func * (lhs: Mat, rhs: Mat) -> Mat {
        if lhs.shape == rhs.shape {
            return lhs.mult(rhs)
        } else if let broadcasted = lhs.broadcast(to: rhs.shape) {
            return broadcasted.mult(rhs)
        } else if let broadcasted = rhs.broadcast(to: lhs.shape) {
            return lhs.mult(broadcasted)
        } else {
            fatalError("You can't multiply matrices of shape \(lhs.shape) and \(rhs.shape)")
        }
    }

    public static func / (lhs: Mat, rhs: Mat) -> Mat {
        if lhs.shape == rhs.shape {
            return lhs.divide(rhs)
        } else if let broadcasted = lhs.broadcast(to: rhs.shape) {
            return broadcasted.divide(lhs)
        } else if let broadcasted = rhs.broadcast(to: lhs.shape) {
            return lhs.divide(broadcasted)
        } else {
            fatalError("You can't divide matrices of shape \(lhs.shape) and \(rhs.shape)")
        }
    }

    public func log() -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        var count = Int32(values.count)
        vvlog(&result, values, &count)
        return Mat(shape: shape, values: result)
    }

    public func exp() -> Mat {
        var result = [Double](repeating: 0.0, count: values.count)
        var count = Int32(values.count)
        vvexp(&result, values, &count)
        return Mat(shape: shape, values: result)
    }

    public func pow(_ value: Double) -> Mat {
        var input = values
        var y: [Double] = [Double](repeating: value, count: values.count)
        var result = [Double](repeating: 0, count: values.count)
        var n = Int32(values.count)
        vvpow(&result, &y, &input, &n)
        return Mat(shape: shape, values: result)
    }

    public func tanh() -> Mat {
        var input = values
        var result: [Double] = [Double](repeating: 0, count: values.count)
        var n = Int32(values.count)
        vvtanh(&result, &input, &n)
        return Mat(shape: shape, values: result)
    }

    public func min(_ value: Double) -> Mat {
        return clamp(min: -Double.greatestFiniteMagnitude, max: value)
    }

    public func max(_ value: Double) -> Mat {
        var results = [Double](repeating: 0.0, count: values.count)
        var minValue = value
        vDSP_vthrD(values, 1, &minValue, &results, 1, vDSP_Length(values.count))
        return Mat(shape: shape, values: results)
    }

    public func clamp(min: Double, max: Double) -> Mat {
        var results = [Double](repeating: 0.0, count: values.count)
        var min = min
        var max = max
        vDSP_vclipD(values, 1, &min, &max, &results, 1, vDSP_Length(values.count))
        let newValues = values.map { Swift.min(Swift.max($0, min), max) }
        return Mat(shape: shape, values: newValues)
    }

    public func normalized() -> Mat {
        var mean: Double = 0.0
        var std: Double = 0.0
        var result = [Double](repeating: 0.0, count: values.count)
        vDSP_normalizeD(values, 1, &result, 1, &mean, &std, vDSP_Length(values.count))
        return Mat(shape: shape, values: result)
    }
}
