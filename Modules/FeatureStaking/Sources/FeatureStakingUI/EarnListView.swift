// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
struct EarnListView<Content: View>: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let hub: L & I_blockchain_ux_earn_type_hub
    let model: [Model]?
    let content: (L & I_blockchain_ux_earn_type_hub_product_asset, EarnProduct, CryptoCurrency, Bool) -> Content

    @StateObject private var state: SortedData

    init(
        hub: L & I_blockchain_ux_earn_type_hub,
        model: [Model]?,
        @ViewBuilder content: @escaping (L & I_blockchain_ux_earn_type_hub_product_asset, EarnProduct, CryptoCurrency, Bool) -> Content
    ) {
        self.hub = hub
        self.model = model
        self.content = content
        _state = .init(wrappedValue: SortedData(hub: hub))
    }

    enum Filter: Hashable {
        case all, only(EarnProduct)
    }

    @State var products: [EarnProduct] = []
    @State var filter: Filter = .all
    @State var search: String = ""
    @State var subscription: AnyCancellable?

    let fuzzyAlgorithm = FuzzyAlgorithm()
    var filtered: [Model] {
        state.value.filter { item in
            switch filter {
            case .all: return true
            case .only(let o): return item.product == o
            }
        }
        .filter { item in
            search.isEmpty
                || item.asset.code.distance(between: search, using: fuzzyAlgorithm) < 0.3
                || item.asset.name.distance(between: search, using: fuzzyAlgorithm) < 0.3
        }
    }

    var body: some View {
        VStack {
            if state.value.count > 5 {
                searchField
            }
            if model.isNotNilOrEmpty, filters.count > 1 {
                segmentedControl
            } else {
                Spacer().frame(height: 10.pt)
            }
            if model.isNotNilOrEmpty {
                list
            } else {
                Spacer()
                BlockchainProgressView()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            app.post(event: hub.article.plain.lifecycle.event.did.enter[].ref(to: context), context: context)
        }
        .onDisappear {
            app.post(event: hub.article.plain.lifecycle.event.did.exit[].ref(to: context), context: context)
        }
        .subscribe($products, to: blockchain.ux.earn.supported.products)
        .onChange(of: model) { model in
            app.post(event: hub.article.plain.lifecycle.event.did.update[].ref(to: context), context: context)
            state.update(model, app: app)
        }
    }

    @ViewBuilder var searchField: some View {
        TextField(L10n.search, text: $search.didSet { search in
            app.state.set(hub.search.paragraph.input, to: search.nilIfEmpty)
            app.post(value: search.nilIfEmpty, of: hub.search.paragraph.input.event.value.changed)
        }.animation())
        .typography(.body2)
        .foregroundColor(.semantic.body)
        .overlay(accessoryOverlay, alignment: .trailing)
        .padding([.top, .leading, .trailing])
        .textFieldStyle(.roundedBorder)
    }

    var filters: [(String, Filter)] {
        products.reduce(into: []) { items, product in
            if state.count[product].isNotNil {
                items.append((product.title, .only(product)))
            }
        }
    }

    @ViewBuilder var segmentedControl: some View {
        PrimarySegmentedControl(
            items: [.init(title: L10n.all, identifier: .all)] + filters.map { title, filter in
                .init(title: title, identifier: filter)
            },
            selection: $filter.didSet { filter in
                app.state.set(hub.filter.paragraph.input, to: filter)
                app.post(value: filter, of: hub.filter.paragraph.input.event.value.changed)
                hideKeyboard()
            }.animation()
        )
    }

    @ViewBuilder var list: some View {
        List {
            ForEach(filtered, id: \.self) { item in
                content(hub.product.asset, item.product, item.asset, item.isEligible)
                    .context(
                        [
                            blockchain.user.earn.product.id: item.product.value,
                            blockchain.user.earn.product.asset.id: item.asset.code,
                            hub.product.id: item.product.value,
                            hub.product.asset.id: item.asset.code
                        ]
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .listStyle(.plain)
        .overlay(
            LinearGradient(
                colors: [.semantic.background, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 10.pt),
            alignment: .top
        )
        .overlay(
            VStack {
                if model.isNotNil, filtered.isEmpty {
                    Spacer()
                    noResults
                    Spacer()
                }
            }
        )
    }

    @ViewBuilder var accessoryOverlay: some View {
        if search.isNotEmpty {
            Button(
                action: { clear() },
                label: { Icon.close.color(.white).circle(backgroundColor: .semantic.muted.opacity(0.5)) }
            )
            .padding(6.pt)
        }
    }

    @ViewBuilder var noResults: some View {
        Text(L10n.noResults)
            .typography(.subheading)
            .foregroundColor(.semantic.title)
        SmallMinimalButton(title: L10n.reset) {
            clear()
        }
        .padding()
    }

    func clear() {
        withAnimation { search = "" }
        hideKeyboard()
    }
}

struct Model: Hashable {
    let product: EarnProduct, asset: CryptoCurrency
    let marketCap: Double
    let isEligible: Bool
    let crypto: MoneyValue?, fiat: MoneyValue?
    let rate: Double
}

extension EarnListView {

    class SortedData: ObservableObject {

        @Published var value: [Model] = []
        @Published var count: [EarnProduct: Int] = [:]

        let hub: L & I_blockchain_ux_earn_type_hub

        init(hub: L & I_blockchain_ux_earn_type_hub) {
            self.hub = hub
        }

        func update(_ model: [Model]?, app: AppProtocol) {
            value = model.emptyIfNil.lazy.filter { [hub] item in
                switch hub {
                case blockchain.ux.earn.portfolio:
                    guard let balance = item.fiat else { return false }
                    if app.state.yes(if: blockchain.ux.user.account.preferences.small.balances.are.hidden), balance.isDust {
                        return false
                    }
                    return balance.isPositive
                case _:
                    return true
                }
            }
            .sorted(by: { $0.asset.name < $1.asset.name })
            .sorted(by: { $0.marketCap > $1.marketCap })
            .sorted(by: { lhs, rhs in
                switch hub {
                case blockchain.ux.earn.portfolio:
                    guard let lhs = lhs.fiat, let rhs = rhs.fiat else { return false }
                    return (try? lhs > rhs) ?? false
                case _:
                    return lhs.rate > rhs.rate
                }
            })
            .sorted(by: { lhs, rhs in
                lhs.isEligible && !rhs.isEligible
            })
            count = Dictionary(
                grouping: value,
                by: \.product
            )
            .mapValues(\.count)
        }
    }
}
