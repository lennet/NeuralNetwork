//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class ProptionalStackViewChildContainerView: UIView {
    private var priority: CGFloat

    init(_ view: UIView, priority: CGFloat) {
        self.priority = priority
        super.init(frame: .zero)

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: priority, height: priority)
    }
}
