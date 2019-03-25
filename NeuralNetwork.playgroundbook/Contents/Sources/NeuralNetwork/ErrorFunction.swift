//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation

public struct ErrorFunction {
    let function: (_ output: Mat, _ expectedOuput: Mat) -> Mat
    let functionDerivative: (_ output: Mat, _ expectedOuput: Mat) -> Mat
}

public extension ErrorFunction {
    static var squared: ErrorFunction {
        return ErrorFunction(function: { (output, expectedOutput) -> Mat in
            0.5 * (output - expectedOutput).pow(2)
        }, functionDerivative: { (output, expectedOutput) -> Mat in
            output - expectedOutput
        })
    }
}
