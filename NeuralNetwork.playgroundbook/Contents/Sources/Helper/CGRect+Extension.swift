//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import CoreGraphics

extension CGRect {
    func map<T>(_ transform: (Int, Int) throws -> T) rethrows -> [T] {
        var result = [T]()
        result.reserveCapacity(Int(width * height))
        for x in Int(minX) ..< Int(maxX) {
            for y in Int(minY) ..< Int(maxY) {
                let current = try transform(x, y)
                result.append(current)
            }
        }
        return result
    }

    var allPoints: [CGPoint] {
        return map(CGPoint.init)
    }
}
