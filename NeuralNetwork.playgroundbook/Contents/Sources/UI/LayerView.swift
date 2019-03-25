//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

extension CGFloat {
    public static func * (left: Int, right: CGFloat) -> CGFloat {
        return CGFloat(left) * right
    }

    public static func / (left: CGFloat, right: Int) -> CGFloat {
        return left / CGFloat(right)
    }
}

extension CGSize {
    var midX: CGFloat {
        return width / 2
    }
}

class LayerView: UIView {
    var viewModel: LayerModel?
    private var shouldColorizeNodes: Bool = false

    init(frame: CGRect, viewModel: LayerModel, shouldColorizeNodes: Bool) {
        self.viewModel = viewModel
        self.shouldColorizeNodes = shouldColorizeNodes
        super.init(frame: frame)
        displayNodes()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    lazy var neuronSize = {
        CGSize(width: bounds.width, height: bounds.width)
    }()

    public func nodeFrame(for index: Int) -> CGRect {
        guard let viewModel = viewModel else {
            return .zero
        }
        let numberOfNeurons: CGFloat = max(CGFloat(viewModel.neurons.count), 1)
        let verticalPadding = ((bounds.height - (numberOfNeurons * neuronSize.height)) / numberOfNeurons) / 2

        let point = CGPoint(x: 0, y: verticalPadding + index * (neuronSize.height + verticalPadding * 2))
        return CGRect(origin: point, size: neuronSize)
    }

    func displayNodes() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.neurons.enumerated().map {
            var color: UIColor
            if shouldColorizeNodes, viewModel.neurons.count <= ColorHelper.allColors.count {
                color = ColorHelper.allColors[$0.offset]
            } else {
                color = .black
            }
            return NeuronView(frame: nodeFrame(for: $0.offset), viewModel: $0.element, color: color)
        }.forEach(addSubview)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for (index, nodeView) in subviews.enumerated() {
            nodeView.frame = nodeFrame(for: index)
        }
    }
}
