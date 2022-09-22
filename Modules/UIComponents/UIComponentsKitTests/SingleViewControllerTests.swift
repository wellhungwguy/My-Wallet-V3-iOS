// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SnapshotTesting
import UIComponentsKit
import UIKit
import XCTest

final class SingleChildViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSingle() {
        let controller = UIViewController()
        controller.view.backgroundColor = .green
        controller.title = "Initial"
        controller.tabBarItem = UITabBarItem(title: "Initial", image: nil, selectedImage: nil)

        let container = UITabBarController()
        container.viewControllers = [
            UINavigationController(
                rootViewController: SingleChildViewController(child: controller)
            )
        ]

        assertSnapshot(matching: container, as: .image)

        controller.title = "Updated"
        controller.tabBarItem = UITabBarItem(title: "Updated", image: nil, selectedImage: nil)

        assertSnapshot(matching: container, as: .image)
    }
}
