//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Accelerate

class InterpolationHelper {
    class func interpolate(values: [Double], indices: [Double]) -> [Double] {
        guard let last = indices.last,
            let first = indices.first else {
            return []
        }
        let n = vDSP_Length(last - first + 1)
        var result = [Double](repeating: 0, count: Int(n))
        let length = vDSP_Length(values.count + 1)
        vDSP_vgenpD(values, 1, indices, 1, &result, 1, n, length)
        return result
    }

    class func interpolate2D(values: [[Double]], indices: [[Double]]) -> [[Double]] {
        let yValues = zip(values, indices).map { linearValues, linearIndices in
            interpolate(values: linearValues, indices: linearIndices)
        }
        let row = Mat(values: yValues).transposed().values2D.map { value in
            interpolate(values: value, indices: indices[0])
        }
        return Mat(values: row).transposed().values2D
    }

    class func interpolate(values: [Double], scaleFactor: Int) -> [Double] {
        let indices = (0 ..< values.count).map { i in Double(i * scaleFactor) }
        return interpolate(values: values, indices: indices)
    }

    class func interpolate2D(values: [[Double]], scaleFactor: Int) -> [[Double]] {
        let indices = [[Double]](repeating: (0 ..< values.count).map { i in Double(i * scaleFactor) }, count: values[0].count)
        return interpolate2D(values: values, indices: indices)
    }
}
