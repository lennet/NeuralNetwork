//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import PlaygroundSupport
import UIKit

public class PlaygroundLiveViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    public var page: Int? {
        didSet {
            if let page = page {
                displayPreview(for: page)
            }
        }
    }

    public lazy var visualisationViewController: NetworkVisualisationViewController = {
        let vc = NetworkVisualisationViewController()
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            liveViewSafeAreaGuide.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: padding),
            liveViewSafeAreaGuide.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: padding),
            liveViewSafeAreaGuide.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: -padding),
            liveViewSafeAreaGuide.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: -padding),
        ])

        return vc
    }()

    private func displayPreview(for page: Int) {
        if let model = PlaygroundStore.getModel(for: page) {
            visualisationViewController.networkView.update(viewModel: model)
            visualisationViewController.networkView.stopTrainingAnimation()
            visualisationViewController.dashboardStackView.isHidden = true
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    public func hideDashboard() {
        visualisationViewController.dashboardStackView.superview?.isHidden = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let page = page {
            displayPreview(for: page)
        }
    }

    public func receive(_ message: PlaygroundValue) {
        // TODO: run playground remotely and send result back to contents view or check if liveView can only be used for empty state presentation
        if let model = NetworkVisualisationState(message) {
            visualisationViewController.didFinishedIteration(epochReport: model.epochReport, networkRepresentation: model.networkRepresentation)
        } else if let startMessage = StartedTrainingPlaygroundMessage(message) {
            visualisationViewController.startedTraining(with: startMessage.dataSet)
        }
    }

    public func liveViewMessageConnectionClosed() {}
}
