// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class EVMCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "EVMCryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true
    let publicKey: String
    let network: EVMNetwork

    func createTransactionEngine() -> Any {
        EthereumOnChainTransactionEngineFactory(
            network: network
        )
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        balance
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        ethereumBalanceRepository
            .balance(
                network: network,
                for: publicKey
            )
            .map(\.moneyValue)
            .eraseError()
            .eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    /// The `ReceiveAddress` for the given account
    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .just(ethereumReceiveAddress)
    }

    var activity: AnyPublisher<[ActivityItemEvent], Error> {
        nonCustodialActivity
            .zip(swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    var nonce: AnyPublisher<BigUInt, EthereumNonceRepositoryError> {
        nonceRepository.nonce(
            network: network,
            for: publicKey
        )
    }

    private var isInterestTransferAvailable: AnyPublisher<Bool, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(false)
        }
        return isInterestWithdrawAndDepositEnabled
            .zip(canPerformInterestTransfer)
            .map { isEnabled, canPerform in
                isEnabled && canPerform
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private var nonCustodialActivity: AnyPublisher<[TransactionalActivityItemEvent], Never> {
        switch network {
        case .ethereum:
            // Use old repository
            return activityRepository
                .transactions(address: publicKey)
                .map { response in
                    response.map(\.activityItemEvent)
                }
                .replaceError(with: [])
                .eraseToAnyPublisher()
        case .polygon:
            // Use EVM repository
            return evmActivityRepository
                .transactions(cryptoCurrency: asset, address: publicKey)
                .map { [publicKey] transactions in
                    transactions
                        .map { item in
                            item.activityItemEvent(sourceIdentifier: publicKey)
                        }
                }
                .replaceError(with: [])
                .eraseToAnyPublisher()
        }
    }

    private var ethereumReceiveAddress: EthereumReceiveAddress {
        EthereumReceiveAddress(
            address: publicKey,
            label: label,
            network: network,
            onTxCompleted: onTxCompleted
        )!
    }

    private var ethereumAddress: EthereumAddress {
        EthereumAddress(address: publicKey, network: network)!
    }

    private var swapActivity: AnyPublisher<[SwapActivityItemEvent], Never> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private var isInterestWithdrawAndDepositEnabled: AnyPublisher<Bool, Never> {
        featureFlagsService
            .isEnabled(.interestWithdrawAndDeposit)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private let bridge: EthereumWalletBridgeAPI
    private let ethereumBalanceRepository: EthereumBalanceRepositoryAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let hdAccountIndex: Int
    private let nonceRepository: EthereumNonceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let activityRepository: HistoricalTransactionsRepositoryAPI
    private let evmActivityRepository: EVMActivityRepositoryAPI

    init(
        network: EVMNetwork,
        publicKey: String,
        label: String? = nil,
        hdAccountIndex: Int,
        activityRepository: HistoricalTransactionsRepositoryAPI = resolve(),
        evmActivityRepository: EVMActivityRepositoryAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        bridge: EthereumWalletBridgeAPI = resolve(),
        ethereumBalanceRepository: EthereumBalanceRepositoryAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve(),
        nonceRepository: EthereumNonceRepositoryAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        let asset = network.cryptoCurrency
        self.asset = asset
        self.network = network
        self.publicKey = publicKey
        self.hdAccountIndex = hdAccountIndex
        self.priceService = priceService
        self.activityRepository = activityRepository
        self.evmActivityRepository = evmActivityRepository
        self.swapTransactionsService = swapTransactionsService
        self.ethereumBalanceRepository = ethereumBalanceRepository
        self.bridge = bridge
        self.label = label ?? asset.defaultWalletName
        self.featureFlagsService = featureFlagsService
        self.nonceRepository = nonceRepository
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .receive,
             .send,
             .viewActivity,
             .linkToDebitCard:
            return .just(true)
        case .deposit,
             .sign,
             .withdraw,
             .interestWithdraw:
            return .just(false)
        case .buy:
            return .just(asset.supports(product: .custodialWalletBalance))
        case .interestTransfer:
            return isInterestTransferAvailable
                .flatMap { [isFunded] isEnabled in
                    isEnabled ? isFunded : .just(false)
                }
                .eraseToAnyPublisher()
        case .sell, .swap:
            guard asset.supports(product: .custodialWalletBalance) else {
                return .just(false)
            }
            return hasPositiveDisplayableBalance
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

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }

    func invalidateAccountBalance() {
        ethereumBalanceRepository.invalidateCache()
    }
}
