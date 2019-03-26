//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import CoreGraphics

public protocol DataSetProtocol: CustomPlaygroundDisplayConvertible {
    var input: Mat { get }
    var output: Mat { get }
    var inputLabels: [String]? { get }
}

public extension DataSetProtocol {
    func split(ratio: Float) -> (DataSetProtocol, DataSetProtocol) {
        let numberOfRows = input.values2D.count
        let splitIndex = numberOfRows - Int(Float(numberOfRows) * ratio)
        let aRange = 0 ..< splitIndex
        let aInput = Mat(values: [[Double]](input.values2D[aRange]))
        let aOutput = Mat(values: [[Double]](output.values2D[aRange]))
        let bRange = splitIndex ..< numberOfRows
        let bInput = Mat(values: [[Double]](input.values2D[bRange]))
        let bOutput = Mat(values: [[Double]](output.values2D[bRange]))
        return (DataSet(input: aInput, output: aOutput, inputLabels: inputLabels), DataSet(input: bInput, output: bOutput, inputLabels: inputLabels))
    }

    func normalized() -> DataSet {
        return DataSet(input: input.normalized(), output: output, inputLabels: inputLabels)
    }
}

public struct DataSet: DataSetProtocol, Codable {
    public let input: Mat
    public let output: Mat
    public let inputLabels: [String]?

    public init(input: Mat, output: Mat, inputLabels: [String]?) {
        self.input = input
        self.output = output
        self.inputLabels = inputLabels
    }
}

public extension DataSet {
    init(input: Mat, output: Mat) {
        self.input = input
        self.output = output

        let aUniCode = UnicodeScalar("A")
        inputLabels = (0 ..< input.shape.cols).map { index in
            String(UnicodeScalar(aUniCode.value + UInt32(index))!)
        }
    }

    init(values: [[Double]: Int]) {
        let numberOfClasses = (values.values.max() ?? 0) + 1
        let inputValues = Array(values.keys)
        input = Mat(values: inputValues)

        let outputValues: [[Double]] = values.values.map { value in
            var outputVector = [Double].init(repeating: 0, count: numberOfClasses)
            outputVector[value] = 1
            return outputVector
        }
        output = Mat(values: outputValues)
        let aUniCode = UnicodeScalar("A")
        inputLabels = (0 ..< input.shape.cols).map { index in
            String(UnicodeScalar(aUniCode.value + UInt32(index))!)
        }
    }
}

extension DataSetProtocol {
    public var playgroundDescription: Any {
        // TODO: fix crash for datasets that are not 2D
        let view = PlotView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
        view.backgroundColor = .white
        view.plot(dataSet: self)
        return view
    }
}
