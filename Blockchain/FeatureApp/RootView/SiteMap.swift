import BlockchainUI
import DIKit
import FeatureAppUI
import FeatureStakingUI
import PlatformKit

// swiftlint:disable line_length

@MainActor
struct SiteMap {

    let app: AppProtocol

    @ViewBuilder func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) async throws -> some View {
        let story = try ref.tag.as(blockchain.ux.type.story)
        switch ref.tag {
        case blockchain.ux.user.portfolio:
            PortfolioView()
        case blockchain.ux.prices:
            PricesView()
        case blockchain.ux.user.rewards:
            RewardsView()
        case blockchain.ux.user.activity:
            ActivityView()
        case blockchain.ux.asset:
            let currency = try ref.context[blockchain.ux.asset.id].decode(CryptoCurrency.self)
            CoinAdapterView(
                cryptoCurrency: currency,
                dismiss: {
                    app.post(value: true, of: story.article.plain.navigation.bar.button.close.tap.then.close.key(to: ref.context))
                }
            )
        case isDescendant(of: blockchain.ux.transaction):
            try await transaction(for: ref, in: context)
        case isDescendant(of: blockchain.ux.earn):
            try await Earn(app).view(for: ref, in: context)
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}

extension SiteMap {

    @MainActor @ViewBuilder func transaction(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) async throws -> some View {
        switch ref.tag {
        case blockchain.ux.transaction.disclaimer:
            StakingConsiderationsView()
                .context([blockchain.user.earn.product.id: "staking"])
        default:
            throw Error(message: "No view", tag: ref, context: context)
        }
    }
}

extension SiteMap {

    @MainActor
    struct Earn {

        let app: AppProtocol

        init(_ app: AppProtocol) { self.app = app }

        @MainActor @ViewBuilder func view(
            for ref: Tag.Reference,
            in context: Tag.Context = [:]
        ) async throws -> some View {
            switch ref.tag {
            case blockchain.ux.earn.staking.summary:
                let currency = try ref.context[blockchain.ux.earn.staking.id].decode(CryptoCurrency.self)
                let exchangeRate = try await currency.exchangeRate(app: app)
                StakingSummaryView(exchangeRate: exchangeRate)
                    .context(
                        [
                            blockchain.user.earn.product.id: "staking",
                            blockchain.user.earn.product.asset.id: currency.code
                        ] + ref.context
                    )
                    .task {
                        do {
                            try await app.batch(
                                updates: [
                                    (blockchain.ux.earn.staking.summary.view.activity.paragraph.row.tap.then.emit, blockchain.ux.home.tab[blockchain.ux.user.activity].select),
                                    (blockchain.ux.earn.staking.summary.add.paragraph.button.primary.tap.then.emit, blockchain.ux.asset.account.staking.deposit),
                                    (blockchain.ux.earn.staking.summary.learn.more.paragraph.button.small.secondary.tap.then.launch.url, app.get(blockchain.ux.earn.staking[currency.code].summary.learn.more.url) as URL),
                                    (blockchain.ux.earn.staking.summary.article.plain.navigation.bar.button.close.tap.then.close, true)
                                ],
                                in: context + ref.context
                            )
                        } catch {
                            app.post(error: error)
                        }
                    }
            default:
                throw Error(message: "No view", tag: ref, context: context)
            }
        }
    }
}

extension SiteMap {

    struct Error: Swift.Error {
        let message: String
        let tag: Tag.Reference
        let context: Tag.Context
    }
}

extension CryptoCurrency {

    func exchangeRate(
        with currency: L & I_blockchain_type_currency = blockchain.user.currency.preferred.fiat.display.currency,
        using currencyService: CurrencyConversionServiceAPI = resolve(),
        app: AppProtocol = resolve()
    ) async throws -> MoneyValuePair {
        try await MoneyValuePair(
            base: .one(currency: self),
            quote: currencyService.convert(.one(currency: self), to: .fiat(app.get(currency))).await()
        )
    }
}
