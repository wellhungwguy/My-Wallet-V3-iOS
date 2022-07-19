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

    var activity: AnyPublisher<[ActivityItemEvent], Error> {
        activityRepository
            .activity(for: asset)
            .zip(receiveAddress)
            .map { activities, receiveAddress in
                activities
                    .map { activity in
                        activity.simpleActivityItemEvent(receiveAddress: receiveAddress.address)
                    }
                    .map(ActivityItemEvent.simpleTransactional)
            }
            .replaceError(with: [])
            .eraseError()
            .eraseToAnyPublisher()
    }

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        addressesRepository
            .addresses(for: asset)
            .map { [publicKey] addresses in
                addresses
                    .first(where: { address in
                        address.publicKey == publicKey && address.isDefault
                    })
            }
            .onNil(ReceiveAddressError.notSupported)
            .flatMap { [addressFactory] match in
                addressFactory
                    .makeExternalAssetAddress(
                        address: match.address,
                        label: match.address,
                        onTxCompleted: { _ in .empty() }
                    )
                    .publisher
                    .eraseError()
            }
            .map { $0 as ReceiveAddress }
            .eraseToAnyPublisher()
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

    private let activityRepository: DelegatedCustodyActivityRepositoryAPI
    private let addressesRepository: DelegatedCustodyAddressesRepositoryAPI
    private let addressFactory: ExternalAssetAddressFactory
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let publicKey: String

    init(
        activityRepository: DelegatedCustodyActivityRepositoryAPI,
        addressesRepository: DelegatedCustodyAddressesRepositoryAPI,
        addressFactory: ExternalAssetAddressFactory,
        asset: CryptoCurrency,
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        publicKey: String
    ) {
        self.activityRepository = activityRepository
        self.addressesRepository = addressesRepository
        self.addressFactory = addressFactory
        self.asset = asset
        self.balanceRepository = balanceRepository
        self.priceService = priceService
        self.publicKey = publicKey
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

extension DelegatedCustodyActivity {
    fileprivate func simpleActivityItemEvent(receiveAddress: String) -> SimpleTransactionalActivityItemEvent {
        let eventStatus: SimpleTransactionalActivityItemEvent.EventStatus
        switch status {
        case .pending, .confirming:
            eventStatus = .pending(confirmations: .init(current: 1, total: 2))
        case .failed, .completed:
            eventStatus = .complete
        }

        let isSend = receiveAddress.caseInsensitiveCompare(from) == .orderedSame
        let eventType: SimpleTransactionalActivityItemEvent.EventType = isSend ? .send : .receive

        return SimpleTransactionalActivityItemEvent(
            amount: value,
            creationDate: timestamp,
            destinationAddress: to,
            fee: fee,
            identifier: transactionID,
            memo: nil,
            sourceAddress: from,
            status: eventStatus,
            transactionHash: transactionID,
            type: eventType
        )
    }
}
