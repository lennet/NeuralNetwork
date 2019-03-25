//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

extension UIBezierPath {
    var allPoints: [CGPoint] {
        return bounds.allPoints.filter(contains)
    }
}
