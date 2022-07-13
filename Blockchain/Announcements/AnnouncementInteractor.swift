// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ERC20Kit
import FeatureAppDomain
import FeatureAuthenticationDomain
import FeatureCryptoDomainDomain
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import RxToolKit
import ToolKit
import WalletPayloadKit

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {

    // MARK: - Services

    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        let assetRename: Single<AnnouncementPreliminaryData.AssetRename?> = featureFetcher
            .fetch(for: .assetRenameAnnouncement, as: AssetRenameAnnouncementFeature.self)
            .eraseError()
            .flatMap { [enabledCurrenciesService, coincore] data
                -> AnyPublisher<AnnouncementPreliminaryData.AssetRename?, Error> in
                guard let cryptoCurrency = CryptoCurrency(
                    code: data.networkTicker,
                    enabledCurrenciesService: enabledCurrenciesService
                ) else {
                    return .just(nil)
                }
                return coincore[cryptoCurrency]
                    .accountGroup(filter: .all)
                    .flatMap(\.balance)
                    .map { balance in
                        AnnouncementPreliminaryData.AssetRename(
                            asset: cryptoCurrency,
                            oldTicker: data.oldTicker,
                            balance: balance
                        )
                    }
                    .eraseError()
                    .eraseToAnyPublisher()
            }
            .replaceError(with: nil)
            .asSingle()

        let hasLinkedBanks = beneficiariesService.hasLinkedBank
            .take(1)
            .asSingle()
        let isSimpleBuyAvailable = supportedPairsInteractor.pairs
            .map { !$0.pairs.isEmpty }
            .take(1)
            .asSingle()
        let isSimpleBuyEligible = simpleBuyEligibilityService.isEligible
        let simpleBuyOrderDetails = pendingOrderDetailsService.pendingActionOrderDetails

        let simpleBuy: Single<AnnouncementPreliminaryData.SimpleBuy> = Single
            .zip(
                hasLinkedBanks,
                isSimpleBuyAvailable,
                isSimpleBuyEligible,
                simpleBuyOrderDetails
            )
            .map { hasLinkedBanks, isSimpleBuyAvailable, isSimpleBuyEligible, simpleBuyOrderDetails in
                AnnouncementPreliminaryData.SimpleBuy(
                    hasLinkedBanks: hasLinkedBanks,
                    isAvailable: isSimpleBuyAvailable,
                    isEligible: isSimpleBuyEligible,
                    pendingOrderDetails: simpleBuyOrderDetails
                )
            }

        let nabuUser = userService.user.asSingle()
        let tiers = tiersService.tiers.asSingle()
        let sddEligibility = tiersService.checkSimplifiedDueDiligenceEligibility()
            .asSingle()
        let countries = infoService.countries

        let hasAnyWalletBalance = coincore.allAccounts
            .map(\.accounts)
            .eraseError()
            .flatMap { accounts -> AnyPublisher<Bool, Error> in
                accounts
                    .map { $0.isFunded.replaceError(with: false) }
                    .zip()
                    .map { values in
                        values.contains(true)
                    }
                    .eraseError()
            }
            .asSingle()

        let authenticatorType = repository.authenticatorType.asSingle()
        let newAsset: Single<CryptoCurrency?> = featureFetcher
            .fetch(for: .newAssetAnnouncement, as: String.self)
            .map { [enabledCurrenciesService] code -> CryptoCurrency? in
                CryptoCurrency(
                    code: code,
                    enabledCurrenciesService: enabledCurrenciesService
                )
            }
            .replaceError(with: nil)
            .asSingle()

        let claimFreeDomainEligible = featureFetcher
            .fetch(for: .blockchainDomains, as: Bool.self)
            .flatMap { [claimEligibilityRepository] isEnabled in
                isEnabled ? claimEligibilityRepository.checkClaimEligibility() : .just(false)
            }
            .asSingle()

        let majorProductBlocked = productsService
            .fetchProducts()
            .map { products in
                products
                    .first(where: { $0.reasonNotEligible?.reason == .eu5Sanction })?
                    .reasonNotEligible
            }
            .asSingle()

        let data = Single.zip(
            nabuUser,
            tiers,
            countries,
            authenticatorType,
            hasAnyWalletBalance,
            Single.zip(
                newAsset,
                assetRename,
                simpleBuy,
                sddEligibility,
                claimFreeDomainEligible,
                majorProductBlocked
            )
        )
        .map { payload -> AnnouncementPreliminaryData in
            let (
                user,
                tiers,
                countries,
                authenticatorType,
                hasAnyWalletBalance,
                (
                    newAsset,
                    assetRename,
                    simpleBuy,
                    isSDDEligible,
                    claimFreeDomainEligible,
                    majorProductBlocked
                )
            ) = payload
            return AnnouncementPreliminaryData(
                assetRename: assetRename,
                authenticatorType: authenticatorType,
                claimFreeDomainEligible: claimFreeDomainEligible,
                countries: countries,
                majorProductBlocked: majorProductBlocked,
                hasAnyWalletBalance: hasAnyWalletBalance,
                isSDDEligible: isSDDEligible,
                newAsset: newAsset,
                simpleBuy: simpleBuy,
                tiers: tiers,
                user: user
            )
        }

        return isWalletInitialized()
            .asSingle()
            .flatMap { isInitialized -> Single<AnnouncementPreliminaryData> in
                guard isInitialized else {
                    return .error(AnnouncementError.uninitializedWallet)
                }
                return data
            }
            .observe(on: MainScheduler.instance)
    }

    // MARK: - Private properties

    private let beneficiariesService: BeneficiariesServiceAPI
    private let claimEligibilityRepository: ClaimEligibilityRepositoryAPI
    private let coincore: CoincoreAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let featureFetcher: FeatureFetching
    private let infoService: GeneralInformationServiceAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI
    private let repository: AuthenticatorRepositoryAPI
    private let simpleBuyEligibilityService: EligibilityServiceAPI
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let tiersService: KYCTiersServiceAPI
    private let userService: NabuUserServiceAPI
    private let productsService: FeatureProductsDomain.ProductsServiceAPI
    private let wallet: WalletProtocol
    private let walletStateProvider: WalletStateProvider

    // MARK: - Setup

    init(
        beneficiariesService: BeneficiariesServiceAPI = resolve(),
        claimEligibilityRepository: ClaimEligibilityRepositoryAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        infoService: GeneralInformationServiceAPI = resolve(),
        pendingOrderDetailsService: PendingOrderDetailsServiceAPI = resolve(),
        repository: AuthenticatorRepositoryAPI = resolve(),
        simpleBuyEligibilityService: EligibilityServiceAPI = resolve(),
        supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
        tiersService: KYCTiersServiceAPI = resolve(),
        userService: NabuUserServiceAPI = resolve(),
        walletStateProvider: WalletStateProvider = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve(),
        wallet: WalletProtocol = WalletManager.shared.wallet
    ) {
        self.beneficiariesService = beneficiariesService
        self.claimEligibilityRepository = claimEligibilityRepository
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
        self.featureFetcher = featureFetcher
        self.infoService = infoService
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.repository = repository
        self.simpleBuyEligibilityService = simpleBuyEligibilityService
        self.supportedPairsInteractor = supportedPairsInteractor
        self.tiersService = tiersService
        self.userService = userService
        self.productsService = productsService
        self.wallet = wallet
        self.walletStateProvider = walletStateProvider
    }

    private func isWalletInitialized() -> AnyPublisher<Bool, Never> {
        nativeWalletFlagEnabled()
            .flatMap { [wallet, walletStateProvider] isEnabled -> AnyPublisher<Bool, Never> in
                guard isEnabled else {
                    return .just(wallet.isInitialized())
                }
                return walletStateProvider
                    .isWalletInitializedPublisher()
            }
            .eraseToAnyPublisher()
    }
}
