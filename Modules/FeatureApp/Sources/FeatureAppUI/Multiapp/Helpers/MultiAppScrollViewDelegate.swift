// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

class MultiAppScrollViewDelegate: NSObject, ObservableObject, UIScrollViewDelegate {

    var didScroll: (UIScrollView) -> Void = { _ in }
    var didEndDragging: (UIScrollView) -> Void = { _ in }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            didEndDragging(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDragging(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("target content offset ->", targetContentOffset.pointee.y)
    }
}
