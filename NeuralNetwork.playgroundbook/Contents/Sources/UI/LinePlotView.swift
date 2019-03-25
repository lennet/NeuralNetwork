//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class LinePlotView: UIView {
    private var path = UIBezierPath()

    public var showAxis: Bool = false {
        didSet {
            axisLayer.isHidden = !showAxis
        }
    }

    var maxX: CGFloat = -1
    var maxY: CGFloat = 0
    var minY: CGFloat = 0

    public let axisLayer = AxisLayer()

    var shapeLayer = CAShapeLayer()

    var pathTransform: CGAffineTransform {
        let pathBounds = path.bounds
        let yScaleFactor = bounds.height / max(maxY - minY, 1)
        let xScaleFactor = bounds.width / max(pathBounds.maxX, 1)
        return CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
            .translatedBy(x: 0, y: abs(minY))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(axisLayer)
        axisLayer.isHidden = !showAxis

        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.isGeometryFlipped = true
        layer.addSublayer(shapeLayer)

        layoutSublayers(of: layer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func add(value: Double) {
        let y = CGFloat(value * 100)
        let x = maxX + 1
        let newPoint = CGPoint(x: x, y: y)
        updatePath(with: newPoint)
        updateUI()
        maxX = newPoint.x
    }

    private func updatePath(with point: CGPoint) {
        if point.y > maxY {
            maxY = point.y
        } else if point.y < minY {
            minY = point.y
        }
        if maxX < 0 {
            path.move(to: point)
        }
        path.addLine(to: point)
    }

    private func updateUI() {
        let currentPath = path.copy() as! UIBezierPath
        currentPath.apply(pathTransform)
        shapeLayer.path = currentPath.cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        axisLayer.bounds = bounds
        axisLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
