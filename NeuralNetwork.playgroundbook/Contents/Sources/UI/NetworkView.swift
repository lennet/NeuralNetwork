//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class NetworkView: UIView {
    private var layerViews: [LayerView] = []
    private var connectionViews: [ConnectionView] = []
    private var inputLabels: [UILabel] = []
    private var viewModel: NetworkModel? {
        didSet {
            if oldValue == nil {
                displayNetwork()
            }
        }
    }

    public var inputLabelValues: [String] = [] {
        didSet {
            updateInputLabels()
        }
    }

    init() {
        super.init(frame: .zero)
    }

    init(frame: CGRect, viewModel: NetworkModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        displayNetwork()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func update(viewModel: NetworkModel) {
        self.viewModel = viewModel
        var index = 0
        for layer in viewModel.layer {
            for neuron in layer.neurons {
                guard let neuronWeights = neuron.weigths else {
                    continue
                }
                for weight in neuronWeights {
                    let connectionView = connectionViews[index]
                    connectionView.lineWidth = min(CGFloat(abs(weight) + 0.1), 10)
                    index += 1
                }
            }
        }
    }

    public func startTrainingAnimation() {
        connectionViews.forEach { $0.startAnimation() }
    }

    public func stopTrainingAnimation() {
        connectionViews.forEach { $0.stopAnimation() }
    }

    private var horizontalPadding: CGFloat {
        return 50
    }

    private var distanceBetweenLayer: CGFloat {
        guard let viewModel = viewModel else {
            return 0
        }
        return (bounds.width - (horizontalPadding * 2) - (viewModel.layer.count * layerSize.width)) / max(CGFloat(viewModel.layer.count - 1), 1)
    }

    private var layerSize: CGSize {
        return CGSize(width: 44, height: bounds.height)
    }

    private func displayNetwork() {
        guard let viewModel = viewModel else {
            return
        }

        for i in 0 ..< viewModel.layer.count {
            let frame = layerFrame(at: i)
            let layerView = LayerView(frame: frame, viewModel: viewModel.layer[i], shouldColorizeNodes: i == viewModel.layer.count - 1)
            layerViews.append(layerView)
            addSubview(layerView)
        }

        (0 ..< viewModel.layer.count - 1).forEach(addConnectionViews)
        updateLayout()
        startTrainingAnimation()
    }

    private func layerFrame(at index: Int) -> CGRect {
        let point = CGPoint(x: index * (layerSize.width + distanceBetweenLayer) + horizontalPadding, y: 0)
        return CGRect(origin: point, size: layerSize)
    }

    private func addConnectionViews(layerIndex: Int) {
        guard let viewModel = viewModel else {
            return
        }

        let numberOfNeurons = viewModel.layer[layerIndex].neurons.count
        let nextNumberOfNeurons = viewModel.layer[layerIndex + 1].neurons.count
        for _ in 0 ..< numberOfNeurons {
            for _ in 0 ..< nextNumberOfNeurons {
                let connectionView = ConnectionView(frame: .zero)
                insertSubview(connectionView, at: 0)
                connectionViews.append(connectionView)
            }
        }
    }

    private func updateInputLabels() {
        inputLabels.forEach { $0.removeFromSuperview() }
        inputLabels = inputLabelValues.map { value in
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.text = value
            return label
        }
        inputLabels.forEach(addSubview)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        updateLayerViewLayout()
        updateConnectionViewLayout()
        updateInputLabelsLayout()
    }

    private func updateInputLabelsLayout() {
        guard !layerViews.isEmpty else {
            return
        }
        for (index, label) in inputLabels.enumerated() {
            let nodeFrame = layerViews[0].nodeFrame(for: index)
            label.sizeToFit()
            label.center = CGPoint(x: horizontalPadding / 2, y: nodeFrame.midY)
        }
    }

    private func updateLayerViewLayout() {
        for (index, layerView) in layerViews.enumerated() {
            layerView.frame = layerFrame(at: index)
        }
    }

    private func updateConnectionViewLayout() {
        guard let viewModel = viewModel else {
            return
        }

        let connectionViewSize = CGSize(width: distanceBetweenLayer, height: bounds.height)
        var connectionViewIndex = 0

        for index in 0 ..< layerViews.count - 1 {
            let numberOfNeurons = viewModel.layer[index].neurons.count
            let nextNumberOfNeurons = viewModel.layer[index + 1].neurons.count

            let point = CGPoint(x: layerFrame(at: index).maxX, y: 0)
            for i in 0 ..< numberOfNeurons {
                let currentNodeFrame = layerViews[index].nodeFrame(for: i)
                for k in 0 ..< nextNumberOfNeurons {
                    let connectionView = connectionViews[connectionViewIndex]
                    let nextNodeFrame = layerViews[index + 1].nodeFrame(for: k)

                    connectionView.sink = CGPoint(x: 1, y: nextNodeFrame.midY / connectionViewSize.height)
                    connectionView.source = CGPoint(x: 0, y: currentNodeFrame.midY / connectionViewSize.height)

                    connectionView.frame = CGRect(origin: point, size: connectionViewSize)

                    connectionViewIndex += 1
                }
            }
        }
    }
}
