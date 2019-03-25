//
//  Copyright © 2019 Leonard Thomas. All rights reserved.
//

import Foundation
import UIKit

public protocol LiveViewable {}

extension UIView: LiveViewable {}
extension UIViewController: LiveViewable {}

public enum AssesmentStatus {
    case fail(hints: [String], solution: String?)
    case pass(message: String)
}

public class PlaygroundPage {
    public static var current = PlaygroundPage()
    public var assessmentStatus: AssesmentStatus?
    public var liveView: LiveViewable!
    public var needsIndefiniteExecution = true
    public func finishExecution() {}
}

public protocol PlaygroundRemoteLiveViewProxyDelegate {}

public class PlaygroundRemoteLiveViewProxy {
    public var delegate: Any?
    public func send(_: PlaygroundValue) {}
}

public enum PlaygroundValue {
    case array([PlaygroundValue])
    case integer(Int)
    case string(String)
    case data(Data)
    case dictionary([String: PlaygroundValue])
    case boolean(Bool)
    case floatingPoint(Float)
}

public class PlaygroundKeyValueStore {
    public static var current = PlaygroundKeyValueStore()
    public subscript(_: String) -> PlaygroundValue? {
        get {
            return nil
        }
        set {}
    }
}

public protocol PlaygroundLiveViewMessageHandler {
    func send(_ message: PlaygroundValue)
    func receive(_ message: PlaygroundValue)
    func liveViewMessageConnectionClosed()
}

extension PlaygroundLiveViewMessageHandler {
    public func send(_: PlaygroundValue) {}
}

public protocol PlaygroundLiveViewSafeAreaContainer {
    var liveViewSafeAreaGuide: UILayoutGuide { get }
}

public extension PlaygroundLiveViewSafeAreaContainer {
    var liveViewSafeAreaGuide: UILayoutGuide {
        return UILayoutGuide()
    }
}
