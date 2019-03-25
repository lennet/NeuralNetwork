//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import PlaygroundSupport
import UIKit

public class PlaygroundStore {
    public class func save(model: NetworkModel, for page: Int) {
        let data = try! JSONEncoder().encode(model)
        PlaygroundKeyValueStore.current["\(page)"] = .data(data)
    }

    public class func getModel(for page: Int) -> NetworkModel? {
        if case let .data(modelData)? = PlaygroundKeyValueStore.current["\(page)"],
            let model = try? JSONDecoder().decode(NetworkModel.self, from: modelData) {
            return model
        }

        // fallback default models
        func modelHelper(layout: [Int]) -> NetworkModel {
            let layers = layout.map { x in
                LayerModel(neurons: (0 ..< x).map { _ in NeuronModel(weigths: nil, bias: nil) })
            }
            return NetworkModel(layer: layers)
        }

        switch page {
        case 0:
            return modelHelper(layout: [2, 4, 2])
        case 1:
            return modelHelper(layout: [2, 2])
        case 2:
            return modelHelper(layout: [2, 4, 2])
        case 3:
            return modelHelper(layout: [2, 4, 4])
        case 4:
            return modelHelper(layout: [4, 5, 4, 3])
        default:
            return nil
        }
    }
}
