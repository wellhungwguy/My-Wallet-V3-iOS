// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

final class MockErrorRecorder: ErrorRecording {
    func error(_ error: Error) {}
}
