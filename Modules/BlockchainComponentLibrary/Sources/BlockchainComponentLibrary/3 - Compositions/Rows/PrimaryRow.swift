// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// PrimaryRow from the Figma Component Library.
///
///
/// # Usage:
///
/// Only title is mandatory to create a Row. Rest of parameters are optional. When no trailing accessory view es provided, a chevron view is shown
/// ```
/// PrimaryRow(
///     title: "Link a Bank",
///     subtitle: "Instant Connection",
///     description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
///     tags: [
///         TagView(text: "Fastest", variant: .success),
///         TagView(text: "Warning Alert", variant: .warning)
///     ],
///     isSelected: $selection {
///         Icon.bank
///             .fixedSize()
///     } trailing: {
///         Switch()
///     }
///
/// ```
///
/// - Version: 1.0.1
///
/// # Figma
///
///  [Table Rows](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A11163)
public struct PrimaryRow<Leading: View, Trailing: View>: View {

    private let title: String
    private let caption: String?
    private let subtitle: String?
    private let description: String?
    private let tags: [TagView]
    private let leading: Leading
    private let trailing: Trailing

    private let action: (() -> Void)?
    private let highlight: Bool
    private let isSelectable: Bool

    /// Create a default row with the given data.
    ///
    /// Only Title is mandatory, rest of the parameters are optional and the row will form itself depending on the given data
    /// - Parameters:
    ///   - title: Title of the row
    ///   - caption: Optional text shown on top of the title
    ///   - subtitle: Optional subtitle on the main vertical content view
    ///   - description: Optional description text on the main vertical content view
    ///   - tags: Optional array of tags object. They show up on the bottom part of the main vertical content view, and align themself horizontally
    ///   - isSelected: Binding for the selection state
    ///   - leading: Optional view on the leading part of the row.
    ///   - trailing: Optional view on the trailing part of the row. If no view is provided, a chevron icon is added automatically.
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [TagView] = [],
        highlight: Bool = true,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.caption = caption
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.highlight = highlight
        isSelectable = action != nil
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
    }

    public var body: some View {
        if isSelectable {
            Button {
                action?()
            } label: {
                horizontalContent
            }
            .buttonStyle(
                PrimaryRowStyle(isSelectable: highlight && isSelectable)
            )
        } else {
            horizontalContent
                .background(Color.semantic.background)
                .accessibilityElement(children: .combine)
        }
    }

    var horizontalContent: some View {
        HStack(alignment: .customRowVerticalAlignment, spacing: 0) {
            leading
                .padding(.trailing, Spacing.padding2)
            mainContent
                .padding(.vertical, Spacing.padding2)
            Spacer()
            trailing
                .padding(.leading, Spacing.padding2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.padding3)
    }

    @ViewBuilder var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                if let caption = caption {
                    Text(caption)
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                }

                Text(title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .typography(.paragraph1)
                        .foregroundColor(
                            Color(
                                light: .palette.grey600,
                                dark: .palette.dark200
                            )
                        )
                }
            }
            .alignmentGuide(.customRowVerticalAlignment) {
                $0[VerticalAlignment.center]
            }
            if let description = description {
                Text(description)
                    .typography(.caption1)
                    .foregroundColor(
                        Color(
                            light: .palette.grey600,
                            dark: .palette.dark200
                        )
                    )
                    .padding(.top, 11)
            }
            if !tags.isEmpty {
                HStack {
                    ForEach(tags, id: \.self) { view in
                        view
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

private struct PrimaryRowStyle: ButtonStyle {

    let isSelectable: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed && isSelectable ? Color.semantic.light : Color.semantic.background)
    }
}

extension PrimaryRow where Leading == EmptyView {

    /// Initialize a PrimaryRow with no leading view
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    ///   - trailing: Optional view displayed at the trailing edge.
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [TagView] = [],
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: { EmptyView() },
            trailing: trailing,
            action: action
        )
    }
}

extension PrimaryRow where Trailing == ChevronRight {

    /// Initialize a PrimaryRow with default trailing chevron
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    ///   - leading: View displayed at the leading edge.
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [TagView] = [],
        @ViewBuilder leading: () -> Leading,
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: leading,
            trailing: { ChevronRight() },
            action: action
        )
    }
}

extension PrimaryRow where Leading == EmptyView, Trailing == ChevronRight {

