// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import SwiftUI
import UnifiedActivityDomain

public struct ActivityRow: View {
    let activityEntry: ActivityEntry

    @Binding private var isSelected: Bool
    private let isSelectable: Bool
    let action: () -> Void

    /// Create a Activity Row with the given data.
    ///
    ///
    /// - Parameters:
    ///   - activityEntry: The activity entry used to configure the view
    ///   - isSelected: Binding for the selection state
    ///   - leading: View on the leading side of the row.
    ///
    public init(
        activityEntry: ActivityEntry,
        isSelected: Binding<Bool>? = nil,
        action: @escaping () -> Void = {}
    ) {
        self.activityEntry = activityEntry
        self.isSelectable = isSelected != nil
        _isSelected = isSelected ?? .constant(false)
        self.action = action
    }

    public var body: some View {
        Button {
            isSelected = true
            action()
        } label: {
            compositionView(with: activityEntry.item)
        }
        .buttonStyle(SimpleBalanceRowStyle(isSelectable: isSelectable))
    }


    @ViewBuilder
    @MainActor
    func compositionView(with item: ActivityItem.CompositionView) -> some View {
        HStack(alignment: .center, spacing: 16) {
            imageView(with: item.leadingImage)

            VStack(alignment: .leading, spacing: 3) {
                ForEach(item.leading) {
                    view(for: $0)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                ForEach(item.trailing) {
                    view(for: $0)
                }
            }
            imageView(with: item.trailingImage)
        }
    }

    @ViewBuilder
    @MainActor
    private func imageView(with image: ImageType?) -> some View {
        if #available(iOS 15.0, *) {
            switch image {
            case .smallTag(let smallTagImage):
                ZStack(alignment: .bottomTrailing) {
                    AsyncMedia(url: URL(string: smallTagImage.main ?? ""), placeholder: { EmptyView() })
                        .frame(width: 25, height: 25)
                        .background(Color.WalletSemantic.light, in: Circle())

                    AsyncMedia(url: URL(string: smallTagImage.tag ?? ""), placeholder: { EmptyView() })
                        .frame(width: 12, height: 12)
                }
            case .none:
                EmptyView()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    @ViewBuilder
    private func view(for item: LeafItemType) -> some View {
        switch item {
        case .text(let textElement):
            Group {
                Text(textElement.value)
                    .lineLimit(1)
                    .typography(textElement.style.typography.typography())
                    .foregroundColor(textElement.style.color.uiColor())
            }
        case .button(let buttonElement):
            EmptyView()
        case .badge(let badgeElement):
            TagView(
                text: badgeElement.value,
                variant: badgeElement.style.variant()
            )
        }
    }
}

private struct SimpleBalanceRowStyle: ButtonStyle {
    let isSelectable: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
            .padding(.vertical, Spacing.padding2)
            .background(configuration.isPressed && isSelectable ? Color.semantic.light : Color.semantic.background)
    }
}

extension LeafItemType: Identifiable {
    public var id: String {
        switch self {
        case .badge(let item):
            return item.id
        case .text(let item):
            return item.id
        case .button(let item):
            return item.id
        }
    }
}

extension ActivityItem.Text: Identifiable {
    public var id: String {
        value
    }
}

extension ActivityItem.Badge: Identifiable {
    public var id: String {
        value
    }
}

extension ActivityItem.Button: Identifiable {
    public var id: String {
        text
    }
}
