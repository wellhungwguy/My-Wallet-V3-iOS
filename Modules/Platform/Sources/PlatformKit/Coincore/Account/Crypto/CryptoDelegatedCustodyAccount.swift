// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Foundation
import MoneyKit
import RxSwift
import ToolKit

public final class CryptoDelegatedCustodyAccount: CryptoAccount, NonCustodialAccount {
    public let asset: CryptoCurrency

    public let isDefault: Bool = true

    public lazy var identifier: AnyHashable = "CryptoDelegatedCustodyAccount.\(asset.code)"

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
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

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
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

    public var balance: AnyPublisher<MoneyValue, Error> {
        balanceRepository
            .balances
            .map { [asset] balances in
                balances.balance(index: 0, currency: asset) ?? MoneyValue.zero(currency: asset)
            }
            .eraseToAnyPublisher()
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    public var label: String {
        asset.defaultWalletName
    }

    public let accountType: AccountType = .nonCustodial
    public let delegatedCustodyAccount: DelegatedCustodyAccount

    private let activityRepository: DelegatedCustodyActivityRepositoryAPI
    private let addressesRepository: DelegatedCustodyAddressesRepositoryAPI
    private let addressFactory: ExternalAssetAddressFactory
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let priceService: PriceServiceAPI

    private var publicKey: String {
        delegatedCustodyAccount.publicKey.hex
    }

    init(
        activityRepository: DelegatedCustodyActivityRepositoryAPI,
        addressesRepository: DelegatedCustodyAddressesRepositoryAPI,
        addressFactory: ExternalAssetAddressFactory,
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        delegatedCustodyAccount: DelegatedCustodyAccount
    ) {
        self.activityRepository = activityRepository
        self.addressesRepository = addressesRepository
        self.addressFactory = addressFactory
        self.balanceRepository = balanceRepository
        self.priceService = priceService
        self.delegatedCustodyAccount = delegatedCustodyAccount
        self.asset = delegatedCustodyAccount.coin
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .buy,
             .deposit,
             .interestTransfer,
             .interestWithdraw,
             .stakingDeposit,
             .sell,
             .sign,
             .swap,
             .withdraw,
             .linkToDebitCard:
            return .just(false)
        case .send:
            return balance
                .map(\.isPositive)
                .eraseToAnyPublisher()
        case .receive, .viewActivity:
            return .just(true)
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func invalidateAccountBalance() {}
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
