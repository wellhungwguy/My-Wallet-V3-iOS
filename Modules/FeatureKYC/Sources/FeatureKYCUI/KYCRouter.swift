// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureFormDomain
import FeatureKYCDomain
import Localization
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit
import UIComponentsKit
import UIKit

enum KYCEvent {

    /// When a particular screen appears, we need to
    /// look at the `NabuUser` object and determine if
    /// there is data there for pre-populate the screen with.
    case pageWillAppear(KYCPageType)

    /// This will push on the next page in the KYC flow.
    case nextPageFromPageType(KYCPageType, KYCPagePayload?)

    /// Event emitted when the provided page type emits an error
    case failurePageForPageType(KYCPageType, KYCPageError)
}

protocol KYCRouterDelegate: AnyObject {
    func apply(model: KYCPageModel)
}

// swiftlint:disable type_body_length

/// Coordinates the KYC flow. This component can be used to start a new KYC flow, or if
/// the user drops off mid-KYC and decides to continue through it again, the coordinator
/// will handle recovering where they left off.
final class KYCRouter: KYCRouterAPI {

    // MARK: - Public Properties

    weak var delegate: KYCRouterDelegate?

    // MARK: - Private Properties

    private(set) var user: NabuUser?

    private(set) var country: CountryData?

    private(set) var states: [KYCState] = []

    private var pager: KYCPagerAPI!

    private weak var rootViewController: UIViewController?

    private var navController: KYCOnboardingNavigationController!

    private let disposables = CompositeDisposable()

    private let disposeBag = DisposeBag()

    private let pageFactory = KYCPageViewFactory()

    private let appSettings: AppSettingsAPI
    private let loadingViewPresenter: LoadingViewPresenting

    private let app: AppProtocol
    private var userTiersResponse: KYC.UserTiers?
    private var kycSettings: KYCSettingsAPI

    private let tiersService: KYCTiersServiceAPI
    private let networkAdapter: NetworkAdapterAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let nabuUserService: NabuUserServiceAPI
    private let requestBuilder: RequestBuilder

    private let webViewServiceAPI: WebViewServiceAPI

    private let kycStoppedRelay = PublishRelay<Void>()
    private let kycFinishedRelay = PublishRelay<KYC.Tier>()

    private var parentFlow: KYCParentFlow?

    private var errorRecorder: ErrorRecording
    private var alertPresenter: AlertViewPresenterAPI

    /// KYC finsihed with `tier1` in-progress / approved
    var tier1Finished: Observable<Void> {
        kycFinishedRelay
            .filter { $0 == .tier1 }
            .mapToVoid()
    }

    /// KYC finsihed with `tier2` in-progress / approved
    var tier2Finished: Observable<Void> {
        kycFinishedRelay
            .filter { $0 == .tier2 }
            .mapToVoid()
    }

    var kycFinished: Observable<KYC.Tier> {
        kycFinishedRelay.asObservable()
    }

    var kycStopped: Observable<Void> {
        kycStoppedRelay.asObservable()
    }

