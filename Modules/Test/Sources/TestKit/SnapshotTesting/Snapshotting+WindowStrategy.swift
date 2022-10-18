// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(UIKit)

import SnapshotTesting
import SwiftUI
import UIKit

extension XCTestCase {

    public func assert(
        _ view: some View,
        on config: ViewImageConfig,
        renderInWindow: Bool = false,
        testName: String = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if renderInWindow {
            let e = expectation(description: "wait for window to fully render")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: e.fulfill)
            wait(for: [e], timeout: 1)
        }
        assertSnapshot(
            matching: view,
            as: renderInWindow ? .windowedImage(on: config) : .image(on: config),
            file: file,
            testName: testName,
            line: line
        )
    }
}

extension Snapshotting where Value: UIViewController, Format == UIImage {

    static var windowedImage: Snapshotting {
        windowedImage(on: nil)
    }

    /// Snapshots a `ViewController` by embedding it within a `UIWindow`. Animations are disabled while snapshotting.
    /// - Parameters:
    ///   - config: You can specify a config matching a specific device. E.g. `.iPhoneSE`.
    ///   - precision: A value between 0.0 and 1.0 representing how close the images need to look alike for the test to pass. Defaults to 0.99 to let a 1% difference through to avoid false failures.
    ///   - scale: The scale of the image. This should match the screen of the config provided. The configic has traits that don't override scale, so this is defaulted to Retina (2x).
    /// - Returns: A snapshotting strategy that can be used in a Snapshot Test's assertion.
    static func windowedImage(
        on config: ViewImageConfig?,
        precision: Float = 0.99,
        scale: CGFloat = 2
    ) -> Snapshotting {
        SimplySnapshotting.image(precision: precision, scale: scale).asyncPullback { vc in
            Async<UIImage> { callback in
                UIView.setAnimationsEnabled(false)
                let window = UIApplication.shared.windows.first!
                window.rootViewController = vc
                if let config {
                    window.frame = CGRect(origin: .zero, size: config.size ?? .zero)
                }
                DispatchQueue.main.async {
                    let format = UIGraphicsImageRendererFormat()
                    format.scale = scale

                    let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
                        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                    }
                    callback(image)
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
    }
}

extension Snapshotting where Value: View, Format == UIImage {

    static var windowedImage: Snapshotting {
        windowedImage(on: nil)
    }

    /// Snapshots a `SwiftUI.View`
    /// - Parameters:
    ///   - config: You can specify a config matching a specific device. E.g. `.iPhoneSE`.
    ///   - precision: A value between 0.0 and 1.0 representing how close the images need to look alike for the test to pass. Defaults to 0.99 to let a 1% difference through to avoid false failures.
    ///   - scale: The scale of the image. This should match the screen of the config provided. The configic has traits that don't override scale, so this is defaulted to Retina (2x).
    /// - Returns: A snapshotting strategy that can be used in a Snapshot Test's assertion.
    static func image(on config: ViewImageConfig, precision: Float = 0.99, scale: CGFloat = 2) -> Snapshotting {
        // defining traits like this fixes an issue with the defaut implementation not accounting for consistent scale of config
        let traits = UITraitCollection(traitsFrom: [
            .init(traitsFrom: [config.traits]),
            .init(displayScale: scale)
        ])
        return Snapshotting<UIViewController, UIImage>
            .image(
                on: config,
                precision: precision,
                size: nil,
                traits: traits
            )
            .pullback { view in
                UIHostingController(rootView: view)
            }
    }

    /// Snapshots a `SwiftUI.View` by embedding it within a `UIWindow`. Animations are disabled while snapshotting.
    /// - Parameters:
    ///   - config: You can specify a config matching a specific device. E.g. `.iPhoneSE`.
    ///   - precision: A value between 0.0 and 1.0 representing how close the images need to look alike for the test to pass. Defaults to 0.99 to let a 1% difference through to avoid false failures.
    /// - Returns: A snapshotting strategy that can be used in a Snapshot Test's assertion.
    static func windowedImage(on config: ViewImageConfig?, precision: Float = 0.99) -> Snapshotting {
        Snapshotting<UIViewController, UIImage>.windowedImage(on: config, precision: precision).pullback { view in
            UIHostingController(rootView: view)
        }
    }
}

#endif
