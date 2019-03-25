//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

public class DecisionBoundaryPlotView: UIView {
    lazy var decisionBoundaryView: DecisionBoundaryView = {
        let view = DecisionBoundaryView(frame: bounds)
        view.backgroundColor = .white
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(view, at: 0)
        return view
    }()

    private lazy var plotView: PlotView = {
        let view = PlotView(frame: bounds)
        view.useGrid = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        return view
    }()

    public func plotPoints(dataSet: DataSetProtocol) {
        plotView.plot(dataSet: dataSet)
    }

    public func plotDecisionBoundary(values: Mat) {
        decisionBoundaryView.plot(values: values)
    }
}
