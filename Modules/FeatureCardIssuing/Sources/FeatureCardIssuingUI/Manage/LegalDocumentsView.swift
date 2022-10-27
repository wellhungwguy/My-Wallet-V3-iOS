// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import SwiftUI

struct LegalDocumentsView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Manage.LegalDocuments

    let store: Store<CardManagementState, CardManagementAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                SectionHeader(title: L10n.statements, variant: .large)
                VStack {
                    ForEach(
                        viewStore.state.statements.indexed(),
                        id: \.element.statementId
                    ) { index, element in
                        let isLast = index == viewStore.state.statements.indices.last
                        DocumentRow(
                            title: element.displayDate,
                            isFirst: index == viewStore.state.statements.indices.first,
                            isLast: isLast
                        ) {
                            viewStore.send(.fetchStatementUrl(element))
                        }
                        if !isLast {
                            PrimaryDivider()
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.padding1)
                        .stroke(Color.semantic.light, lineWidth: 1)
                )
                .padding(.horizontal, Spacing.padding2)
                SectionHeader(title: L10n.legalDocuments, variant: .large)
                VStack {
                    ForEach(
                        viewStore.state.legalItems.indexed(),
                        id: \.element.name
                    ) { index, element in
                        let isLast = index == viewStore.state.legalItems.indices.last
                        DocumentRow(
                            title: element.displayName,
                            isFirst: index == viewStore.state.legalItems.indices.first,
                            isLast: isLast
                        ) {
                            UIApplication.shared.open(element.url)
                        }
                        if !isLast {
                            PrimaryDivider()
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.padding1)
                        .stroke(Color.semantic.light, lineWidth: 1)
                )
                .padding(.horizontal, Spacing.padding2)
            }
            .navigationTitle(L10n.title)
            .onAppear {
                viewStore.send(.getDocuments)
            }
        }
    }
}

struct DocumentRow: View {

    let title: String
    let isFirst: Bool
    let isLast: Bool
    let action: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            Text(title).typography(.paragraph2).foregroundColor(.semantic.title)
            Spacer()
            Icon.newWindow.color(.semantic.muted).frame(width: 24)
        }
        .padding(.top, isFirst ? Spacing.padding2 : Spacing.padding1)
        .padding(.bottom, isLast ? Spacing.padding2 : Spacing.padding1)
        .padding(.horizontal, Spacing.padding2)
        .onTapGesture {
            action?()
        }
    }
}

extension Statement {

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M yy"
        guard let date = formatter.date(from: "\(month) \(year)") else {
            return ""
        }
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

#if DEBUG
struct LegalDocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        LegalDocumentsView(
            store: .init(
                initialState: CardManagementState(
                    card: nil,
                    isLocked: false,
                    cardHelperUrl: nil,
                    error: nil,
                    legalItems: [
                        .init(
                            url: URL(string: WebView.CallbackUrl.activate)!,
                            version: 123,
                            name: "legal-item-1",
                            displayName: "Legal Item 1"
                        ),
                        .init(
                            url: URL(string: WebView.CallbackUrl.activate)!,
                            version: 123,
                            name: "legal-item-2",
                            displayName: "Legal Item 2"
                        ),
                        .init(
                            url: URL(string: WebView.CallbackUrl.activate)!,
                            version: 123,
                            name: "legal-item-3",
                            displayName: "Legal Item 3"
                        )
                    ],
                    statements: [
                        .init(id: "123", month: 9, year: 22)
                    ],
                    transactions: [.success, .pending, .failed],
                    tokenisationCoordinator: PassTokenisationCoordinator(service: MockServices())
                ),
                reducer: cardManagementReducer,
                environment: .preview
            )
        )
    }
}
#endif
