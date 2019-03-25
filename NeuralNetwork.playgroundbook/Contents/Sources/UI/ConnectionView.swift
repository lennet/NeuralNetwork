//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

extension CGPoint {
    fileprivate func convert(to view: UIView) -> CGPoint {
        return applying(.init(scaleX: view.bounds.width, y: view.bounds.height))
    }
}

@IBDesignable
class ConnectionView: UIView {
    @IBInspectable
    var source: CGPoint = CGPoint(x: 0, y: 0.2) {
        didSet {
            controlPoint2.y = source.y == 0.5 ? 0.55 : source.y
        }
    }

    @IBInspectable
    var sink: CGPoint = CGPoint(x: 1, y: 0.8) {
        didSet {
            controlPoint.y = sink.y == 0.5 ? 0.45 : sink.y
        }
    }

    @IBInspectable
    var controlPoint: CGPoint = CGPoint(x: 0.6, y: 0.2)

    @IBInspectable
    var controlPoint2: CGPoint = CGPoint(x: 0.4, y: 0.8)

    @IBInspectable
    var lineWidth: CGFloat = 0.5 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }

    var strokeColor: UIColor = UIColor.blue

    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addLineLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addLineLayer()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        addLineLayer()
        updatePath()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updatePath()
    }

    public func startAnimation() {
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0
        animation.toValue = shapeLayer.lineDashPattern!.reduce(0) { $0 - $1.intValue }
        animation.duration = 0.8
        animation.repeatCount = .infinity
        shapeLayer.add(animation, forKey: "line")
    }

    public func stopAnimation() {
        shapeLayer.removeAnimation(forKey: "line")
    }

    private func addLineLayer() {
        shapeLayer.frame = bounds
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = strokeColor.withAlphaComponent(0.7).cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineDashPattern = [24, 6]
        layer.addSublayer(shapeLayer)
    }

    private func updatePath() {
        let path = UIBezierPath()
        path.move(to: source.applying(.init(scaleX: bounds.width, y: bounds.height)))

        if controlPoint.y < controlPoint2.y {
            path.addCurve(to: sink.convert(to: self), controlPoint1: controlPoint.convert(to: self), controlPoint2: controlPoint2.convert(to: self))
        } else {
            // the sink is higher than the source and we are swapping the control points to get the same curve
            path.addCurve(to: sink.convert(to: self), controlPoint1: controlPoint2.convert(to: self), controlPoint2: controlPoint.convert(to: self))
        }

        shapeLayer.path = path.cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
}
