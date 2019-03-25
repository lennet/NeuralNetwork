//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import UIKit

class DecisionBoundaryView: UIView {
    private var imageBuffer: CGImage?
    private let context = CIContext()

    public var colorIndexOffset = -1

    struct Pixel {
        let r: UInt8, g: UInt8, b: UInt8, a: UInt8
    }

    public func plot(values: Mat) {
        DispatchQueue.global(qos: .background).async {
            guard let image = self.image(for: values.values2D) else {
                return
            }
            DispatchQueue.main.async {
                self.imageBuffer = image
                self.setNeedsDisplay()
            }
        }
    }

    private func image(for values: [[Double]]) -> CGImage? {
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        let pixels = values.map(pixel)
        let sizef = sqrt(Float(pixels.count))
        let size = Int(sizef)
        let imageData = Data(bytes: pixels, count: pixels.count * MemoryLayout<Pixel>.stride) as CFData
        guard let providerRef = CGDataProvider(data: imageData) else {
            return nil
        }
        return CGImage(width: size, height: size,
                       bitsPerComponent: bitsPerComponent,
                       bitsPerPixel: bitsPerPixel,
                       bytesPerRow: size * MemoryLayout<Pixel>.stride,
                       space: rgbColorSpace,
                       bitmapInfo: bitmapInfo,
                       provider: providerRef,
                       decode: nil,
                       shouldInterpolate: true,
                       intent: .defaultIntent)
    }

    private func pixel(for values: [Double]) -> Pixel {
        let maxValue = values.max()!
        let maxIndex = Double((values.index(of: maxValue) ?? 0) + colorIndexOffset)
        let colorValues = ColorHelper.pixelValues.prefix(values.count)
        if maxIndex < 0 {
            return colorValues.last!.color
        }
        return colorValues[Int(maxIndex)].color
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        guard let imageBuffer = imageBuffer else {
            return
        }
        context?.draw(imageBuffer, in: rect)
    }
}
