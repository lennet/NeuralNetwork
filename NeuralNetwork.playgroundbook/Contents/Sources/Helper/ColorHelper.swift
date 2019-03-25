//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

private extension DecisionBoundaryView.Pixel {
    init(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        r = UInt8(red * 255)
        g = UInt8(green * 255)
        b = UInt8(blue * 255)
        a = UInt8(alpha * 255)
    }
}

class ColorHelper {
    static var allColors: [UIColor] = [
        #colorLiteral(red: 0.03921568627, green: 0.5176470588, blue: 1, alpha: 1),
        #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1),
        #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1),
        #colorLiteral(red: 1, green: 0.8392156863, blue: 0.03921568627, alpha: 1),
    ]
    static var colorMap: [Int: UIColor] = {
        var result: [Int: UIColor] = [:]
        ColorHelper.allColors.enumerated().forEach { index, color in
            result[index] = color
        }
        return result
    }()

    static var pixelValues: [(value: Double, color: DecisionBoundaryView.Pixel)] = {
        ColorHelper.allColors.map(DecisionBoundaryView.Pixel.init).enumerated().map { index, color in
            (Double(index + 1), color)
        }
    }()
}
