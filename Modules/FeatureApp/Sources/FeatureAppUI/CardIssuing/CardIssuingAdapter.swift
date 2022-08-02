// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import Errors
import FeatureAccountPickerUI
import FeatureCardIssuingDomain
import FeatureCardIssuingUI
import FeatureSettingsUI
import FeatureTransactionUI
import Foundation
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SwiftUI
import UIComponentsKit

final class CardIssuingAdapter: FeatureSettingsUI.CardIssuingViewControllerAPI {

    private let cardIssuingBuilder: CardIssuingBuilderAPI
    private let nabuUserService: NabuUserServiceAPI

    init(
        cardIssuingBuilder: CardIssuingBuilderAPI,
        nabuUserService: NabuUserServiceAPI
    ) {
        self.cardIssuingBuilder = cardIssuingBuilder
        self.nabuUserService = nabuUserService
    }

    func makeIntroViewController(
        onComplete: @escaping (FeatureSettingsUI.CardOrderingResult) -> Void
    ) -> UIViewController {
        let address = nabuUserService
            .user
            .mapError { _ in CardOrderingError.noAddress }
            .flatMap { user -> AnyPublisher<Card.Address, CardOrderingError> in
                guard let address = user.address else {
                    return .failure(.noAddress)
                }
                return .just(Card.Address(with: address))
            }
            .eraseToAnyPublisher()

        return cardIssuingBuilder.makeIntroViewController(address: address) { result in
            switch result {
            case .created:
                onComplete(.created)
            case .cancelled:
                onComplete(.cancelled)
            }
        }
    }

    func makeManagementViewController(
        onComplete: @escaping () -> Void
    ) -> UIViewController {
        cardIssuingBuilder.makeManagementViewController(onComplete: onComplete)
    }
}

final class CardIssuingTopUpRouter: TopUpRouterAPI {

    private let coincore: CoincoreAPI
    private let transactionsRouter: TransactionsRouterAPI

    private var cancellables = [AnyCancellable]()

    init(
        coincore: CoincoreAPI,
        transactionsRouter: TransactionsRouterAPI
    ) {
        self.coincore = coincore
        self.transactionsRouter = transactionsRouter
    }

    func openBuyFlow(for currency: FiatCurrency?) {
        guard let fiatCurrency = currency else {
            transactionsRouter.presentTransactionFlow(to: .buy(nil))
                .subscribe()
                .store(in: &cancellables)
            return
        }

        coincore
            .allAccounts(filter: .all)
            .receive(on: DispatchQueue.main)
            .map { accountGroup -> FiatAccount? in
                accountGroup.accounts
                    .compactMap { account in account as? FiatAccount }
                    .first(where: { account in
                        account.fiatCurrency.code == fiatCurrency.code
                    })
            }
            .flatMap { [weak self] fiatAccount -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self = self else {
                    return .just(.abandoned)
                }

                guard let fiatAccount = fiatAccount else {
                    return self
                        .transactionsRouter
                        .presentTransactionFlow(to: .buy(nil))
                }

                return self
                    .transactionsRouter
                    .presentTransactionFlow(to: .deposit(fiatAccount))
            }
            .subscribe()
            .store(in: &cancellables)
    }

    func openBuyFlow(for currency: CryptoCurrency?) {
        guard let cryptoCurrency = currency else {
            transactionsRouter.presentTransactionFlow(to: .buy(nil))
                .subscribe()
                .store(in: &cancellables)
            return
        }

        coincore
            .cryptoAccounts(for: cryptoCurrency)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] accounts -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self = self else {
                    return .just(.abandoned)
                }
                return self
                    .transactionsRouter
                    .presentTransactionFlow(to: .buy(accounts.first(where: { account in
                        account.accountType.isCustodial
                    })))
            }
            .subscribe()
            .store(in: &cancellables)
    }

    func openSwapFlow() {
        transactionsRouter
            .presentTransactionFlow(to: .swap(nil))
            .subscribe()
            .store(in: &cancellables)
    }
}

class CardIssuingAccountPickerAdapter: AccountProviderAPI, AccountPickerAccountProviding {

    private struct Account {
        let details: BlockchainAccount
        let balance: AccountBalance
    }

