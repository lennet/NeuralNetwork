//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class PlotView: UIView {
    struct Point {
        let point: CGPoint
        let color: UIColor
    }

    private let grid = GridLayer()

    @IBInspectable var useGrid: Bool = true {
        didSet {
            grid.isHidden = !useGrid
        }
    }

    @IBInspectable var pointRadius: CGFloat = 10
    public var maxValue: CGFloat = 10 {
        didSet {
            grid.instanceCount = Int(maxValue) / 3
        }
    }

    private var resolution: CGFloat = 2

    private var currentlyPlottedPoints: [Point] = []
    private var currentlyPlottedPointLayer: [CALayer] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGridIfNeeded()
        layer.masksToBounds = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setupGridIfNeeded()
//        let testData = XORDataSet()
        let testData = ArtificalDataSets.fourCorners()
        plot(dataSet: testData)
    }

    public func plot(mat: Mat) {
        let points: [Point] = (0 ..< mat.shape.rows).map { rowIndex in
            let row = mat.row(at: rowIndex)
            let point = CGPoint(x: row[0], y: row[1])
            let color: UIColor = row[2] == 1 ? .red : .blue
            return Point(point: point, color: color)
        }
        plot(points: points)
    }

    public func plot(dataSet: DataSetProtocol) {
        let points: [Point] = zip(dataSet.input.values2D, dataSet.output.values2D).map { input, output in
            let point = CGPoint(x: input[0], y: input[1])
            let color: UIColor
            if let index = output.index(of: 1) {
                color = ColorHelper.colorMap[index] ?? .black
            } else {
                color = .black
            }
            return Point(point: point, color: color)
        }
        plot(points: points)
    }

    private func setupGridIfNeeded() {
        guard grid.superlayer == nil else {
            return
        }

        layer.addSublayer(grid)
    }

    public func plot(points: [CGPoint]) {
        let plotPoints = points.map { Point(point: $0, color: .blue) }
        plot(points: plotPoints)
    }

    public func plot(points: [Point]) {
        currentlyPlottedPoints = points

        // remove old layer if needed
        currentlyPlottedPointLayer.forEach { $0.removeFromSuperlayer() }
        currentlyPlottedPointLayer.removeAll()

        // Add new layer
        currentlyPlottedPointLayer.reserveCapacity(currentlyPlottedPoints.count)
        for point in currentlyPlottedPoints {
            let pointLayer = CALayer()
            pointLayer.backgroundColor = point.color.cgColor
            pointLayer.borderColor = UIColor.white.cgColor
            pointLayer.borderWidth = 1
            layer.addSublayer(pointLayer)
            currentlyPlottedPointLayer.append(pointLayer)
        }

        // define resolution based on plotted points
        let maxX = points.lazy.map { abs($0.point.x) }.max() ?? 0
        let maxY = points.lazy.map { abs($0.point.y) }.max() ?? 0

        maxValue = max(maxX, maxY)

        resolution = floor(maxValue) == maxValue ? 1 : 2
        // layout
        updatedPresentedPoints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        grid.frame = layer.bounds
        grid.setNeedsLayout()
        updatedPresentedPoints()
    }

    private func updatedPresentedPoints() {
        let scaleRatio = (bounds.width / (maxValue * resolution))

        pointRadius = max(min(bounds.height / (CGFloat(currentlyPlottedPoints.count) / 8), bounds.height / 10), 5)

        let scaleTransform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        let pointLayerSize = CGSize(width: pointRadius, height: pointRadius)
        for (pointLayer, point) in zip(currentlyPlottedPointLayer, currentlyPlottedPoints) {
            let transformedPoint = point.point.applying(scaleTransform)
            pointLayer.cornerRadius = pointRadius / 2
            pointLayer.frame = CGRect(origin: CGPoint(x: transformedPoint.x - pointLayerSize.midX + layer.bounds.midX * (resolution - 1), y: transformedPoint.y - pointLayerSize.midX + layer.bounds.midY * (resolution - 1)), size: pointLayerSize)
        }
    }
}
