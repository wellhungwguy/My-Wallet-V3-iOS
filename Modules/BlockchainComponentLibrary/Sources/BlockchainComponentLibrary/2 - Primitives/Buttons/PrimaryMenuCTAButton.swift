// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PrimaryMenuCTAButton from the Figma Component Library.
///
///
/// # Usage:
///
/// `PrimaryMenuCTAButton(title: "Tap me", subtitle: "Do something") { print("button did tap") }`
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Buttons](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=3%3A367)
public struct PrimaryMenuCTAButton<LeadingView: View>: View {

    private let title: String
    private let subtitle: String
    private let isLoading: Bool
    private let leadingView: () -> LeadingView
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String,
        isLoading: Bool = false,
        @ViewBuilder leadingView: @escaping () -> LeadingView,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isLoading = isLoading
        self.leadingView = leadingView
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Spacing.padding2) {
                leadingView()
                    .frame(width: 24, height: 24)
                    .padding(.leading, Spacing.padding2)
                VStack(alignment: .leading,
                       spacing: 3) {
                    Text(title)
                    Text(subtitle)
                        .typography(.paragraph1)
                }
                Spacer()
            }
        }
        .buttonStyle(
            PillButtonStyle(
                isLoading: isLoading,
                isEnabled: true,
                size: .large,
                colorCombination: .fabCTAButtonColorCombination
            )
        )
    }
}

extension PrimaryMenuCTAButton where LeadingView == EmptyView {

    /// Create a primary button without a leading view.
    /// - Parameters:
    ///   - title: Centered title label
    ///   - isLoading: True to display a loading indicator instead of the label.
    ///   - action: Action to be triggered on tap
    public init(
        title: String,
        subtitle: String,
        isLoading: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            isLoading: isLoading,
            leadingView: { EmptyView() },
            action: action
        )
    }
}

extension PillButtonStyle.ColorCombination {
    public static let fabCTAButtonColorCombination = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.grey900,
                dark: .palette.grey900
            ),
            background: .palette.grey000,
            border: .palette.white
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .palette.grey900,
            background: .palette.grey000,
            border: .palette.white
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: Color(
                light: .palette.grey900.opacity(0.7),
                dark: .palette.grey900.opacity(0.4)
            ),
            background: Color(
                light: .palette.grey000,
                dark: .palette.grey000
            ),
            border: Color(
                light: .clear,
                dark: .clear
            )
        ),
        progressViewRail: .palette.grey000.opacity(0.8),
        progressViewTrack: .palette.grey000.opacity(0.25)
    )
}

struct PrimaryMenuCTAButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PrimaryMenuCTAButton(title: "Enabled",
                                 subtitle: "Enabled",
                                 action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            PrimaryMenuCTAButton(
                title: "With Icon",
                subtitle: "With icon",
                leadingView: {
                    Icon.placeholder
                },
                action: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("With Icon")

            PrimaryMenuCTAButton(title: "Disabled",
                                 subtitle: "Disabled",
                                 action: {})
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")

            PrimaryMenuCTAButton(title: "Loading",
                                 subtitle: "Loading",
                                 isLoading: true, action: {})
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Loading")
        }
        .padding()
    }
}
