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
                        .typography(.body2)
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
            WithViewStore(store) { viewStore in
                HStack {
                    ProgressView(value: viewStore.state.progressPercentage).progressViewStyle(.linear)
                    Text(viewStore.state.progressCaption).typography(.caption2).foregroundColor(.semantic.muted)
                }
            }
            .padding(Spacing.padding2)
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
                    VStack {
                        if viewStore.state.hasNext {
                            MinimalButton(title: L10n.Button.skip) {
                                viewStore.send(.skipAll)
                            }
                        }
                        PrimaryButton(
                            title: viewStore.state.hasNext ? L10n.Button.next : L10n.Button.done,
                            isLoading: viewStore.state.accepted == .loading || loading
                        ) {
                            viewStore.send(viewStore.state.hasNext ? .next : .accept)
                        }
                        .disabled(viewStore.state.accepted == .loading || loading)
                    }
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

extension AcceptLegalState {

    fileprivate var progressPercentage: Float {
        guard items.isNotEmpty,
                let current,
              let currentIndex = items.firstIndex(of: current)
        else {
            return .zero
        }

        return Float(currentIndex + 1) / Float(items.count)
    }

    fileprivate var progressCaption: String {
        guard items.isNotEmpty else {
            return ""
        }

        guard let current,
              let currentIndex = items.firstIndex(of: current)
        else {
            return "0/\(items.count)"
        }

        return "\(currentIndex + 1)/\(items.count)"
    }
}

#if DEBUG
struct AcceptLegal_Previews: PreviewProvider {
    static var previews: some View {
            AcceptLegalView(
                store: Store(
                    initialState: AcceptLegalState(
                        items: [
                            LegalItem(
                                url: URL(string: "https://blockchain.com/")!,
                                version: 1,
                                name: "TC",
                                displayName: "Terms & Conditions",
                                acceptedVersion: 1
                            ),
                            LegalItem(
                                url: URL(string: "https://blockchain.com/")!,
                                version: 1,
                                name: "UC",
                                displayName: "Not Terms & Conditions",
                                acceptedVersion: 1
                            ),
                            LegalItem(
                                url: URL(string: "https://blockchain.com/")!,
                                version: 1,
                                name: "VC",
                                displayName: "Not Terms & Conditions either",
                                acceptedVersion: 1
                            )
                        ],
                        current: LegalItem(
                            url: URL(string: "https://blockchain.com/")!,
                            version: 1,
                            name: "VC",
                            displayName: "Not Terms & Conditions either",
                            acceptedVersion: 1
                        )
                    ),
                    reducer: acceptLegalReducer,
                    environment: .init(mainQueue: .main, legalService: MockServices())
                )
            )
        }
}
#endif
