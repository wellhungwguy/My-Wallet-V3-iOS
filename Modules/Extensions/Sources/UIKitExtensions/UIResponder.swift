#if canImport(UIKit)
import UIKit

extension UIResponder {

    public var responderViewController: UIViewController? {
        if let vc = self as? UIViewController {
            return vc
        } else if let nextResponder = next {
            return nextResponder.responderViewController
        } else {
            return nil
        }
    }
}
#endif
