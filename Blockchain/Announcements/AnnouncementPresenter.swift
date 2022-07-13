// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import FeatureCryptoDomainDomain
import FeatureCryptoDomainUI
import FeatureDashboardUI
import FeatureKYCDomain
import FeatureNFTDomain
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import RxToolKit
import SwiftUI
import ToolKit
import UIComponentsKit
import WalletPayloadKit

/// Describes the announcement visual. Plays as a presenter / provide for announcements,
/// By creating a list of pending announcements, on which subscribers can be informed.
final class AnnouncementPresenter {

    // MARK: - Rx

    /// Returns a driver with `.none` as default value for announcement action
    /// Scheduled on be executed on main scheduler, its resources are shared and it remembers the last value.
    var announcement: Driver<AnnouncementDisplayAction> {
        announcementRelay
            .asDriver()
            .distinctUntilChanged()
    }

    // MARK: Services

    private let tabSwapping: TabSwapping
    private let walletOperating: WalletOperationsRouting
    private let backupFlowStarter: BackupFlowStarterAPI
    private let settingsStarter: SettingsStarterAPI

    private let app: AppProtocol
    private let featureFetcher: RxFeatureFetching
    private let cashIdentityVerificationRouter: CashIdentityVerificationAnnouncementRouting
    private let interestIdentityVerificationRouter: InterestIdentityVerificationAnnouncementRouting
    private let kycRouter: KYCRouterAPI
    private let wallet: Wallet
    private let kycSettings: KYCSettingsAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let interactor: AnnouncementInteracting
    private let webViewServiceAPI: WebViewServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let navigationRouter: NavigationRouterAPI
    private let exchangeProviding: ExchangeProviding
    private let accountsRouter: AccountsRouting
    private let viewWaitlistRegistration: ViewWaitlistRegistrationRepositoryAPI

    private let coincore: CoincoreAPI
    private let nabuUserService: NabuUserServiceAPI

    private let announcementRelay = BehaviorRelay<AnnouncementDisplayAction>(value: .hide)
    private let disposeBag = DisposeBag()

    private var currentAnnouncement: Announcement?

    // Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    init(
        app: AppProtocol = DIKit.resolve(),
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        exchangeProviding: ExchangeProviding = DIKit.resolve(),
        accountsRouter: AccountsRouting = DIKit.resolve(),
        interactor: AnnouncementInteracting = AnnouncementInteractor(),
        topMostViewControllerProvider: TopMostViewControllerProviding = DIKit.resolve(),
        featureFetcher: RxFeatureFetching = DIKit.resolve(),
        cashIdentityVerificationRouter: CashIdentityVerificationAnnouncementRouting = DIKit.resolve(),
        interestIdentityVerificationRouter: InterestIdentityVerificationAnnouncementRouting = DIKit.resolve(),
        tabSwapping: TabSwapping = DIKit.resolve(),
        walletOperating: WalletOperationsRouting = DIKit.resolve(),
        backupFlowStarter: BackupFlowStarterAPI = DIKit.resolve(),
        settingsStarter: SettingsStarterAPI = DIKit.resolve(),
        kycRouter: KYCRouterAPI = DIKit.resolve(),
        reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet,
        kycSettings: KYCSettingsAPI = DIKit.resolve(),
        webViewServiceAPI: WebViewServiceAPI = DIKit.resolve(),
        viewWaitlistRegistration: ViewWaitlistRegistrationRepositoryAPI = DIKit.resolve(),
        wallet: Wallet = WalletManager.shared.wallet,
        analyticsRecorder: AnalyticsEventRecorderAPI = DIKit.resolve(),
        coincore: CoincoreAPI = DIKit.resolve(),
        nabuUserService: NabuUserServiceAPI = DIKit.resolve()
    ) {
        self.app = app
        self.interactor = interactor
        self.viewWaitlistRegistration = viewWaitlistRegistration
        self.webViewServiceAPI = webViewServiceAPI
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.interestIdentityVerificationRouter = interestIdentityVerificationRouter
        self.cashIdentityVerificationRouter = cashIdentityVerificationRouter
        self.kycRouter = kycRouter
        self.reactiveWallet = reactiveWallet
        self.kycSettings = kycSettings
        self.featureFetcher = featureFetcher
        self.wallet = wallet
        self.analyticsRecorder = analyticsRecorder
        self.tabSwapping = tabSwapping
        self.walletOperating = walletOperating
        self.backupFlowStarter = backupFlowStarter
        self.settingsStarter = settingsStarter
        self.navigationRouter = navigationRouter
        self.exchangeProviding = exchangeProviding
        self.accountsRouter = accountsRouter
        self.coincore = coincore
        self.nabuUserService = nabuUserService

        announcement
            .asObservable()
            .filter(\.isHide)
            .mapToVoid()
            .bindAndCatch(weak: self) { (self) in
                self.currentAnnouncement = nil
            }
            .disposed(by: disposeBag)
    }

    /// Refreshes announcements on demand
    func refresh() {
        reactiveWallet
            .waitUntilInitialized
            .asObservable()
            .bind { [weak self] _ in
                self?.calculate()
            }
            .disposed(by: disposeBag)
    }

    private func calculate() {
        let announcementsMetadata = featureFetcher
            .fetch(for: .announcements, as: AnnouncementsMetadata.self)
        let data: Single<AnnouncementPreliminaryData> = interactor.preliminaryData
            .delaySubscription(.seconds(10), scheduler: MainScheduler.asyncInstance)
        Single
            .zip(announcementsMetadata, data)
            .flatMap(weak: self) { (self, payload) -> Single<AnnouncementDisplayAction> in
                let action = self.resolve(metadata: payload.0, preliminaryData: payload.1)
                return .just(action)
            }
            .catchAndReturn(.hide)
            .asObservable()
            .bindAndCatch(to: announcementRelay)
            .disposed(by: disposeBag)
    }

    /// Resolves the first valid announcement according by the provided types and preliminary data
    // swiftlint:disable:next cyclomatic_complexity
    private func resolve(
        metadata: AnnouncementsMetadata,
        preliminaryData: AnnouncementPreliminaryData
    ) -> AnnouncementDisplayAction {
        // For other users, keep the current logic in place
        for type in metadata.order {
            // Wallets with no balance should show no announcements
            guard preliminaryData.hasAnyWalletBalance || type.showsWhenWalletHasNoBalance else {
                return .none
            }

            let announcement: Announcement
            switch type {
            case .majorProductBlocked:
                let reason = preliminaryData.majorProductBlocked
                announcement = majorProductBlocked(reason)
            case .claimFreeCryptoDomain:
                announcement = claimFreeCryptoDomainAnnouncement(
                    claimFreeDomainEligible: preliminaryData.claimFreeDomainEligible
                )
            case .resubmitDocumentsAfterRecovery:
                announcement = resubmitDocumentsAfterRecovery(user: preliminaryData.user)
            case .sddUsersFirstBuy:
                announcement = sddUsersFirstBuy(
                    tiers: preliminaryData.tiers,
                    isSDDEligible: preliminaryData.isSDDEligible,
                    hasAnyWalletBalance: preliminaryData.hasAnyWalletBalance,
                    reappearanceTimeInterval: metadata.interval
                )
            case .cloudBackup:
                announcement = cloudBackupAnnouncement
            case .interestFunds:
                announcement = interestAnnouncement(isKYCVerified: preliminaryData.tiers.isTier2Approved)
            case .fiatFundsNoKYC:
                announcement = cashAnnouncement(isKYCVerified: preliminaryData.tiers.isTier2Approved)
            case .fiatFundsKYC:
                announcement = fiatFundsLinkBank(
                    isKYCVerified: preliminaryData.tiers.isTier2Approved,
                    hasLinkedBanks: preliminaryData.simpleBuy.hasLinkedBanks
                )
            case .verifyEmail:
                announcement = verifyEmail(
                    user: preliminaryData.user,
                    reappearanceTimeInterval: metadata.interval
                )
            case .twoFA:
                announcement = twoFA(data: preliminaryData, reappearanceTimeInterval: metadata.interval)
            case .backupFunds:
                announcement = backupFunds(reappearanceTimeInterval: metadata.interval)
            case .buyBitcoin:
                announcement = buyBitcoin(reappearanceTimeInterval: metadata.interval)
            case .transferBitcoin:
                announcement = transferBitcoin(
                    isKycSupported: preliminaryData.isKycSupported,
                    reappearanceTimeInterval: metadata.interval
                )
            case .verifyIdentity:
                announcement = verifyIdentity(using: preliminaryData.user)
            case .bitpay:
                announcement = bitpay
            case .viewNFTWaitlist:
                announcement = viewNFTComingSoonAnnouncement()
            case .resubmitDocuments:
                announcement = resubmitDocuments(user: preliminaryData.user)
            case .simpleBuyKYCIncomplete:
                announcement = simpleBuyFinishSignup(
                    tiers: preliminaryData.tiers,
                    hasIncompleteBuyFlow: preliminaryData.hasIncompleteBuyFlow,
                    reappearanceTimeInterval: metadata.interval
                )
            case .newSwap:
                announcement = newSwap(using: preliminaryData, reappearanceTimeInterval: metadata.interval)
            case .newAsset:
                announcement = newAsset(cryptoCurrency: preliminaryData.newAsset)
            case .assetRename:
                announcement = assetRename(
                    data: preliminaryData.assetRename
                )
            case .ukEntitySwitch:
                announcement = ukEntitySwitch(user: preliminaryData.user)
            case .walletConnect:
                announcement = walletConnect()
            case .applePay:
                announcement = applePay()
            case .taxCenter:
                announcement = taxCenter(
                    userCountry: preliminaryData.user.address?.country,
                    reappearanceTimeInterval: metadata.interval
                )
            }

            // Return the first different announcement that should show
            if announcement.shouldShow {
                if currentAnnouncement?.type != announcement.type {
                    currentAnnouncement = announcement
                    return .show(announcement.viewModel)
                } else { // Announcement is currently displaying
                    return .none
                }
            }
        }
        // None of the types were resolved into a displayable announcement
        return .none
    }

    // MARK: - Private Helpers

    /// Hides whichever announcement is now displaying
    private var announcementDismissAction: CardAnnouncementAction {
        { [weak self] in
            self?.announcementRelay.accept(.hide)
        }
    }

    private func actionForOpening(_ absoluteURL: String) -> CardAnnouncementAction {
        { [weak self] in
            guard let destination = self?.topMostViewControllerProvider.topMostViewController else {
                return
            }
            self?.webViewServiceAPI.openSafari(
                url: absoluteURL,
                from: destination
            )
        }
    }
}