    init(
        app: AppProtocol = resolve(),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail),
        webViewServiceAPI: WebViewServiceAPI = resolve(),
        tiersService: KYCTiersServiceAPI = resolve(),
        appSettings: AppSettingsAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        alertPresenter: AlertViewPresenterAPI = resolve(),
        nabuUserService: NabuUserServiceAPI = resolve(),
        kycSettings: KYCSettingsAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail)
    ) {
        self.app = app
        self.requestBuilder = requestBuilder
        self.errorRecorder = errorRecorder
        self.alertPresenter = alertPresenter
        self.analyticsRecorder = analyticsRecorder
        self.nabuUserService = nabuUserService
        self.webViewServiceAPI = webViewServiceAPI
        self.tiersService = tiersService
        self.appSettings = appSettings
        self.kycSettings = kycSettings
        self.loadingViewPresenter = loadingViewPresenter
        self.networkAdapter = networkAdapter
    }

    deinit {
        disposables.dispose()
    }

    // MARK: Public

    func start(parentFlow: KYCParentFlow) {
        start(tier: .tier2, parentFlow: parentFlow, from: nil)
    }

    func start(tier: KYC.Tier, parentFlow: KYCParentFlow) {
        start(tier: tier, parentFlow: parentFlow, from: nil)
    }

    func start(
        tier: KYC.Tier,
        parentFlow: KYCParentFlow,
        from viewController: UIViewController?
    ) {
        self.parentFlow = parentFlow
        guard let viewController = viewController ?? UIApplication.shared.topMostViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        rootViewController = viewController

        app.post(
            event: blockchain.ux.kyc.event.did.start,
            context: [
                blockchain.ux.kyc.tier: {
                    switch tier {
                    case .tier0:
                        return blockchain.ux.kyc.tier.none[]
                    case .tier1:
                        return blockchain.ux.kyc.tier.silver[]
                    case .tier2:
                        return blockchain.ux.kyc.tier.gold[]
                    }
                }()
            ]
        )

        switch tier {
        case .tier0:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycTier0Start)
        case .tier1:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycTier1Start)
        case .tier2:
            analyticsRecorder.record(event: AnalyticsEvents.KYC.kycTier2Start)
            analyticsRecorder.record(
                event: AnalyticsEvents.New.Onboarding.upgradeVerificationClicked(
                    origin: .init(parentFlow),
                    tier: tier.rawValue
                )
            )
        }

        loadingViewPresenter.show(with: LocalizationConstants.loading)

        let postTierObservable = post(tier: tier).asObservable()
            .flatMap { [tiersService] tiersResponse in
                Observable.zip(
                    Observable.just(tiersResponse),
                    tiersService
                        .checkSimplifiedDueDiligenceEligibility(for: tiersResponse.latestApprovedTier)
                        .asObservable(),
                    tiersService
                        .checkSimplifiedDueDiligenceVerification(
                            for: tiersResponse.latestApprovedTier,
                            pollUntilComplete: false
                        )
                        .asObservable()
                )
            }

        let disposable = Observable
            .zip(
                nabuUserService.fetchUser().asObservable(),
                postTierObservable
            )
            .subscribe(on: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .hideLoaderOnDisposal(loader: loadingViewPresenter)
            .subscribe(onNext: { [weak self] user, tiersTuple in
                let (tiersResponse, isSDDEligible, isSDDVerified) = tiersTuple
                self?.pager = KYCPager(tier: tier, tiersResponse: tiersResponse)
                Logger.shared.debug("Got user with ID: \(user.personalDetails.identifier ?? "")")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.userTiersResponse = tiersResponse
                strongSelf.user = user

                // SDD Eligible users can buy but we only need to check for SDD during the buy flow.
                // This is to avoid breaking Tier 2 upgrade paths (e.g., from Settings)
                let shouldUseSDDFlags = tier < .tier2 && parentFlow == .simpleBuy
                let shouldCheckForSDDEligibility = shouldUseSDDFlags ? isSDDEligible : false
                let shouldCheckForSDDVerification = shouldUseSDDFlags ? isSDDVerified : false

                let startingPage = KYCPageType.startingPage(
                    forUser: user,
                    requiredTier: tier,
                    tiersResponse: tiersResponse,
                    isSDDEligible: shouldCheckForSDDEligibility,
                    isSDDVerified: shouldCheckForSDDVerification,
                    hasQuestions: strongSelf.hasQuestions
                )

                if startingPage != .accountStatus {
                    /// If the starting page is accountStatus, they do not have any additional
                    /// pages to view, so we don't want to set `isCompletingKyc` to `true`.
                    strongSelf.kycSettings.isCompletingKyc = true
                }

                strongSelf.initializeNavigationStack(
                    viewController,
                    user: user,
                    tier: tier,
                    isSDDEligible: shouldCheckForSDDEligibility,
                    isSDDVerified: shouldCheckForSDDVerification
                )
                strongSelf.restoreToMostRecentPageIfNeeded(
                    tier: tier,
                    isSDDEligible: isSDDEligible,
                    isSDDVerified: shouldCheckForSDDVerification
                )
            }, onError: { [alertPresenter, errorRecorder] error in
                Logger.shared.error("Failed to get user: \(String(describing: error))")
                errorRecorder.error(error)
                alertPresenter.notify(
                    content: .init(
                        title: LocalizationConstants.KYC.Errors.cannotFetchUserAlertTitle,
                        message: String(describing: error)
                    ),
                    in: viewController
                )
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    // Called when the entire KYC process has been completed.
    func finish() {
        dismiss { [app, tiersService, kycFinishedRelay, disposeBag] in
            tiersService.fetchTiers()
                .asObservable()
                .map(\.latestApprovedTier)
                .catchAndReturn(.tier0)
                .bindAndCatch(to: kycFinishedRelay)
                .disposed(by: disposeBag)
            NotificationCenter.default.post(
                name: Constants.NotificationKeys.kycFinished,
                object: nil
            )
            NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
            app.post(event: blockchain.ux.kyc.event.did.finish)
            app.post(event: blockchain.ux.kyc.event.status.did.change)
        }
    }

    // Called when the KYC process is stopped before completing.
    func stop() {
        dismiss { [app, kycStoppedRelay] in
            kycStoppedRelay.accept(())
            NotificationCenter.default.post(
                name: Constants.NotificationKeys.kycStopped,
                object: nil
            )
            NotificationCenter.default.post(name: .kycStatusChanged, object: nil)
            app.post(event: blockchain.ux.kyc.event.did.cancel)
            app.post(event: blockchain.ux.kyc.event.status.did.change)
        }
    }

    private func dismiss(completion: @escaping () -> Void) {
        guard navController != nil else {
            completion()
            return
        }
        navController.dismiss(animated: true, completion: completion)
    }

    func handle(event: KYCEvent) {
        switch event {
        case .pageWillAppear(let type):
            handlePageWillAppear(for: type)
        case .failurePageForPageType(_, let error):
            handleFailurePage(for: error)
        case .nextPageFromPageType(let type, let payload):
            handlePayloadFromPageType(type, payload)
            let disposable = pager.nextPage(from: type, payload: payload)
                .subscribe(on: MainScheduler.asyncInstance)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] nextPage in
                    guard let self = self else {
                        return
                    }

                    switch (self.parentFlow, nextPage) {
                    case (.simpleBuy, .accountStatus):
                        self.finish()
                        return
                    default:
                        break
                    }

                    let controller = self.pageFactory.createFrom(
                        pageType: nextPage,
                        in: self,
                        payload: payload
                    )

                    if let informationController = controller as? KYCInformationController, nextPage == .accountStatus {
                        self.presentInformationController(informationController)
                    } else {
                        self.navController.pushViewController(controller, animated: true)
                    }
                }, onError: { error in
                    Logger.shared.error("Error getting next page: \(String(describing: error))")
                }, onCompleted: { [weak self] in
                    Logger.shared.info("No more next pages")
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.kycSettings.isCompletingKyc = false
                    strongSelf.finish()
                })
            disposables.insertWithDiscardableResult(disposable)
        }
    }

    func presentInformationController(_ controller: KYCInformationController) {
        /// Refresh the user's tiers to get their status.
        /// Sometimes we receive an `INTERNAL_SERVER_ERROR` if we refresh this
        /// immediately after submitting all KYC data. So, we apply a delay here.
        tiersService.tiers
            .asSingle()
            .handleLoaderForLifecycle(loader: loadingViewPresenter)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let self = self else { return }
                    let status = response.tierAccountStatus(for: .tier2)

                    controller.viewModel = KYCInformationViewModel.create(
                        for: status,
                        isReceivingAirdrop: false
                    )
                    controller.viewConfig = KYCInformationViewConfig.create(
                        for: status,
                        isReceivingAirdrop: false
                    )
                    controller.primaryButtonAction = { _ in
                        switch status {
                        case .approved:
                            self.finish()
                        case .pending:
                            break
                        case .failed, .expired:
                            if let blockchainSupportURL = URL(string: Constants.Url.blockchainSupport) {
                                UIApplication.shared.open(blockchainSupportURL)
                            }
                        case .none, .underReview:
                            return
                        }
                    }

                    self.navController.pushViewController(controller, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }

    var hasQuestions: Bool {
        (try? app.state.get(blockchain.ux.kyc.extra.questions.form.is.empty)) == false
    }

    // MARK: View Restoration

    /// Restores the user to the most recent page if they dropped off mid-flow while KYC'ing
    private func restoreToMostRecentPageIfNeeded(tier: KYC.Tier, isSDDEligible: Bool, isSDDVerified: Bool) {
        guard let currentUser = user else {
            return
        }
        guard let response = userTiersResponse else { return }

        let latestPage = kycSettings.latestKycPage

        let startingPage = KYCPageType.startingPage(
            forUser: currentUser,
            requiredTier: tier,
            tiersResponse: response,
            isSDDEligible: isSDDEligible,
            isSDDVerified: isSDDVerified,
            hasQuestions: hasQuestions
        )

        if startingPage == .accountStatus {
            /// The `tier` on KYCPager cannot be `tier1` if the user's `startingPage` is `.accountStatus`.
            /// If their `startingPage` is `.accountStatus`, they're done.
            pager = KYCPager(tier: .tier2, tiersResponse: response)
        }

        guard let endPageForLastUsedTier = KYCPageType.pageType(
            for: currentUser,
            tiersResponse: response,
            latestPage: latestPage
        ) else {
            return
        }

        // If a user has moved to a new tier, they need to use the starting page for the new tier
        let endPage = endPageForLastUsedTier.rawValue >= startingPage.rawValue ? endPageForLastUsedTier : startingPage

        var currentPage = startingPage
        while currentPage != endPage {
            guard let nextPage = currentPage.nextPage(
                forTier: tier,
                user: user,
                country: country,
                tiersResponse: response
            ) else { return }

            currentPage = nextPage

            let nextController = pageFactory.createFrom(
                pageType: currentPage,
                in: self,
                payload: createPagePayload(page: currentPage, user: currentUser)
            )

            navController.pushViewController(nextController, animated: false)
        }
    }

    private func createPagePayload(page: KYCPageType, user: NabuUser) -> KYCPagePayload? {
        switch page {
        case .confirmPhone:
            return .phoneNumberUpdated(phoneNumber: user.mobile?.phone ?? "")
        case .confirmEmail:
            return .emailPendingVerification(email: user.email.address)
        case .accountStatus:
            guard let response = userTiersResponse else { return nil }
            return .accountStatus(
                status: response.tierAccountStatus(for: .tier2),
                isReceivingAirdrop: false
            )
        case .enterEmail,
             .welcome,
             .country,
             .states,
             .profile,
             .address,
             .accountUsageForm,
             .sddVerificationCheck,
             .tier1ForcedTier2,
             .enterPhone,
             .verifyIdentity,
             .resubmitIdentity,
             .applicationComplete:
            return nil
        }
    }

    private func initializeNavigationStack(
        _ viewController: UIViewController,
        user: NabuUser,
        tier: KYC.Tier,
        isSDDEligible: Bool,
        isSDDVerified: Bool
    ) {
        guard let response = userTiersResponse else { return }
        let startingPage = KYCPageType.startingPage(
            forUser: user,
            requiredTier: tier,
            tiersResponse: response,
            isSDDEligible: isSDDEligible,
            isSDDVerified: isSDDVerified,
            hasQuestions: hasQuestions
        )
        var controller: KYCBaseViewController
        if startingPage == .accountStatus {
            controller = pageFactory.createFrom(
                pageType: startingPage,
                in: self,
                payload: .accountStatus(
                    status: response.tierAccountStatus(for: .tier2),
                    isReceivingAirdrop: false
                )
            )
        } else {
            controller = pageFactory.createFrom(
                pageType: startingPage,
                in: self
            )
        }

        navController = presentInNavigationController(controller, in: viewController)
    }

    // MARK: Private Methods

    private func handlePayloadFromPageType(_ pageType: KYCPageType, _ payload: KYCPagePayload?) {
        guard let payload = payload else { return }
        switch payload {
        case .countrySelected(let country):
            self.country = country
        case .stateSelected(_, let states):
            self.states = states
        case .phoneNumberUpdated,
             .emailPendingVerification,
             .sddVerification,
             .accountStatus:
            // Not handled here
            return
        }
    }

    private func handleFailurePage(for error: KYCPageError) {

        let informationViewController = KYCInformationController.make(with: self)
        informationViewController.viewConfig = KYCInformationViewConfig(
            titleColor: UIColor.gray5,
            isPrimaryButtonEnabled: true,
            imageTintColor: nil
        )

        switch error {
        case .countryNotSupported(let country):
            kycSettings.isCompletingKyc = false
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedCountry(country)
            informationViewController.primaryButtonAction = { [unowned self] viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
                let interactor = KYCCountrySelectionInteractor()
                let disposable = interactor.selected(
                    country: country,
                    shouldBeNotifiedWhenAvailable: true
                )
                self.disposables.insertWithDiscardableResult(disposable)
            }
            presentInNavigationController(informationViewController, in: navController)
        case .stateNotSupported(let state):
            kycSettings.isCompletingKyc = false
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedState(state)
            informationViewController.primaryButtonAction = { [unowned self] viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
                let interactor = KYCCountrySelectionInteractor()
                let disposable = interactor.selected(
                    state: state,
                    shouldBeNotifiedWhenAvailable: true
                )
                self.disposables.insertWithDiscardableResult(disposable)
            }
            presentInNavigationController(informationViewController, in: navController)
        }
    }

    private func handlePageWillAppear(for type: KYCPageType) {
        if type == .accountStatus || type == .applicationComplete {
            kycSettings.latestKycPage = nil
        } else {
            kycSettings.latestKycPage = type
        }

        // Optionally apply page model
        switch type {
        case .tier1ForcedTier2,
             .sddVerificationCheck,
             .welcome,
             .confirmEmail,
             .country,
             .states,
             .accountStatus,
             .accountUsageForm,
             .applicationComplete,
             .resubmitIdentity:
            break
        case .enterEmail:
            guard let current = user else { return }
            delegate?.apply(model: .email(current))
        case .profile:
            guard let current = user else { return }
            delegate?.apply(model: .personalDetails(current))
        case .address:
            guard let current = user else { return }
            delegate?.apply(model: .address(current, country, states))
        case .enterPhone, .confirmPhone:
            guard let current = user else { return }
            delegate?.apply(model: .phone(current))
        case .verifyIdentity:
            guard let countryCode = country?.code ?? user?.address?.countryCode else { return }
            delegate?.apply(model: .verifyIdentity(countryCode: countryCode))
        }
    }

    private func post(tier: KYC.Tier) -> AnyPublisher<KYC.UserTiers, NabuNetworkError> {
        let body = KYCTierPostBody(selectedTier: tier)
        let request = requestBuilder.post(
            path: ["kyc", "tiers"],
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    @discardableResult private func presentInNavigationController(
        _ viewController: UIViewController,
        in presentingViewController: UIViewController
    ) -> KYCOnboardingNavigationController {
        let navController = KYCOnboardingNavigationController.make()
        navController.pushViewController(viewController, animated: false)
        navController.modalTransitionStyle = .coverVertical
        if let presentedViewController = presentingViewController.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                presentingViewController.present(navController, animated: true)
            }
        } else {
            presentingViewController.present(navController, animated: true)
        }

        return navController
    }
}