    /// Initialize a PrimaryRow with no leading view, and default trailing chevron
    /// - Parameters:
    ///   - title: Leading title text
    ///   - subtitle: Optional leading subtitle text
    ///   - description: Optional leading description
    ///   - tags: Optional TagViews displayed at the bottom of the row.
    ///   - isSelected: Binding for the selection state
    public init(
        title: String,
        caption: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        tags: [TagView] = [],
        action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            caption: caption,
            subtitle: subtitle,
            description: description,
            tags: tags,
            leading: { EmptyView() },
            trailing: { ChevronRight() },
            action: action
        )
    }
}

/// View containing Icon.chevronRight, colored for table rows.
public struct ChevronRight: View {
    public var body: some View {
        Icon.chevronRight
            .fixedSize()
            .accentColor(
                Color(
                    light: .palette.grey400,
                    dark: .palette.grey400
                )
            )
            .flipsForRightToLeftLayoutDirection(true)
    }
}

extension VerticalAlignment {
    struct CustomRowVerticalAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let customRowVerticalAlignment = VerticalAlignment(CustomRowVerticalAlignment.self)
}

// swiftlint:disable line_length
struct PrimaryRow_Previews: PreviewProvider {

    static var previews: some View {
        PreviewController(selection: 0)
            .previewLayout(.sizeThatFits)
    }

    struct PreviewController: View {

        @State var selection: Int

        init(selection: Int) {
            _selection = State(initialValue: selection)
        }

        var body: some View {
            Group {
                PrimaryRow(
                    title: "Trading",
                    subtitle: "Buy & Sell",
                    action: {
                        selection = 0
                    }
                )
                PrimaryRow(
                    title: "Email Address",
                    subtitle: "satoshi@blockchain.com",
                    tags: [TagView(text: "Confirmed", variant: .success)],
                    action: {
                        selection = 1
                    }
                )
                PrimaryRow(
                    title: "From: BTC Trading Account",
                    subtitle: "To: 0x093871209487120934812027675",
                    action: {
                        selection = 2
                    }
                )
            }
            .frame(width: 375)
            Group {
                PrimaryRow(
                    title: "Link a Bank",
                    subtitle: "Instant Connection",
                    description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                    tags: [
                        TagView(text: "Fastest", variant: .success),
                        TagView(text: "Warning Alert", variant: .warning)
                    ],
                    action: {
                        selection = 3
                    }
                )
                PrimaryRow(
                    title: "Cloud Backup",
                    subtitle: "Buy & Sell",
                    trailing: {
                        Switch()
                    }
                )
                PrimaryRow(
                    title: "Features and Limits",
                    action: {
                        selection = 5
                    }
                )
            }
            .frame(width: 375)
            Group {
                PrimaryRow(
                    title: "Back Up Your Wallet",
                    subtitle: "Step 1",
                    leading: {
                        Icon.wallet
                            .fixedSize()
                            .accentColor(.semantic.dark)
                    },
                    action: {
                        selection = 6
                    }
                )
                PrimaryRow(
                    title: "Gold Level",
                    subtitle: "Higher Trading Limits",
                    tags: [TagView(text: "Approved", variant: .success)],
                    leading: {
                        Icon.apple
                            .fixedSize()
                            .accentColor(.semantic.orangeBG)
                    },
                    action: {
                        selection = 7
                    }
                )
                PrimaryRow(
                    title: "Trade",
                    subtitle: "BTC -> ETH",
                    leading: {
                        Icon.trade
                            .fixedSize()
                            .accentColor(.semantic.success)
                    },
                    action: {
                        selection = 8
                    }
                )
                PrimaryRow(
                    title: "Link a Bank",
                    subtitle: "Instant Connection",
                    description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                    tags: [
                        TagView(text: "Fastest", variant: .success),
                        TagView(text: "Warning Alert", variant: .warning)
                    ],
                    leading: {
                        Icon.bank
                            .fixedSize()
                            .accentColor(.semantic.primary)
                    },
                    action: {
                        selection = 9
                    }
                )
                PrimaryRow(
                    title: "Features and Limits",
                    leading: {
                        Icon.blockchain
                            .fixedSize()
                            .accentColor(.semantic.primary)
                    },
                    action: {
                        selection = 10
                    }
                )
            }
            .frame(width: 375)
        }
    }

    struct Switch: View {
        @State var isOn: Bool = false

        var body: some View {
            PrimarySwitch(
                variant: .green,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}
