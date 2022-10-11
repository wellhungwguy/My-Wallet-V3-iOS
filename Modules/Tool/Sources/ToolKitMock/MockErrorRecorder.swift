// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

class MockErrorRecorder: ErrorRecording {
    func error(_ error: Error) {}
}
