//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public struct NetworkModel: Codable, Equatable {
    let layer: [LayerModel]
}

public extension NetworkModel {
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url)
    }

    static func load(from url: URL) throws -> NetworkModel {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(NetworkModel.self, from: data)
    }
}

public struct LayerModel: Codable, Equatable {
    let neurons: [NeuronModel]
    let activationFunction: String?
}

extension LayerModel {
    init(neurons: [NeuronModel]) {
        self.neurons = neurons
        activationFunction = nil
    }
}

public struct NeuronModel: Codable, Equatable {
    let weigths: [Double]?
    let bias: Double?
}
