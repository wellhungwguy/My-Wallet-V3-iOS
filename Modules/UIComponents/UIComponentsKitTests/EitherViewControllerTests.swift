// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import ToolKit
import UIComponentsKit
import UIKit
import XCTest

final class EitherViewControllerTests: XCTestCase {
    class Green: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .green
        }
    }

    class Blue: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .blue
        }
    }

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testEither() {
        let either: Either<Green, Blue> = .left(Green())
        let controller = EitherViewController(child: either)

        assertSnapshot(matching: controller, as: .image)

        controller.child = .right(Blue())

        assertSnapshot(matching: controller, as: .image)
    }
}
