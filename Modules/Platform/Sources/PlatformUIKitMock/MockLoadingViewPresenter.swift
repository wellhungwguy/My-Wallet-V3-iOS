// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit
import UIKit

public final class MockLoadingViewPresenter: LoadingViewPresenting {

    public struct RecordedInvocations {
        public var show: [(style: LoadingViewPresenter.LoadingViewStyle, text: String?, superView: UIView?)] = []
        public var hide: [Void] = []
    }

    public private(set) var recordedInvocations = RecordedInvocations()

    public var isEnabled: Bool = true
    public var isVisible: Bool = false

    public func hide() {
        isVisible = false
        recordedInvocations.hide.append(())
    }

    public func showCircular(in superview: UIView?, with text: String?) {
        show(with: .circle, text: text, in: superview)
    }

    public func showCircular(with text: String?) {
        showCircular(in: nil, with: text)
    }

    public func showCircular() {
        showCircular(in: nil, with: nil)
    }

    public func show(with style: LoadingViewPresenter.LoadingViewStyle, text: String?) {
        show(with: style, text: text, in: nil)
    }

    public func show(in superview: UIView?, with text: String?) {
        show(with: .activityIndicator, text: text, in: superview)
    }

    public func show(with text: String?) {
        show(in: nil, with: text)
    }

    private func show(with style: LoadingViewPresenter.LoadingViewStyle, text: String?, in view: UIView?) {
        isVisible = true
        recordedInvocations.show.append((style, text, view))
    }
}
