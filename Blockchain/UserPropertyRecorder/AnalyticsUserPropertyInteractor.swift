// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import FeatureAuthenticationDomain
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

/// This class connect the analytics service with the application layer
final class AnalyticsUserPropertyInteractor {

    // MARK: - Properties

    private let authenticatorRepository: AuthenticatorRepositoryAPI
    private let coincore: CoincoreAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let guidRepository: GuidRepositoryAPI
    private let nabuUserService: NabuUserServiceAPI
    private let recorder: UserPropertyRecording
    private let tiersService: KYCTiersServiceAPI
    private let subject = PassthroughSubject<Bool, Never>()
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Setup

    init(
        authenticatorRepository: AuthenticatorRepositoryAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        guidRepository: GuidRepositoryAPI = resolve(),
        nabuUserService: NabuUserServiceAPI = resolve(),
        recorder: UserPropertyRecording = AnalyticsUserPropertyRecorder(),
        tiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.authenticatorRepository = authenticatorRepository
        self.coincore = coincore
        self.fiatCurrencyService = fiatCurrencyService
        self.guidRepository = guidRepository
        self.nabuUserService = nabuUserService
        self.recorder = recorder
        self.tiersService = tiersService
        subject
            .throttle(
                for: .seconds(10),
                scheduler: DispatchQueue.global(qos: .userInitiated),
                latest: true
            )
            .flatMap { [_record] _ -> AnyPublisher<Void, Never> in
                _record()
            }
            .eraseToAnyPublisher()
            .subscribe()
            .store(in: &cancellables)
    }

    /// Records all the user properties
    func record() {
        subject.send(true)
    }

    // MARK: Private Methods

    private func fiatBalances() -> AnyPublisher<[CryptoCurrency: MoneyValue], Never> {
        coincore.cryptoAssets
            .map { asset -> AnyPublisher<(asset: CryptoCurrency, moneyValue: MoneyValue?), Never> in
                asset
                    .accountGroup(filter: .allExcludingExchange)
                    .compactMap { $0 }
                    .flatMap { accountGroup -> AnyPublisher<MoneyValue, Error> in
                        // We want to record the fiat balance analytics event always in USD.
                        accountGroup.fiatBalance(fiatCurrency: .USD)
                    }
                    .optional()
                    .replaceError(with: nil)
                    .map { (asset: asset.asset, moneyValue: $0) }
                    .eraseToAnyPublisher()
            }
            .zip()
            .map { items in
                items.reduce(into: [CryptoCurrency: MoneyValue]()) { result, item in
                    result[item.asset] = item.moneyValue
                }
            }
            .eraseToAnyPublisher()
    }

    /// Records all the user properties
    private func _record() -> AnyPublisher<Void, Never> {
        Publishers.Zip4(
            nabuUserService.user.eraseError(),
            tiersService.tiers.eraseError(),
            authenticatorRepository.authenticatorType.eraseError(),
            guidRepository.guid.eraseError()
        )
        .zip(fiatBalances().eraseError())
        .handleEvents(
            receiveOutput: { [weak self] userData, fiatBalances in
                self?.record(
                    user: userData.0,
                    tiers: userData.1,
                    authenticatorType: userData.2,
                    guid: userData.3,
                    balances: fiatBalances
                )
            },
            receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    Logger.shared.error(error)
                case .finished:
                    break
                }
            }
        )
        .mapToVoid()
        .replaceError(with: ())
        .eraseToAnyPublisher()
    }

    private func record(
        user: NabuUser?,
        tiers: KYC.UserTiers?,
        authenticatorType: WalletAuthenticatorType,
        guid: String?,
        balances: [CryptoCurrency: MoneyValue]
    ) {
        if let identifier = user?.personalDetails.identifier {
            recorder.record(id: identifier)
            let property = HashedUserProperty(key: .nabuID, value: identifier)
            recorder.record(property)
        }

        if let guid = guid {
            let property = HashedUserProperty(key: .walletID, value: guid)
            recorder.record(property)
        }

        if let tiers = tiers {
            let value = "\(tiers.latestTier.rawValue)"
            recorder.record(StandardUserProperty(key: .kycLevel, value: value))
        }

        if let date = user?.kycCreationDate {
            recorder.record(StandardUserProperty(key: .kycCreationDate, value: date))
        }

        if let date = user?.kycUpdateDate {
            recorder.record(StandardUserProperty(key: .kycUpdateDate, value: date))
        }

        if let isEmailVerified = user?.email.verified {
            recorder.record(StandardUserProperty(key: .emailVerified, value: String(isEmailVerified)))
        }

        recorder.record(StandardUserProperty(key: .twoFAEnabled, value: String(authenticatorType.isTwoFactor)))

        let positives: [String] = balances
            .filter(\.value.isPositive)
            .map(\.key.code)

        let totalFiatBalance = try? balances.values.reduce(.zero(currency: .USD), +)

        recorder.record(
            StandardUserProperty(key: .fundedCoins, value: positives.joined(separator: ","))
        )
        recorder.record(
            StandardUserProperty(key: .totalBalance, value: balanceBucket(for: totalFiatBalance?.minorAmount ?? 0))
        )
    }

    /// Total balance (measured in USD) in buckets: 0, 0-10, 10-100, 100-1000, >1000
    private func balanceBucket(for minorUSDBalance: BigInt) -> String {
        switch minorUSDBalance {
        case ...099:
            return "0 USD"
        case 100...1099:
            return "1-10 USD"
        case 1100...10099:
            return "11-100 USD"
        case 10100...100099:
            return "101-1000 USD"
        case 100100...:
            return "1001 USD"
        default:
            return "0 USD"
        }
    }
}
