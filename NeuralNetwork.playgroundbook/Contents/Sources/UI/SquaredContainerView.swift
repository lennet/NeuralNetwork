//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class SquaredContainerView: UIView {
    init(frame: CGRect, subview: UIView) {
        super.init(frame: frame)
        addSubview(subview)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let side = min(bounds.width, bounds.height)
        for subview in subviews {
            subview.frame.size = CGSize(width: side, height: side)
            subview.center = center
        }
    }
}
