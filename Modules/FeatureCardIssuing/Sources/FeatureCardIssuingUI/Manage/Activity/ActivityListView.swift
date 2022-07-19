// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

struct ActivityListView: View {

    typealias L10n = LocalizationConstants.CardIssuing.Manage.Activity
    let store: Store<CardManagementState, CardManagementAction>

    init(
        store: Store<CardManagementState, CardManagementAction>
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                ForEach(viewStore.state.transactions) { transaction in
                    ActivityRow(transaction) {
                        viewStore.send(.showTransaction(transaction))
                    }
                    .onAppear {
                        if transaction == viewStore.state.transactions.last {
                            viewStore.send(.fetchMoreTransactions)
                        }
                    }
                    PrimaryDivider()
                }
            }
            .padding(0)
            .navigationTitle(L10n.transactionListTitle)
            .bottomSheet(
                isPresented: viewStore.binding(
                    get: {
                        $0.displayedTransaction != nil
                    },
                    send: CardManagementAction.setTransactionDetailsVisible
                ),
                content: {
                    ActivityDetailsView(store: store.scope(state: \.displayedTransaction))
                }
            )
        }
    }
}

#if DEBUG

struct ActivityList_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ActivityListView(
                store: Store(
                    initialState: .preview,
                    reducer: cardManagementReducer,
                    environment: .preview
                )
            )
        }
    }
}

#endif
