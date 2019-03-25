//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class AxisLayer: CALayer {
    let xLayer = CALayer()
    let yLayer = CALayer()

    private let color: CGColor = UIColor.blue.cgColor
    private var valueSubLayers: [CALayer] = []
    private let lineSize = CGSize(width: 1, height: 15)
    private let fontSize: CGFloat = 22

    var showXAxis = true {
        didSet {
            xLayer.isHidden = !showXAxis
        }
    }

    var displayedValues: [Int] = []
    var resolution = CGVector(dx: 50, dy: 50)
    var axisOffSet = CGVector(dx: 0, dy: 0)

    var showYAxis = true {
        didSet {
            yLayer.isHidden = !showYAxis
        }
    }

    override init(layer: Any) {
        super.init(layer: layer)
        initAxis()
    }

    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        initAxis()
    }

    override init() {
        super.init()
        initAxis()
    }

    private func initAxis() {
        xLayer.bounds.size.height = lineSize.width
        xLayer.backgroundColor = color
        yLayer.backgroundColor = color
        yLayer.bounds.size.width = lineSize.width
        addSublayer(xLayer)
        addSublayer(yLayer)
    }

    override func prepareForInterfaceBuilder() {
        initAxis()
    }

    private func updateDisplayedValues() {
        // TODO: cleanup
        valueSubLayers.forEach { $0.removeFromSuperlayer() }
        valueSubLayers.removeAll()
        valueSubLayers.reserveCapacity(displayedValues.count * 4)

        for value in displayedValues {
            // X Axis
            if showXAxis {
                let layer = CALayer()
                layer.bounds.size = CGSize(width: lineSize.width, height: lineSize.height)
                layer.position = CGPoint(x: bounds.midX + resolution.dx * CGFloat(value), y: bounds.midY + axisOffSet.dy)
                layer.backgroundColor = color
                addSublayer(layer)

                let textLayer = CATextLayer()
                textLayer.foregroundColor = color
                textLayer.bounds.size = CGSize(width: fontSize, height: fontSize)
                textLayer.position = CGPoint(x: bounds.midX + resolution.dx * CGFloat(value), y: bounds.midY + textLayer.bounds.midY + layer.bounds.height + axisOffSet.dy)
                textLayer.fontSize = fontSize
                textLayer.alignmentMode = .center
                textLayer.string = "\(value)"
                addSublayer(textLayer)
                valueSubLayers.append(textLayer)
                valueSubLayers.append(layer)
            }

            if showYAxis {
                // Y Axis
                let layerY = CALayer()
                layerY.bounds.size = CGSize(width: lineSize.height, height: lineSize.width)
                layerY.position = CGPoint(x: bounds.midX + axisOffSet.dx, y: bounds.midY - resolution.dy * CGFloat(value))
                layerY.backgroundColor = color
                addSublayer(layerY)

                let textLayerY = CATextLayer()
                textLayerY.foregroundColor = color
                textLayerY.bounds.size = CGSize(width: fontSize, height: fontSize)
                textLayerY.position = CGPoint(x: bounds.midX -
                    textLayerY.bounds.midX - layerY.bounds.width + axisOffSet.dx, y: bounds.midY - resolution.dy * CGFloat(value))
                textLayerY.fontSize = fontSize
                textLayerY.alignmentMode = .center
                textLayerY.preferredFrameSize()
                textLayerY.string = "\(value)"
                addSublayer(textLayerY)
                valueSubLayers.append(textLayerY)
                valueSubLayers.append(layerY)
            }
        }
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        xLayer.bounds.size.width = bounds.width
        yLayer.bounds.size.height = bounds.height
        xLayer.position = CGPoint(x: bounds.midX, y: bounds.midY + axisOffSet.dy)
        yLayer.position = CGPoint(x: bounds.midX + axisOffSet.dx, y: bounds.midY)

        updateDisplayedValues()
    }
}