extension KYCPageType {

    /// The page type the user should be placed in given the information they have provided
    fileprivate static func pageType(for user: NabuUser, tiersResponse: KYC.UserTiers, latestPage: KYCPageType? = nil) -> KYCPageType? {
        // Note: latestPage is only used by tier 2 flow, for tier 1, we need to infer the page,
        // because the user may need to select the country again.
        let tier = user.tiers?.selected ?? .tier1
        switch tier {
        case .tier0:
            return nil
        case .tier1:
            return tier1PageType(for: user)
        case .tier2:
            return tier1PageType(for: user) ?? tier2PageType(for: user, tiersResponse: tiersResponse, latestPage: latestPage)
        }
    }

    private static func tier1PageType(for user: NabuUser) -> KYCPageType? {
        guard user.email.verified else {
            return .enterEmail
        }

        guard user.personalDetails.firstName != nil else {
            return .country
        }

        guard user.address != nil else { return .country }

        return nil
    }

    private static func tier2PageType(for user: NabuUser, tiersResponse: KYC.UserTiers, latestPage: KYCPageType? = nil) -> KYCPageType? {
        if let latestPage = latestPage {
            return latestPage
        }

        guard let mobile = user.mobile else { return .enterPhone }

        guard mobile.verified else { return .confirmPhone }

        if tiersResponse.canCompleteTier2 {
            switch tiersResponse.canCompleteTier2 {
            case true:
                return user.needsDocumentResubmission == nil ? .verifyIdentity : .resubmitIdentity
            case false:
                return nil
            }
        }

        guard tiersResponse.canCompleteTier2 == false else { return .verifyIdentity }

        return nil
    }
}
