// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Foundation
import MoneyKit
import RxSwift
import ToolKit

final class CryptoDelegatedCustodyAccount: CryptoAccount, NonCustodialAccount {
    let asset: CryptoCurrency

    let isDefault: Bool = true

    lazy var identifier: AnyHashable = "CryptoDelegatedCustodyAccount.\(asset.code)"

    var activity: Single<[ActivityItemEvent]> {
        .never()
    }

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .empty()
    }

    var requireSecondPassword: Single<Bool> {
        .never()
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        balanceRepository
            .balances
            .map { [asset] balances in
                balances.balance(index: 0, currency: asset) ?? MoneyValue.zero(currency: asset)
            }
            .eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var label: String {
        asset.defaultWalletName
    }

    let accountType: AccountType = .nonCustodial

    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let priceService: PriceServiceAPI

    init(
        asset: CryptoCurrency,
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI
    ) {
        self.asset = asset
        self.balanceRepository = balanceRepository
        self.priceService = priceService
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .buy,
             .deposit,
             .interestTransfer,
             .interestWithdraw,
             .sell,
             .send,
             .sign,
             .swap,
             .withdraw,
             .linkToDebitCard:
            return .just(false)
        case .receive, .viewActivity:
            return .just(true)
        }
    }

    func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func invalidateAccountBalance() {}
}
