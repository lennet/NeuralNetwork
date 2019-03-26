//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class GridLayer: CALayer {
    private let squareLayer = CALayer()
    private let innerReplicatorLayer = CAReplicatorLayer()
    private let replicatorLayer = CAReplicatorLayer()

    public var instanceCount = 10 {
        didSet {
            setNeedsLayout()
        }
    }

    override init() {
        super.init()
        commonInit()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }

    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        commonInit()
    }

    func commonInit() {
        let borderWidth: CGFloat = 1
        let borderColor: CGColor = UIColor.black.cgColor
        self.borderWidth = borderWidth + 1
        self.borderColor = borderColor

        squareLayer.borderColor = borderColor
        squareLayer.borderWidth = borderWidth
        innerReplicatorLayer.addSublayer(squareLayer)

        replicatorLayer.addSublayer(innerReplicatorLayer)
        addSublayer(replicatorLayer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        innerReplicatorLayer.instanceCount = instanceCount
        replicatorLayer.instanceCount = instanceCount
        let squareSize = CGSize(width: bounds.width / instanceCount, height: bounds.height / instanceCount)
        innerReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(squareSize.width, 0, 0)
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, squareSize.height, 0)
        replicatorLayer.frame = bounds
        squareLayer.frame = CGRect(x: 0, y: 0, width: squareSize.width, height: squareSize.height)
    }
}
