//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

public struct ActivationFunction {
    let function: (Mat) -> Mat
    let functionDerivative: (Mat) -> Mat
    let name: String
}

public extension ActivationFunction {
    static var sigmoid: ActivationFunction {
        let sigmoid: (Mat) -> (Mat) = { x in
            let exp = x.exp() // .min(Double.greatestFiniteMagnitude)
            return exp.divide(exp + 1.0) // .clamp(min: 0.0000000000000001, max: 0.9999999999999999)
        }
        return ActivationFunction(function: sigmoid, functionDerivative: { x in
            let sig = sigmoid(x)
            return sig * (1 - sig)
        }, name: #function)
    }

    static var relu: ActivationFunction {
        return ActivationFunction(function: { mat in
            mat.max(0)
        }, functionDerivative: { mat in
            let newValues = mat.values.map { $0 > 0.0 ? 1.0 : 0.0 }
            return Mat(shape: mat.shape, values: newValues)
        }, name: #function)
    }

    static var tanh: ActivationFunction {
        return ActivationFunction(function: { mat in
            mat.tanh()
        }, functionDerivative: { mat in
            1 - mat.tanh().pow(2)
        }, name: #function)
    }

    static var linear: ActivationFunction {
        return ActivationFunction(function: { $0 }, functionDerivative: { mat in Mat(ones: mat.shape) }, name: #function)
    }

    static func activationFunction(for name: String) -> ActivationFunction {
        switch name {
        case "sigmoid":
            return sigmoid
        case "relu":
            return relu
        case "tanh":
            return tanh
        default:
            return linear
        }
    }
}

extension ActivationFunction: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        let view = LinePlotView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 150)))
        view.shapeLayer.masksToBounds = true

        let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 170, height: 200)))
        containerView.backgroundColor = .white
        containerView.addSubview(view)
        view.center = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY - 15)

        let maxInputValue: Double = 5
        let possibleInputs = Array(stride(from: -maxInputValue, to: maxInputValue, by: 0.1))
        let mat = Mat(shape: Shape(rows: UInt(possibleInputs.count), cols: 1), values: possibleInputs)
        let result = function(mat)
        // TODO: filter out trailing constant numbers or find better way to define possible inputs
        result.values.forEach(view.add)
        view.layoutSubviews()
        // TODO: file radar:
        // Without the ContainerView  the presentation is flipped
        view.showAxis = true
        view.axisLayer.showYAxis = false

        // TODO: fix resolution
        view.axisLayer.displayedValues = [0, 1, Int(maxInputValue)]
        view.axisLayer.axisOffSet.dy = view.bounds.midY - CGPoint(x: 0, y: 0).applying(view.pathTransform).y

        view.axisLayer.resolution.dx = view.bounds.midX / CGFloat(possibleInputs.count) * 20
        view.axisLayer.resolution.dy = CGPoint(x: 0, y: 1).applying(view.pathTransform).y / CGFloat(maxInputValue)

        return containerView
    }
}
