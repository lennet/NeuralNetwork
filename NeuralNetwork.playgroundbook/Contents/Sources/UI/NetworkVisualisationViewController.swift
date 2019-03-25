//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

public class NetworkVisualisationViewController: UIViewController, NeuralNetworkDebugOutputHandler {
    let horizontalStackView = UIStackView()
    let dashboardStackView = UIStackView()
    let networkView = NetworkView()
    private var minInput: Double = 0
    private var maxInput: Double = 0

    public let decisionPlotView = DecisionBoundaryPlotView()
    let lossPlotView = LinePlotView()
    var lastModel: NetworkModel?
    private let epochLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let lossLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        horizontalStackView.frame = view.bounds
        horizontalStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        horizontalStackView.distribution = .fillProportionally

        dashboardStackView.distribution = .fillEqually

        dashboardStackView.addArrangedSubview(dashboardItemStackView(label: epochLabel, content: SquaredContainerView(frame: .zero, subview: decisionPlotView)))
        dashboardStackView.addArrangedSubview(dashboardItemStackView(label: lossLabel, content: SquaredContainerView(frame: .zero, subview: lossPlotView)))

        horizontalStackView.addArrangedSubview(ProptionalStackViewChildContainerView(networkView, priority: 5))
        horizontalStackView.addArrangedSubview(ProptionalStackViewChildContainerView(dashboardStackView, priority: 2))
        view.addSubview(horizontalStackView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateStackViewLayout()
    }

    private func dashboardItemStackView(label: UIView, content: UIView) -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.addArrangedSubview(ProptionalStackViewChildContainerView(label, priority: 1))
        stackView.addArrangedSubview(ProptionalStackViewChildContainerView(content, priority: 5))
        return stackView
    }

    private func updateStackViewLayout() {
        if view.bounds.width > view.bounds.height {
            horizontalStackView.axis = .horizontal
            dashboardStackView.axis = .vertical
        } else {
            horizontalStackView.axis = .vertical
            dashboardStackView.axis = .horizontal
        }
    }

    public func didFinishedIteration(epochReport: EpochReport, networkRepresentation: NetworkModel) {
        lossPlotView.add(value: epochReport.loss)
        networkView.update(viewModel: networkRepresentation)
        updateDashboards(for: networkRepresentation)

        epochLabel.text = "Epoch: \(String(format: "%04d", epochReport.epochIndex))"
        lossLabel.text = "Loss: \(String(format: "%.3f", epochReport.loss))"
        lastModel = networkRepresentation
    }

    public func startedTraining(with dataSet: DataSetProtocol) {
        minInput = dataSet.input.values.min() ?? 0
        maxInput = dataSet.input.values.max() ?? 0

        decisionPlotView.plotPoints(dataSet: dataSet)
        networkView.inputLabelValues = dataSet.inputLabels ?? []
    }

    public func didFinishTraining() {
        networkView.stopTrainingAnimation()
    }

    public func setDeciscionBoundaryColorOffset(value: Int) {
        decisionPlotView.decisionBoundaryView.colorIndexOffset = value
    }

    lazy var possibleInput: Mat = {
        let sideStide = Array(stride(from: minInput, to: maxInput, by: (maxInput * 2.0) / 100))
        let inputValues = sideStide.map { x in
            sideStide.map { [Double(x), Double($0)] }
        }.joined()
        return Mat(values: Array(inputValues)).transposed()
    }()

    private func updateDashboards(for model: NetworkModel) {
        guard model.layer[0].neurons.count == 2 else {
            // We currently can only plot two dimensional data
            decisionPlotView.isHidden = true
            return
        }
        let result = NeuralNetwork(model: model)
            .predict(input: possibleInput)
            .transposed()
        decisionPlotView.plotDecisionBoundary(values: result)
    }

    public var debugOutputFrequency: Int {
        return 10
    }
}
