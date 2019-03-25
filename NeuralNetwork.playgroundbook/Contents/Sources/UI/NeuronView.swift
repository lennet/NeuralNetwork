//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class NeuronView: UIView {
    let viewModel: NeuronModel?

    init(frame: CGRect, viewModel: NeuronModel, color: UIColor) {
        self.viewModel = viewModel
        super.init(frame: frame)
        layer.borderWidth = 5
        if color == UIColor.black {
            backgroundColor = color
        } else {
            backgroundColor = color
            layer.borderColor = UIColor.black.cgColor
        }
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
