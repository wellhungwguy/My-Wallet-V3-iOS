// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

public typealias NavigationLinkProviderList = [String: [NavigationLinkProvider]]

public struct NavigationLinkProvider: Hashable {

    public static func == (lhs: NavigationLinkProvider, rhs: NavigationLinkProvider) -> Bool {
        lhs.title == rhs.title
    }

    private let view: AnyView
    private let title: String

    public init(view: some View, title: String? = nil) {
        self.title = title ?? String(describing: type(of: view))
        self.view = AnyView(view.primaryNavigation(title: self.title))
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    @ViewBuilder
    public static func sections(for data: NavigationLinkProviderList) -> some View {
        ForEach(Array(data.keys.sorted()), id: \.self) { key in
            if let dict = data[key] {
                Section(header: SectionHeader(title: key)) {
                    links(for: dict)
                }
            }
        }
    }

    @ViewBuilder
    public static func links(for dict: [NavigationLinkProvider]) -> some View {
        ForEach(dict, id: \.self) { linkable in
            NavigationLinkView(
                title: linkable.title,
                view: linkable.view
            )
        }
    }
}

private struct NavigationLinkView<LinkableView: View>: View {
    @State var isActive = false

    let title: String
    let view: LinkableView

    var body: some View {
        VStack(spacing: 0) {
            PrimaryRow(title: title) { isActive = true }
                .background(
                    PrimaryNavigationLink(
                        destination: ZStack { view }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.semantic.background.ignoresSafeArea()),
                        isActive: $isActive,
                        label: { EmptyView() }
                    )
                )

            PrimaryDivider()
        }
        .listRowInsets(EdgeInsets())
    }
}
