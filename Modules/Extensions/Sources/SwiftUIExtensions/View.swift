#if canImport(UIKit)

import SwiftUI
import UIKit

extension View {

    public func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
