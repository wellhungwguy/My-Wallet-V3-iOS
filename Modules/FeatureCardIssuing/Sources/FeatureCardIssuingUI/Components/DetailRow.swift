// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Foundation
import SwiftUI

struct DetailsRow<Leading: View, Trailing: View>: View {

    enum TextModel {
        case title(String)
        case caption(String)
        case subtitle(String)
        case custom(String, Color, Typography)
        case empty

        var text: String {
            switch self {
            case .title(let text),
                 .caption(let text),
                 .subtitle(let text),
                 .custom(let text, _, _):
                return text
            case .empty:
                return ""
            }
        }

        var color: Color {
            switch self {
            case .title:
                return .semantic.title
            case .subtitle, .caption:
                return .semantic.muted
            case .custom(_, let color, _):
                return color
            case .empty:
                return .clear
            }
        }

        var typography: Typography {
            switch self {
            case .title:
                return .body2
            case .subtitle:
                return .paragraph1
            case .caption:
                return .caption1
            case .custom(_, _, let typography):
                return typography
            case .empty:
                return .body2
            }
        }
    }

    let leadingTitle: TextModel
    let trailingTitle: TextModel
    let leadingSubtitle: TextModel
    let trailingSubtitle: TextModel
    let leading: () -> Leading
    let trailing: () -> Trailing
    let action: () -> Void

    init(
        leadingTitle: TextModel = .empty,
        trailingTitle: TextModel = .empty,
        leadingSubtitle: TextModel = .empty,
        trailingSubtitle: TextModel = .empty,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.leadingSubtitle = leadingSubtitle
        self.trailingSubtitle = trailingSubtitle
        self.leading = leading
        self.trailing = trailing
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.padding2) {
            leading()
            HStack(alignment: .top, spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    if !leadingTitle.text.isEmpty {
                        HStack(alignment: .center) {
                            Text(leadingTitle.text)
                                .typography(leadingTitle.typography)
                                .foregroundColor(leadingTitle.color)
                        }
                    }
                    if !leadingSubtitle.text.isEmpty {
                        HStack(alignment: .center) {
                            Text(leadingSubtitle.text)
                                .typography(leadingSubtitle.typography)
                                .foregroundColor(leadingSubtitle.color)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    if !trailingTitle.text.isEmpty {
                        Text(trailingTitle.text)
                            .typography(trailingTitle.typography)
                            .foregroundColor(trailingTitle.color)
                    }
                    if !trailingSubtitle.text.isEmpty {
                        Text(trailingSubtitle.text)
                            .typography(trailingSubtitle.typography)
                            .foregroundColor(trailingSubtitle.color)
                    }
                }
            }

            trailing()
        }
        .padding(.horizontal, Spacing.padding3)
        .padding(.vertical, Spacing.padding2)
        .background(Color.semantic.background)
        .onTapGesture {
            action()
        }
    }
}

extension DetailsRow {

    init(
        leadingTitle: String = "",
        trailingTitle: String = "",
        leadingSubtitle: String = "",
        trailingSubtitle: String = "",
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = .title(leadingTitle)
        self.trailingTitle = .title(trailingTitle)
        self.leadingSubtitle = .caption(leadingSubtitle)
        self.trailingSubtitle = .subtitle(trailingSubtitle)
        self.leading = leading
        self.trailing = trailing
        self.action = action
    }
}

extension DetailsRow where Leading == EmptyView {

    init(
        leadingTitle: TextModel = .empty,
        trailingTitle: TextModel = .empty,
        leadingSubtitle: TextModel = .empty,
        trailingSubtitle: TextModel = .empty,
        @ViewBuilder trailing: @escaping () -> Trailing,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.leadingSubtitle = leadingSubtitle
        self.trailingSubtitle = trailingSubtitle
        self.leading = { EmptyView() }
        self.trailing = trailing
        self.action = action
    }

    init(
        leadingTitle: String = "",
        trailingTitle: String = "",
        leadingSubtitle: String = "",
        trailingSubtitle: String = "",
        @ViewBuilder trailing: @escaping () -> Trailing,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = .title(leadingTitle)
        self.trailingTitle = .title(trailingTitle)
        self.leadingSubtitle = .caption(leadingSubtitle)
        self.trailingSubtitle = .subtitle(trailingSubtitle)
        self.leading = { EmptyView() }
        self.trailing = trailing
        self.action = action
    }
}

extension DetailsRow where Trailing == EmptyView {

    init(
        leadingTitle: TextModel = .empty,
        trailingTitle: TextModel = .empty,
        leadingSubtitle: TextModel = .empty,
        trailingSubtitle: TextModel = .empty,
        @ViewBuilder leading: @escaping () -> Leading,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.leadingSubtitle = leadingSubtitle
        self.trailingSubtitle = trailingSubtitle
        self.leading = leading
        self.trailing = { EmptyView() }
        self.action = action
    }

    init(
        leadingTitle: String = "",
        trailingTitle: String = "",
        leadingSubtitle: String = "",
        trailingSubtitle: String = "",
        @ViewBuilder leading: @escaping () -> Leading,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = .title(leadingTitle)
        self.trailingTitle = .title(trailingTitle)
        self.leadingSubtitle = .caption(leadingSubtitle)
        self.trailingSubtitle = .subtitle(trailingSubtitle)
        self.leading = leading
        self.trailing = { EmptyView() }
        self.action = action
    }
}

extension DetailsRow where Trailing == EmptyView, Leading == EmptyView {

    init(
        leadingTitle: TextModel = .empty,
        trailingTitle: TextModel = .empty,
        leadingSubtitle: TextModel = .empty,
        trailingSubtitle: TextModel = .empty,
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = leadingTitle
        self.trailingTitle = trailingTitle
        self.leadingSubtitle = leadingSubtitle
        self.trailingSubtitle = trailingSubtitle
        self.leading = { EmptyView() }
        self.trailing = { EmptyView() }
        self.action = action
    }

    init(
        leadingTitle: String = "",
        trailingTitle: String = "",
        leadingSubtitle: String = "",
        trailingSubtitle: String = "",
        action: @escaping () -> Void = {}
    ) {
        self.leadingTitle = .title(leadingTitle)
        self.trailingTitle = .title(trailingTitle)
        self.leadingSubtitle = .caption(leadingSubtitle)
        self.trailingSubtitle = .subtitle(trailingSubtitle)
        self.leading = { EmptyView() }
        self.trailing = { EmptyView() }
        self.action = action
    }
}
