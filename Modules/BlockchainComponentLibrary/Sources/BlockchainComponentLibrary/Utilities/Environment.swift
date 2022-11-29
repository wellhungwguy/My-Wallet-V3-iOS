import Foundation
import SwiftUI

extension EnvironmentValues {

    public var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