extension AnnouncementType {
    var showsWhenWalletHasNoBalance: Bool {
        switch self {
        case .claimFreeCryptoDomain,
             .ukEntitySwitch:
            return true
        default:
            return false
        }
    }
}

// MARK: - Computes announcements

extension AnnouncementPresenter {

    /// Computes email verification announcement
    private func verifyEmail(
        user: NabuUser,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        VerifyEmailAnnouncement(
            isEmailVerified: user.email.verified,
            reappearanceTimeInterval: reappearanceTimeInterval,
            action: UIApplication.shared.openMailApplication,
            dismiss: announcementDismissAction
        )
    }

    /// Computes Simple Buy Finish Signup Announcement
    private func simpleBuyFinishSignup(
        tiers: KYC.UserTiers,
        hasIncompleteBuyFlow: Bool,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        SimpleBuyFinishSignupAnnouncement(
            canCompleteTier2: tiers.canCompleteTier2,
            hasIncompleteBuyFlow: hasIncompleteBuyFlow,
            reappearanceTimeInterval: reappearanceTimeInterval,
            action: { [weak self] in
                guard let self = self else { return }
                self.announcementDismissAction()
                self.handleBuyCrypto()
            },
            dismiss: announcementDismissAction
        )
    }

    // Computes transfer in bitcoin announcement
    private func transferBitcoin(isKycSupported: Bool, reappearanceTimeInterval: TimeInterval) -> Announcement {
        TransferInCryptoAnnouncement(
            isKycSupported: isKycSupported,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                guard let self = self else { return }
                self.announcementDismissAction()
                self.tabSwapping.switchTabToReceive()
            }
        )
    }

    /// Computes identity verification card announcement
    private func verifyIdentity(using user: NabuUser) -> Announcement {
        VerifyIdentityAnnouncement(
            isCompletingKyc: kycSettings.isCompletingKyc,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .announcement,
                    from: self.tabSwapping
                )
            }
        )
    }

    /// Computes Major Product Blocked announcement
    private func majorProductBlocked(_ reason: ProductIneligibility?) -> Announcement {
        MajorProductBlockedAnnouncement(
            announcementMessage: reason?.message,
            dismiss: announcementDismissAction,
            action: { [actionForOpening] in
                if let learnMoreURL = reason?.learnMoreUrl {
                    return actionForOpening(learnMoreURL.absoluteString)
                }
                return {}
            }(),
            showLearnMoreButton: reason?.learnMoreUrl != nil
        )
    }

    /// Computes Bitpay announcement
    private var bitpay: Announcement {
        BitpayAnnouncement(
            dismiss: announcementDismissAction
        )
    }

    private func showCoinView(for currency: CryptoCurrency) {
        app.post(
            event: blockchain.ux.asset[currency.code].select,
            context: [blockchain.ux.asset.select.origin: "ANNOUNCEMENT"]
        )
    }

    /// Computes asset rename card announcement.
    private func assetRename(
        data: AnnouncementPreliminaryData.AssetRename?
    ) -> Announcement {
        AssetRenameAnnouncement(
            data: data,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                guard let asset = data?.asset else {
                    return
                }
                self?.showCoinView(for: asset)
            }
        )
    }

    private func ukEntitySwitch(user: NabuUser) -> Announcement {
        UKEntitySwitchAnnouncement(
            userCountry: user.address?.country,
            dismiss: announcementDismissAction,
            action: actionForOpening("https://support.blockchain.com/hc/en-us/articles/4418431131668")
        )
    }

    private func walletConnect() -> Announcement {
        let absolutURL = "https://medium.com/blockchain/" +
            "introducing-walletconnect-access-web3-from-your-blockchain-com-wallet-da02e49ccea9"
        return WalletConnectAnnouncement(
            dismiss: announcementDismissAction,
            action: actionForOpening(absolutURL)
        )
    }

    private func applePay() -> Announcement {
        ApplePayAnnouncement(
            dismiss: announcementDismissAction,
            action: { [weak self] in
                self?.app.state.set(blockchain.ux.transaction.previous.payment.method.id, to: "APPLE_PAY")
                self?.handleBuyCrypto(currency: .bitcoin)
            }
        )
    }

    private func taxCenter(
        userCountry: Country?,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        TaxCenterAnnouncement(
            userCountry: userCountry,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: announcementDismissAction
        )
    }

    /// Computes new asset card announcement.
    private func newAsset(cryptoCurrency: CryptoCurrency?) -> Announcement {
        NewAssetAnnouncement(
            cryptoCurrency: cryptoCurrency,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                guard let cryptoCurrency = cryptoCurrency else {
                    return
                }
                self?.handleBuyCrypto(currency: cryptoCurrency)
            }
        )
    }

    /// Cash Support Announcement for users who have not KYC'd
    private func cashAnnouncement(isKYCVerified: Bool) -> Announcement {
        CashIdentityVerificationAnnouncement(
            shouldShowCashIdentityAnnouncement: !isKYCVerified,
            dismiss: announcementDismissAction,
            action: { [weak cashIdentityVerificationRouter] in
                cashIdentityVerificationRouter?.showCashIdentityVerificationScreen()
            }
        )
    }

    /// Cash Support Announcement for users who have not KYC'd
    private var cloudBackupAnnouncement: Announcement {
        CloudBackupAnnouncement(
            dismiss: announcementDismissAction,
            action: actionForOpening("https://support.blockchain.com/hc/en-us/articles/360046143432")
        )
    }

    /// Claim Free Crypto Domain Announcement for eligible users
    private func claimFreeCryptoDomainAnnouncement(
        claimFreeDomainEligible: Bool
    ) -> Announcement {
        ClaimFreeCryptoDomainAnnouncement(
            claimFreeDomainEligible: claimFreeDomainEligible,
            action: { [weak self] in
                self?.presentClaimIntroductionHostingController()
            },
            dismiss: announcementDismissAction
        )
    }

    private func registerEmailForNFTViewWaitlist() {
        viewWaitlistRegistration
            .registerEmailForNFTViewWaitlist()
            .sink(receiveCompletion: { [analyticsRecorder] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case .emailUnavailable:
                        analyticsRecorder
                            .record(
                                event: ClientEvent.clientError(
                                    error: "VIEW_NFT_WAITLIST_EMAIL_ERROR",
                                    source: "WALLET",
                                    title: "",
                                    action: "ANNOUNCEMENT"
                                )
                            )
                    case .network(let nabuNetworkError):
                        Logger.shared.error("\(error)")
                        analyticsRecorder
                            .record(
                                event: ClientEvent.clientError(
                                    error: "VIEW_NFT_WAITLIST_REGISTRATION_ERROR",
                                    networkEndpoint: nabuNetworkError.request?.url?.absoluteString ?? "",
                                    networkErrorCode: "\(nabuNetworkError.code)",
                                    networkErrorDescription: nabuNetworkError.description,
                                    networkErrorId: nil,
                                    networkErrorType: nabuNetworkError.type.rawValue,
                                    source: "EXPLORER",
                                    title: "",
                                    action: "ANNOUNCEMENT"
                                )
                            )
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    private func presentClaimIntroductionHostingController() {
        let vc = ClaimIntroductionHostingController(
            mainQueue: .main,
            analyticsRecorder: DIKit.resolve(),
            externalAppOpener: DIKit.resolve(),
            searchDomainRepository: DIKit.resolve(),
            orderDomainRepository: DIKit.resolve(),
            userInfoProvider: { [coincore, nabuUserService] in
                Deferred { [coincore] in
                    Just([coincore[.ethereum], coincore[.bitcoin], coincore[.bitcoinCash], coincore[.stellar]])
                }
                .eraseError()
                .flatMap { [nabuUserService] cryptoAssets -> AnyPublisher<([ResolutionRecord], NabuUser), Error> in
                    guard let providers = cryptoAssets as? [DomainResolutionRecordProviderAPI] else {
                        return .empty()
                    }
                    let recordPublisher = providers.map(\.resolutionRecord).zip()
                    let nabuUserPublisher = nabuUserService.user.eraseError()
                    return recordPublisher
                        .zip(nabuUserPublisher)
                        .eraseToAnyPublisher()
                }
                .map { records, nabuUser -> OrderDomainUserInfo in
                    OrderDomainUserInfo(
                        nabuUserId: nabuUser.identifier,
                        nabuUserName: nabuUser
                            .personalDetails
                            .firstName?
                            .replacingOccurrences(of: " ", with: "") ?? "",
                        resolutionRecords: records
                    )
                }
                .eraseToAnyPublisher()
            }
        )
        let nav = UINavigationController(rootViewController: vc)
        navigationRouter.present(viewController: nav, using: .modalOverTopMost)
    }

    /// Interest Account Announcement for users who have not KYC'd
    private func interestAnnouncement(isKYCVerified: Bool) -> Announcement {
        InterestIdentityVerificationAnnouncement(
            isKYCVerified: isKYCVerified,
            dismiss: announcementDismissAction,
            action: { [weak interestIdentityVerificationRouter] in
                interestIdentityVerificationRouter?.showInterestDashboardAnnouncementScreen(isKYCVerfied: isKYCVerified)
            }
        )
    }

    /// Cash Support Announcement for users who have KYC'd
    /// and have not linked a bank.
    private func fiatFundsLinkBank(isKYCVerified: Bool, hasLinkedBanks: Bool) -> Announcement {
        FiatFundsLinkBankAnnouncement(
            shouldShowLinkBankAnnouncement: false, // TODO: remove `false` and uncomment this: isKYCVerified && !hasLinkedBanks,
            dismiss: announcementDismissAction,
            action: {
                // TODO: Route to bank linking
            }
        )
    }

    /// Computes SDD Users Buy announcement
    private func sddUsersFirstBuy(
        tiers: KYC.UserTiers,
        isSDDEligible: Bool,
        hasAnyWalletBalance: Bool,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        // For now, we want to target non-KYCed SDD eligible users specifically, but we're going to review all announcements soon for Onboarding
        BuyBitcoinAnnouncement(
            isEnabled: tiers.isTier0 && isSDDEligible && !hasAnyWalletBalance,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                self?.handleBuyCrypto(currency: .bitcoin)
            }
        )
    }

    /// Computes Buy BTC announcement
    private func buyBitcoin(reappearanceTimeInterval: TimeInterval) -> Announcement {
        BuyBitcoinAnnouncement(
            isEnabled: !wallet.isBitcoinWalletFunded,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                self?.handleBuyCrypto(currency: .bitcoin)
            }
        )
    }

    /// Computes Swap card announcement
    private func newSwap(
        using data: AnnouncementPreliminaryData,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        NewSwapAnnouncement(
            isEligibleForSimpleBuy: data.simpleBuy.isEligible,
            isTier1Or2Verified: data.tiers.isTier1Approved || data.tiers.isTier2Approved,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                self?.tabSwapping.switchTabToSwap()
                self?.analyticsRecorder.record(event: AnalyticsEvents.New.Swap.swapClicked(origin: .dashboardPromo))
            }
        )
    }

    /// Computes Backup Funds (recovery phrase)
    private func backupFunds(reappearanceTimeInterval: TimeInterval) -> Announcement {
        let shouldBackupFunds = !wallet.isRecoveryPhraseVerified() && wallet.isBitcoinWalletFunded
        return BackupFundsAnnouncement(
            shouldBackupFunds: shouldBackupFunds,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                self?.backupFlowStarter.startBackupFlow()
            }
        )
    }

    /// Computes 2FA announcement
    private func twoFA(data: AnnouncementPreliminaryData, reappearanceTimeInterval: TimeInterval) -> Announcement {
        let shouldEnable2FA = !data.hasTwoFA && wallet.isBitcoinWalletFunded
        return Enable2FAAnnouncement(
            shouldEnable2FA: shouldEnable2FA,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                self?.settingsStarter.showSettingsView()
            }
        )
    }

    private func viewNFTComingSoonAnnouncement() -> Announcement {
        ViewNFTComingSoonAnnouncement(
            dismiss: announcementDismissAction,
            action: { [weak self] in
                guard let self = self else { return }
                self.registerEmailForNFTViewWaitlist()
            }
        )
    }

    /// Computes Upload Documents card announcement
    private func resubmitDocuments(user: NabuUser) -> Announcement {
        ResubmitDocumentsAnnouncement(
            needsDocumentResubmission: user.needsDocumentResubmission != nil
                && user.needsDocumentResubmission?.reason != 1,
            dismiss: announcementDismissAction,
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .announcement,
                    from: self.tabSwapping
                )
            }
        )
    }

    private func resubmitDocumentsAfterRecovery(user: NabuUser) -> Announcement {
        ResubmitDocumentsAfterRecoveryAnnouncement(
            // reason 1: resubmission needed due to account recovery
            needsDocumentResubmission: user.needsDocumentResubmission?.reason == 1,
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .announcement,
                    from: self.tabSwapping
                )
            }
        )
    }
}

extension AnnouncementPresenter {
    private func handleBuyCrypto(currency: CryptoCurrency = .bitcoin) {
        walletOperating.handleBuyCrypto(currency: currency)
        analyticsRecorder.record(
            event: AnalyticsEvents.New.SimpleBuy.buySellClicked(type: .buy, origin: .dashboardPromo)
        )
    }
}
