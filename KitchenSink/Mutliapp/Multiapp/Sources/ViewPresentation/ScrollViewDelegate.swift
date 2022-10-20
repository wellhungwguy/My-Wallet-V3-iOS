//
//  Created by Dimitris Chatzieleftheriou on 15/09/2022.
//

import Foundation
import UIKit

class ScrollViewDelegate: NSObject, ObservableObject, UIScrollViewDelegate {

    var didScroll: (UIScrollView) -> Void = { _ in }
    var didEndDragging: (UIScrollView) -> Void = { _ in }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDragging(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("target content offset ->", targetContentOffset.pointee.y)
    }
}
