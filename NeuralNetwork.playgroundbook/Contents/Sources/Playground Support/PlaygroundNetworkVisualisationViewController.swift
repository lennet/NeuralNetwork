//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import PlaygroundSupport
import UIKit

public class PlaygroundNetworkVisualisationViewController: NetworkVisualisationViewController, PlaygroundLiveViewSafeAreaContainer {
//    private var firstEpoch = true
    public var page: Int?
    public override func viewDidLoad() {
        super.viewDidLoad()

        let padding: CGFloat = 16
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            liveViewSafeAreaGuide.trailingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor, constant: padding),
            liveViewSafeAreaGuide.bottomAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: padding),
            liveViewSafeAreaGuide.topAnchor.constraint(equalTo: horizontalStackView.topAnchor, constant: -padding),
            liveViewSafeAreaGuide.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor, constant: -padding),

        ])
    }

    public override func didFinishedIteration(epochReport: EpochReport, networkRepresentation: NetworkModel) {
        super.didFinishedIteration(epochReport: epochReport, networkRepresentation: networkRepresentation)
//        if firstEpoch {
        safeModel()
//            firstEpoch = false
//        }
    }

    public override func didFinishTraining() {
        super.didFinishTraining()
        safeModel()
    }

    private func safeModel() {
        if let page = page,
            let model = lastModel {
            PlaygroundStore.save(model: model, for: page)
        }
    }
}
