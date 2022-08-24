// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension NSObject {

    /// Returns the object's class name. Particularly useful in saving raw strings usage in code.
    public var objectName: String {
        String(describing: type(of: self))
    }

    /// Returns the object's class name. Particularly useful in saving raw strings usage in code.
    public class var objectName: String {
        String(describing: self)
    }
}
