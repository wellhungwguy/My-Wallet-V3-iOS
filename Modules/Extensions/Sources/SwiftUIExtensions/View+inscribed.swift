// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {

    /// Inscribe `content` with the aspect ratio of 1 (square) inside of the incircle of the bounding
    /// box. This ensures `content` will never exceed the bounds of the incircle. The content will be
    /// overlaid.
    ///
    /// - Parameter content: The contents to display inside the inscribed incircle bounds
    /// - Returns: The current view with `contents` overlaid
    @ViewBuilder
    public func inscribed<Content>(
        _ content: @autoclosure @escaping () -> Content
    ) -> some View where Content: View {
        inscribed(content)
    }

    /// Inscribe `content` with the aspect ratio of 1 (square) inside the an incircle of the bounding
    /// box. This ensures `content` will never exceed the bounds of the incircle. The content will be
    /// overlaid.
    ///
    /// - Parameter aspectRatio: The aspect ratio which should be applied to `content`
    /// - Parameter content: The contents to display inside of the inscribed incircle bounds
    /// - Returns: The current view with `contents` overlaid
    @ViewBuilder
    public func inscribed<Content>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        inscribed(aspectRatio: 1, content)
    }

    /// Inscribe `content` with the aspect ratio `aspectRatio` inside the incircle of the bounding
    /// box. This ensures `content` will never exceed the bounds of the incircle. The content will be
    /// overlaid.
    ///
    /// - Parameter aspectRatio: The aspect ratio which should be applied to `content`
    /// - Parameter content: The contents to display inside of the inscribed incircle bounds
    /// - Returns: The current view with `contents` overlaid
    @ViewBuilder
    public func inscribed<Content>(
        aspectRatio: CGFloat,
        _ content: @autoclosure @escaping () -> Content
    ) -> some View where Content: View {
        inscribed(aspectRatio: aspectRatio, content)
    }

    /// Inscribe `content` with the aspect ratio `aspectRatio` inside the incircle of the bounding
    /// box. This ensures `content` will never exceed the bounds of the incircle. The content will be
    /// overlaid.
    ///
    /// - Parameter aspectRatio: The aspect ratio which should be applied to `content`
    /// - Parameter content: The contents to display inside of the inscribed incircle bounds
    /// - Returns: The current view with `contents` overlaid
    @ViewBuilder
    public func inscribed<Content>(
        aspectRatio: CGFloat,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        ZStack {
            if aspectRatio.isNormal {
                withGeometry(\.size) { view, size in
                    let theta = atan2(aspectRatio, 1)
                    let size = CGSize(
                        width: sin(theta) * size.width,
                        height: cos(theta) * size.height
                    )
                    view.overlay(
                        content()
                            .frame(width: size.width, height: size.height),
                        alignment: .center
                    )
                }
            } else {
                self
            }
        }
    }
}

struct Inscribed_Previews: PreviewProvider {

    static var previews: some View {
        Circle()
            .frame(width: 100, height: 100)
            .foregroundColor(Color.red.opacity(0.15))
            .inscribed(Text("Hello World!"))
    }
}
