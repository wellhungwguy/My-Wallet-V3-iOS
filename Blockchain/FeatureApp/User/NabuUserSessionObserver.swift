// swiftlint:disable line_length

import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureAuthenticationDomain
import MoneyKit
import PlatformKit
import ToolKit

final class NabuUserSessionObserver: Session.Observer {

    unowned let app: AppProtocol

    private var bag: Set<AnyCancellable> = []
    private let userService: NabuUserServiceAPI
    private let tokenRepository: NabuTokenRepositoryAPI
    private let offlineTokenRepository: NabuOfflineTokenRepositoryAPI

    init(
        app: AppProtocol,
        tokenRepository: NabuTokenRepositoryAPI = resolve(),
        offlineTokenRepository: NabuOfflineTokenRepositoryAPI = resolve(),
        userService: NabuUserServiceAPI = resolve()
    ) {
        self.app = app
        self.tokenRepository = tokenRepository
        self.offlineTokenRepository = offlineTokenRepository
        self.userService = userService
    }

    var token: AnyCancellable?

    func start() {

        resetTokenObserver()
        tokenRepository.sessionTokenPublisher
            .compactMap(\.wrapped)
            .sink { [app] nabu in app.state.set(blockchain.user.token.nabu, to: nabu.token) }
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.in)
            .flatMap { [userService] _ in userService.fetchUser() }
            .sink(to: NabuUserSessionObserver.fetched(user:), on: self)
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.out)
            .sink(to: My.resetTokenObserver, on: self)
            .store(in: &bag)

        app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .removeDuplicates()
            .dropFirst()
            .flatMap { [userService] currency -> AnyPublisher<NabuUser, Never> in
                userService.setTradingCurrency(currency)
                    .flatMap { userService.fetchUser().mapError(\.nabu) }
                    .ignoreFailure()
                    .eraseToAnyPublisher()
            }
            .sink(to: NabuUserSessionObserver.fetched(user:), on: self)
            .store(in: &bag)
    }

    func stop() {
        bag = []
    }

    func resetTokenObserver() {
        token = offlineTokenRepository.offlineTokenPublisher
            .compactMap(\.success?.userId)
            .removeDuplicates()
            .sink { [app] userId in
                app.signIn(userId: userId)
            }
    }

    func fetched(user: NabuUser) {
        app.state.transaction { state in

            state.set(blockchain.user.is.cowboy.fan, to: false)

            state.set(blockchain.user.email.address, to: user.email.address)
            state.set(blockchain.user.name.first, to: user.personalDetails.firstName)
            state.set(blockchain.user.name.last, to: user.personalDetails.lastName)
            state.set(blockchain.user.currency.currencies, to: user.currencies.userFiatCurrencies.map(\.code))
            state.set(blockchain.user.currency.preferred.fiat.trading.currency, to: user.currencies.preferredFiatTradingCurrency.code)
            state.set(blockchain.user.currency.available.currencies, to: user.currencies.usableFiatCurrencies.map(\.code))
            state.set(blockchain.user.currency.default, to: user.currencies.defaultWalletCurrency.code)
            state.set(blockchain.user.address.line_1, to: user.address?.lineOne)
            state.set(blockchain.user.address.line_2, to: user.address?.lineTwo)
            state.set(blockchain.user.address.state, to: user.address?.state)
            state.set(blockchain.user.address.city, to: user.address?.city)
            state.set(blockchain.user.address.postal.code, to: user.address?.postalCode)
            state.set(blockchain.user.address.country.code, to: user.address?.countryCode)
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
