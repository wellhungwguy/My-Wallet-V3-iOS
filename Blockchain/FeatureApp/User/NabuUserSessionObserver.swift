// swiftlint:disable line_length

import BlockchainNamespace
import Combine
import DIKit
import FeatureAuthenticationDomain
import MoneyKit
import PlatformKit
import ToolKit

final class NabuUserSessionObserver: Session.Observer {

    unowned let app: AppProtocol

    private var bag: Set<AnyCancellable> = []
    private let userService: NabuUserServiceAPI
    private let repository: NabuTokenRepositoryAPI

    init(
        app: AppProtocol,
        repository: NabuTokenRepositoryAPI = resolve(),
        userService: NabuUserServiceAPI = resolve()
    ) {
        self.app = app
        self.repository = repository
        self.userService = userService
    }

    func start() {

        repository.sessionTokenPublisher
            .compactMap(\.wrapped)
            .sink { [app] nabu in app.state.set(blockchain.user.token.nabu, to: nabu.token) }
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.in)
            .flatMap { [userService] _ in userService.fetchUser() }
            .sink(to: NabuUserSessionObserver.fetched(user:), on: self)
            .store(in: &bag)

        app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .removeDuplicates()
            .dropFirst()
            .flatMap(userService.setTradingCurrency)
            .subscribe()
            .store(in: &bag)
    }

    func stop() {
        bag = []
    }

    func fetched(user: NabuUser) {
        app.state.transaction { state in
            state.set(blockchain.user.email.address, to: user.email.address)
            state.set(blockchain.user.name.first, to: user.personalDetails.firstName)
            state.set(blockchain.user.name.last, to: user.personalDetails.lastName)
            state.set(blockchain.user.currency.value, to: user.currencies.userFiatCurrencies.map(\.code))
            state.set(blockchain.user.currency.preferred.fiat.trading.currency, to: user.currencies.preferredFiatTradingCurrency.code)
            state.set(blockchain.user.currency.available, to: user.currencies.usableFiatCurrencies.map(\.code))
            state.set(blockchain.user.currency.default, to: user.currencies.defaultWalletCurrency.code)
            let tag: Tag
            if let tier = user.tiers?.current {
                switch tier {
                case .tier0:
                    tag = blockchain.user.account.tier.none[]
                case .tier1:
                    tag = blockchain.user.account.tier.silver[]
                case .tier2:
                    tag = blockchain.user.account.tier.gold[]
                }
            } else {
                tag = blockchain.user.account.tier.none[]
            }
            state.set(blockchain.user.account.tier, to: tag)
        }
    }
}
