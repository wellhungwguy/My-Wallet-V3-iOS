// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct AcceptLegalView: View {

    @State private var loading = true

    private typealias L10n = LocalizationConstants.CardIssuing.Legal

    private let store: Store<AcceptLegalState, AcceptLegalAction>

    init(store: Store<AcceptLegalState, AcceptLegalAction>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            WithViewStore(store) { viewStore in
                ZStack(alignment: .center) {
                    Text(viewStore.state.current?.displayName ?? "")
                        .typography(.title3)
                        .padding([.top, .leading], Spacing.padding1)
                    HStack {
                        Spacer()
                        Icon.closeCirclev2
                            .frame(width: 24, height: 24)
                            .onTapGesture(perform: {
                                viewStore.send(.close)
                            })
                    }
                    .padding(.horizontal, Spacing.padding2)
                }
                .padding(.bottom, Spacing.padding2)
            }
            IfLetStore(
                store.scope(state: \.current?.url),
                then: { store in
                    WithViewStore(store) { viewStore in
                        WebView(
                            url: viewStore.state,
                            loading: $loading
                        )
                    }
                },
                else: {
                    Spacer()
                }
            )
            WithViewStore(store) { viewStore in
                HStack(alignment: .center) {
                    PrimaryButton(
                        title: viewStore.state.hasNext ? L10n.Button.next : L10n.Button.accept,
                        isLoading: viewStore.state.accepted == .loading || loading
                    ) {
                        viewStore.send(viewStore.state.hasNext ? .next : .accept)
                    }
                    .disabled(viewStore.state.accepted == .loading || loading)
                }
                .padding(Spacing.padding2)
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
        .listStyle(PlainListStyle())
        .padding(.vertical, Spacing.padding2)
        .background(Color.semantic.background.ignoresSafeArea())
    }
}