    private let nabuUserService: NabuUserServiceAPI
    private let coinCore: CoincoreAPI
    private var cancellables = [AnyCancellable]()
    private let cardService: CardServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    init(
        cardService: CardServiceAPI,
        coinCore: CoincoreAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        nabuUserService: NabuUserServiceAPI
    ) {
        self.cardService = cardService
        self.coinCore = coinCore
        self.fiatCurrencyService = fiatCurrencyService
        self.nabuUserService = nabuUserService
    }

    private let accountPublisher = CurrentValueSubject<[Account], Never>([])
    private var router: AccountPickerRouting?

    var accounts: Observable<[BlockchainAccount]> {
        accountPublisher
            .map { pairs in
                pairs.map(\.details)
            }
            .asObservable()
    }

    func selectAccount(for card: Card) -> AnyPublisher<AccountBalance, NabuNetworkError> {

        let publisher = PassthroughSubject<AccountBalance, NabuNetworkError>()
        let accounts = cardService.eligibleAccounts(for: card)
        let accountBalances = Publishers
            .CombineLatest(accounts.eraseError(), coinCore.allAccounts(filter: .all).eraseError())
            .map { accountBalances, group -> [Account] in
                accountBalances
                    .compactMap { accountBalance in
                        guard let account = group.accounts.first(where: {
                            accountBalance.balance.symbol == $0.currencyType.code
                                && $0.accountType.isCustodial
                        }) else {
                            return nil
                        }
                        return Account(details: account, balance: accountBalance)
                    }
            }

        let builder = AccountPickerBuilder(
            accountProvider: self,
            action: .linkToDebitCard
        )

        let router = builder.build(
            listener: .simple { [weak self] account in
                if let balance = self?.accountPublisher.value.first(where: { pair in
                    pair.details.identifier == account.identifier
                })?.balance {
                    publisher.send(balance)
                }
                self?.router?.viewControllable
                    .uiviewController
                    .dismiss(
                        animated: true
                    )
            },
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: LocalizationConstants
                    .CardIssuing
                    .Manage
                    .SourceAccount
                    .title
            ),
            headerModel: .none
        )

        self.router = router

        router.interactable.activate()
        router.load()
        let viewController = router.viewControllable.uiviewController
        viewController.isModalInPresentation = true

        let navigationController = UINavigationController(rootViewController: viewController)

        accountBalances.sink(receiveValue: accountPublisher.send).store(in: &cancellables)

        let topMostViewControllerProvider: TopMostViewControllerProviding = resolve()

        topMostViewControllerProvider
            .topMostViewController?
            .present(navigationController, animated: true)

        return publisher.eraseToAnyPublisher()
    }

    func linkedAccount(for card: Card) -> AnyPublisher<AccountSnapshot?, Never> {

        Publishers
            .CombineLatest3(
                cardService.fetchLinkedAccount(for: card).eraseError(),
                coinCore.allAccounts(filter: .all).eraseError(),
                fiatCurrencyService.displayCurrency.eraseError()
            )
            .flatMap { accountCurrency, group, fiatCurrency
                -> AnyPublisher<AccountSnapshot?, Never> in
                guard let account = group.accounts.first(where: { account in
                    account.currencyType.code == accountCurrency.accountCurrency
                        && account.accountType.isCustodial
                }) else {
                    return .just(nil)
                }

                return AccountSnapshot
                    .with(
                        account,
                        fiatCurrency
                    )
                    .optional()
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}

extension FeatureCardIssuingDomain.Card.Address {
    init(with address: UserAddress) {
        self.init(
            line1: address.lineOne,
            line2: address.lineTwo,
            city: address.city,
            postCode: address.postalCode,
            state: address.state,
            country: address.country.code
        )
    }
}

extension AccountSnapshot {

    static func with(
        _ account: SingleAccount,
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<FeatureCardIssuingDomain.AccountSnapshot, Never> {
        account.balance.ignoreFailure()
            .combineLatest(
                account.fiatBalance(fiatCurrency: fiatCurrency)
                    .ignoreFailure()
            )
            .map { crypto, fiat in
                AccountSnapshot(
                    id: account.identifier,
                    name: account.label,
                    cryptoCurrency: account.currencyType.cryptoCurrency,
                    fiatCurrency: fiatCurrency,
                    crypto: crypto,
                    fiat: fiat,
                    image: crypto.currencyType.image,
                    backgroundColor: account.currencyType.cryptoCurrency == nil ? .backgroundFiat : .clear
                )
            }
            .eraseToAnyPublisher()
    }
}
