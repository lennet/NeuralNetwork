//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation
import PlaygroundSupport

struct NetworkVisualisationState: Codable {
    let epochReport: EpochReport
    let networkRepresentation: NetworkModel
}

extension NetworkVisualisationState {
    init?(_ playgroundValue: PlaygroundValue) {
        switch playgroundValue {
        case let .data(data):
            guard let model = try? JSONDecoder().decode(NetworkVisualisationState.self, from: data) else {
                return nil
            }
            self = model
        default:
            return nil
        }
    }

    var playgroundValue: PlaygroundValue {
        let data = try! JSONEncoder().encode(self)
        return .data(data)
    }
}
