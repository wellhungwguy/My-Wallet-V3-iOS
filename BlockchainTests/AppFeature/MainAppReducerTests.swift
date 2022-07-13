// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import DIKit
import ERC20Kit
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import ObservabilityKit
@testable import PlatformKit
import PlatformUIKit
import RxSwift
import WalletPayloadKit
import XCTest

@testable import Blockchain
@testable import ComposableNavigation
@testable import FeatureAppDomain
@testable import FeatureAppUI
@testable import FeatureAuthenticationMock
@testable import FeatureAuthenticationUI

// swiftlint:disable all
final class MainAppReducerTests: XCTestCase {

    var mockAccountRecoveryService: MockAccountRecoveryService!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var mockAppStoreOpener: MockAppStoreOpener!
    var mockCoincore: MockCoincore!
    var mockCredentialsStore: CredentialsStoreAPIMock!
    var mockDeepLinkHandler: MockDeepLinkHandler!
    var mockDeepLinkRouter: MockDeepLinkRouter!
    var mockDelegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceMock!
    var mockDeviceVerificationService: MockDeviceVerificationService!
    var mockERC20CryptoAssetService: ERC20CryptoAssetServiceMock!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockExternalAppOpener: MockExternalAppOpener!
    var mockFeatureFlagsService: MockFeatureFlagsService!
    var mockFiatCurrencySettingsService: FiatCurrencySettingsServiceMock!
    var mockForgetWalletService: ForgetWalletService!
    var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    var mockMobileAuthSyncService: MockMobileAuthSyncService!
    var mockNabuUser: NabuUser!
    var mockNabuUserService: MockNabuUserService!
    var mockReactiveWallet = MockReactiveWallet()
    var mockRemoteNotificationAuthorizer: MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockResetPasswordService: MockResetPasswordService!
    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockSiftService: MockSiftService!
    var mockWallet: MockWallet! = MockWallet()
    var mockWalletManager: WalletManager!
    var mockWalletPayloadService: MockWalletPayloadService!
    var mockWalletService: FeatureAppDomain.WalletService!
    var mockWalletStateProvider: WalletStateProvider!
    var mockWalletUpgradeService: MockWalletUpgradeService!

    var mockPerformanceTracing: PerformanceTracingServiceAPI!

    var testStore: TestStore<
        CoreAppState,
        CoreAppState,
        CoreAppAction,
        CoreAppAction,
        CoreAppEnvironment
    >!
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockNabuUserService = MockNabuUserService()
        mockSettingsApp = MockBlockchainSettingsApp()
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: mockSettingsApp,
            reactiveWallet: mockReactiveWallet
        )
        mockExternalAppOpener = MockExternalAppOpener()
        mockMobileAuthSyncService = MockMobileAuthSyncService()
        mockResetPasswordService = MockResetPasswordService()
        mockAccountRecoveryService = MockAccountRecoveryService()
        mockDeviceVerificationService = MockDeviceVerificationService()
        mockCredentialsStore = CredentialsStoreAPIMock()
        mockAlertPresenter = MockAlertViewPresenter()
        mockWalletUpgradeService = MockWalletUpgradeService()
        mockExchangeAccountRepository = MockExchangeAccountRepository()
        mockRemoteNotificationAuthorizer = MockRemoteNotificationAuthorizer(
            expectedAuthorizationStatus: UNAuthorizationStatus.authorized,
            authorizationRequestExpectedStatus: .success(())
        )
        mockRemoteNotificationServiceContainer = MockRemoteNotificationServiceContainer(
            authorizer: mockRemoteNotificationAuthorizer
        )
        mockCoincore = MockCoincore()
        mockAnalyticsRecorder = MockAnalyticsRecorder()
        mockSiftService = MockSiftService()
        mockMainQueue = DispatchQueue.test
        mockDeepLinkHandler = MockDeepLinkHandler()
        mockDeepLinkRouter = MockDeepLinkRouter()
        mockFeatureFlagsService = MockFeatureFlagsService()
        mockFiatCurrencySettingsService = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)
        mockAppStoreOpener = MockAppStoreOpener()
        mockERC20CryptoAssetService = ERC20CryptoAssetServiceMock()
        mockDelegatedCustodySubscriptionsService = DelegatedCustodySubscriptionsServiceMock()
        mockWalletService = WalletService(
            fetch: { _ in .empty() },
            fetchUsingSecPassword: { _, _ in .empty() },
            recoverFromMetadata: { _ in .empty() }
        )
        mockWalletStateProvider = WalletStateProvider(
            isWalletInitializedPublisher: { .empty() },
            releaseState: {}
        )
        mockWalletPayloadService = MockWalletPayloadService()
        mockForgetWalletService = ForgetWalletService.mock(called: {})

        mockPerformanceTracing = PerformanceTracing.mock

        mockNabuUser = NabuUser(
            identifier: "1234567890",
            personalDetails: .init(id: nil, first: nil, last: nil, birthday: nil),
            address: nil,
            email: Email(address: "test", verified: true),
            mobile: nil,
            status: KYC.AccountStatus.none,
            state: NabuUser.UserState.none,
            currencies: Currencies(
                preferredFiatTradingCurrency: .USD,
                usableFiatCurrencies: [.USD],
                defaultWalletCurrency: .USD,
                userFiatCurrencies: [.USD]
            ),
            tags: Tags(blockstack: nil),
            tiers: nil,
            needsDocumentResubmission: nil,
            productsUsed: NabuUser.ProductsUsed(exchange: false),
            settings: NabuUserSettings(mercuryEmailVerified: false)
        )
        mockNabuUserService.stubbedResults.user = .just(mockNabuUser)
        mockNabuUserService.stubbedResults.fetchUser = .just(mockNabuUser)
        mockNabuUserService.stubbedResults.setInitialResidentialInfo = .just(())
        mockNabuUserService.stubbedResults.setTradingCurrency = .just(())

        testStore = TestStore(
            initialState: CoreAppState(),
            reducer: mainAppReducer,
            environment: CoreAppEnvironment(
                accountRecoveryService: mockAccountRecoveryService,
                alertPresenter: mockAlertPresenter,
                analyticsRecorder: mockAnalyticsRecorder,
                app: App.test,
                appStoreOpener: mockAppStoreOpener,
                appUpgradeState: { .just(nil) },
                blockchainSettings: mockSettingsApp,
                buildVersionProvider: { "" },
                coincore: mockCoincore,
                credentialsStore: mockCredentialsStore,
                deeplinkHandler: mockDeepLinkHandler,
                deeplinkRouter: mockDeepLinkRouter,
                delegatedCustodySubscriptionsService: mockDelegatedCustodySubscriptionsService,
                deviceVerificationService: mockDeviceVerificationService,
                erc20CryptoAssetService: mockERC20CryptoAssetService,
                exchangeRepository: mockExchangeAccountRepository,
                externalAppOpener: mockExternalAppOpener,
                featureFlagsService: mockFeatureFlagsService,
                fiatCurrencySettingsService: mockFiatCurrencySettingsService,
                forgetWalletService: mockForgetWalletService,
                loadingViewPresenter: LoadingViewPresenter(),
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                mobileAuthSyncService: mockMobileAuthSyncService,
                nabuUserService: mockNabuUserService,
                nativeWalletFlagEnabled: { .just(false) },
                performanceTracing: mockPerformanceTracing,
                pushNotificationsRepository: MockPushNotificationsRepository(),
                remoteNotificationServiceContainer: mockRemoteNotificationServiceContainer,
                resetPasswordService: mockResetPasswordService,
                secondPasswordPrompter: SecondPasswordPromptableMock(),
                sharedContainer: SharedContainerUserDefaults(),
                siftService: mockSiftService,
                walletManager: mockWalletManager,
                walletPayloadService: mockWalletPayloadService,
                walletService: mockWalletService,
                walletStateProvider: mockWalletStateProvider,
                walletUpgradeService: mockWalletUpgradeService
            )
        )
    }

    override func tearDownWithError() throws {
        mockSettingsApp = nil
        mockExternalAppOpener = nil
        mockWalletManager = nil
        mockMobileAuthSyncService = nil
        mockResetPasswordService = nil
        mockAccountRecoveryService = nil
        mockDeviceVerificationService = nil
        mockCredentialsStore = nil
        mockAlertPresenter = nil
        mockWalletUpgradeService = nil
        mockExchangeAccountRepository = nil
        mockRemoteNotificationAuthorizer = nil
        mockRemoteNotificationServiceContainer = nil
        mockCoincore = nil
        mockAnalyticsRecorder = nil
        mockSiftService = nil
        mockMainQueue = nil
        mockDeepLinkHandler = nil
        mockDeepLinkRouter = nil
        mockFeatureFlagsService = nil
        mockFiatCurrencySettingsService = nil
        mockWalletService = nil
        mockWalletPayloadService = nil
        testStore = nil

        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = CoreAppState()
        XCTAssertNotNil(state.onboarding)
        XCTAssertNil(state.loggedIn)
    }

    func test_syncPinKeyWithICloud() {
        // given
        mockSettingsApp.isPairedWithWallet = true

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.isPairedWithWallet = false
        mockSettingsApp.guid = "a"
        mockSettingsApp.sharedKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.isPairedWithWallet = false
        mockSettingsApp.encryptedPinPassword = "a"
        mockSettingsApp.pinKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.isPairedWithWallet = false
        mockSettingsApp.pinKey = nil
        mockSettingsApp.encryptedPinPassword = nil
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertTrue(mockCredentialsStore.synchronizeCalled)
        XCTAssertTrue(mockCredentialsStore.expectedPinDataCalled)
    }

    func test_verify_didDecryptWallet_action_updates_appSettings() {
        testStore.send(
            .didDecryptWallet(.init(guid: "a", sharedKey: "b", passwordPartHash: "c"))
        )
        testStore.receive(.resetVerificationStatusIfNeeded(guid: "a", sharedKey: "b"))
        XCTAssertNotNil(testStore.environment.blockchainSettings.guid)
        XCTAssertEqual(testStore.environment.blockchainSettings.guid, "a")

        XCTAssertNotNil(testStore.environment.blockchainSettings.sharedKey)
        XCTAssertEqual(testStore.environment.blockchainSettings.sharedKey, "b")
    }

    func test_trying_to_login_withSecondPassword_account_displays_notice() {
        mockWallet.mockNeedsSecondPassword = true
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil
        mockSettingsApp.isPinSet = false

        testStore.send(.onboarding(.start))
        testStore.receive(.onboarding(.proceedToFlow)) { state in
            state.onboarding?.welcomeState = .init()
        }

        testStore.receive(.onboarding(.welcomeScreen(.start)))
        testStore.send(.onboarding(.welcomeScreen(.enter(into: .manualLogin)))) { state in
            state.onboarding?.welcomeState?.route = RouteIntent(route: .manualLogin, action: .enterInto())
            state.onboarding?.welcomeState?.manualCredentialsState = .init()
        }
        testStore.send(
            .onboarding(
                .welcomeScreen(
                    .manualPairing(
                        .walletPairing(
                            .decryptWalletWithPassword("password")
                        )
                    )
                )
            )
        ) { state in
            state.onboarding?.welcomeState?.manualCredentialsState?.isLoading = true
        }

        testStore.receive(.onboarding(.welcomeScreen(.requestedToDecryptWallet("password"))))
        testStore.receive(.fetchWallet(password: "password"))
        testStore.receive(.authenticate)
        mockMainQueue.advance(by: .seconds(1))
        testStore.receive(.doFetchWallet(password: "password"))
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        XCTAssertTrue(mockWallet.fetchCalled)
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash
        )
        mockMainQueue.advance()

        // wallet decryptions still expects the original values
        let decryption = WalletDecryption(
            guid: String(repeating: "a", count: 36),
            sharedKey: String(repeating: "b", count: 36),
            passwordPartHash: nil
        )
        testStore.receive(.didDecryptWallet(decryption))
        testStore.receive(.authenticated(.success(true)))

        // Assert that both of these values are nil
        XCTAssertNil(mockSettingsApp.guid)
        XCTAssertNil(mockSettingsApp.sharedKey)

        testStore.receive(.onboarding(.informSecondPasswordDetected))
        testStore.receive(.onboarding(.welcomeScreen(.informSecondPasswordDetected)))
        testStore.receive(
            .onboarding(
                .welcomeScreen(
                    .manualPairing(
                        .navigate(to: .secondPasswordDetected)
                    )
                )
            )
        ) { state in
            state.onboarding?.welcomeState?.manualCredentialsState?.route = RouteIntent(
                route: .secondPasswordDetected,
                action: .navigateTo
            )
            state.onboarding?.welcomeState?.manualCredentialsState?.secondPasswordNoticeState = .init()
        }
    }

    func test_sending_success_authentication_from_password_required_screen() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = false

        testStore.send(.onboarding(.start))
        testStore.receive(.onboarding(.proceedToFlow)) { state in
            state.onboarding?.passwordRequiredState = .init(
                walletIdentifier: self.mockSettingsApp.guid ?? ""
            )
        }

        // password screen should start
        testStore.receive(.onboarding(.passwordScreen(.start)))

        // when authenticating
        testStore.send(.onboarding(.passwordScreen(.authenticate("password"))))

        testStore.receive(.fetchWallet(password: "password"))
        testStore.receive(.authenticate)
        mockMainQueue.advance(by: .seconds(1))
        testStore.receive(.doFetchWallet(password: "password"))
        XCTAssertTrue(mockWallet.fetchCalled)
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash
        )
        mockMainQueue.advance()

        let decryption = WalletDecryption(
            guid: mockSettingsApp.guid,
            sharedKey: mockSettingsApp.sharedKey,
            passwordPartHash: nil
        )
        testStore.receive(.didDecryptWallet(decryption))
        testStore.receive(.resetVerificationStatusIfNeeded(guid: decryption.guid, sharedKey: decryption.sharedKey))
        testStore.receive(.authenticated(.success(true)))
        testStore.receive(.setupPin) { state in
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordRequiredState = nil
        }
        testStore.receive(.onboarding(.pin(.create))) { state in
            state.onboarding?.pinState?.creating = true
        }
    }

    func test_sending_success_authentication_from_pin() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true

        testStore.send(.onboarding(.start))
        testStore.receive(.onboarding(.proceedToFlow)) { state in
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordRequiredState = nil
        }

        // password screen should start
        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
        }

        // when authenticating
        testStore.send(.onboarding(.pin(.handleAuthentication("password"))))

        testStore.receive(.fetchWallet(password: "password"))
        testStore.receive(.authenticate)
        mockMainQueue.advance(by: .seconds(1))
        testStore.receive(.doFetchWallet(password: "password"))
        XCTAssertTrue(mockWallet.fetchCalled)
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash
        )

        mockMainQueue.advance()

        let decryption = WalletDecryption(
            guid: mockSettingsApp.guid,
            sharedKey: mockSettingsApp.sharedKey,
            passwordPartHash: nil
        )
        testStore.receive(.didDecryptWallet(decryption))
        testStore.receive(.resetVerificationStatusIfNeeded(guid: decryption.guid, sharedKey: decryption.sharedKey))
        testStore.receive(.authenticated(.success(true)))
        testStore.receive(.initializeWallet)
        mockReactiveWallet.mockState.send(.initialized)
        mockMainQueue.advance()
        mockWalletUpgradeService.needsWalletUpgradeRelay.send(false)
        testStore.receive(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.checkWalletUpgrade)
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.prepareForLoggedIn)
        testStore.receive(.fetchedUser(.success(mockNabuUser)))
        testStore.receive(.proceedToLoggedIn(.success(true))) { state in
            state.onboarding = nil
            state.loggedIn = .init()
        }
        assertDidPerformSignIn()
        logout()
        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_logout_should_perform_cleanup_and_display_password_screen() {
        testStore.send(.proceedToLoggedIn(.success(true))) { state in
            state.loggedIn = .init()
            state.onboarding = nil
        }
        mockMainQueue.advance()

        assertDidPerformSignIn()
        logout()

        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        XCTAssertNotNil(mockAnalyticsRecorder.recordEventCalled.event)
        XCTAssertEqual(
            mockAnalyticsRecorder.recordEventCalled.event!.name,
            AnalyticsEvents.New.Navigation.signedOut.name
        )

        XCTAssertTrue(mockSiftService.removeUserIdCalled)
        XCTAssertTrue(mockSettingsApp.resetCalled)

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_logout_should_perform_cleanup_and_pin_screen() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true

        testStore.send(.onboarding(.start))
        testStore.receive(.onboarding(.proceedToFlow)) { state in
            state.onboarding?.pinState = .init()
        }

        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
            state.onboarding?.passwordRequiredState = nil
        }

        testStore.send(.onboarding(.pin(.logout))) { state in
            state.loggedIn = nil
            state.onboarding = .init(
                pinState: nil,
                walletUpgradeState: nil,
                passwordRequiredState: .init(
                    walletIdentifier: self.mockSettingsApp.guid ?? ""
                )
            )
        }

        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        XCTAssertNotNil(mockAnalyticsRecorder.recordEventCalled.event)
        XCTAssertEqual(
            mockAnalyticsRecorder.recordEventCalled.event!.name,
            AnalyticsEvents.New.Navigation.signedOut.name
        )

        XCTAssertTrue(mockSiftService.removeUserIdCalled)
        XCTAssertTrue(mockSettingsApp.resetCalled)

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_walletInitialized_should_check_if_wallet_upgrade_is_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.send(true)

        testStore.send(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.checkWalletUpgrade)
        testStore.receive(.walletNeedsUpgrade(true)) { state in
            state.onboarding?.pinState = nil
            state.onboarding?.walletUpgradeState = WalletUpgrade.State()
            state.loggedIn = nil
        }

        testStore.receive(.onboarding(.walletUpgrade(.begin)))

        testStore.send(.onboarding(.walletUpgrade(.completed)))
        mockMainQueue.advance()
        testStore.receive(.prepareForLoggedIn)
        testStore.receive(.fetchedUser(.success(mockNabuUser)))
        testStore.receive(.proceedToLoggedIn(.success(true))) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        assertDidPerformSignIn()
        logout()

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_walletInitialized_should_proceed_to_logged_in_when_no_upgrade_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.send(false)
        testStore.send(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.checkWalletUpgrade)
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.prepareForLoggedIn)
        testStore.receive(.fetchedUser(.success(mockNabuUser)))
        testStore.receive(.proceedToLoggedIn(.success(true))) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        assertDidPerformSignIn()
        logout()

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_appForegrounded_while_wallet_not_initialized_and_logged_in_state() {
        // given
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true

        mockWalletUpgradeService.needsWalletUpgradeRelay.send(false)
        testStore.send(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.checkWalletUpgrade)
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.prepareForLoggedIn)
        testStore.receive(.fetchedUser(.success(mockNabuUser)))
        testStore.receive(.proceedToLoggedIn(.success(true))) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        assertDidPerformSignIn()

        // when
        mockWallet.mockIsInitialized = false
        testStore.send(.appForegrounded)
        mockMainQueue.advance()
        // then

        testStore.receive(.loggedIn(.stop))
        testStore.receive(.requirePin) { state in
            state.loggedIn = nil
            state.onboarding = Onboarding.State(pinState: .init())
        }
        testStore.receive(.onboarding(.start)) { state in
            state.onboarding?.pinState = .init()
        }
        testStore.receive(.onboarding(.proceedToFlow))
        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
        }
    }

    func test_clearPinIfNeeded_correctly_clears_pin() {
        // given a hashed password
        mockSettingsApp.passwordPartHash = "a-hash"

        // 1. when the same password hash is used
        clearPinIfNeeded(for: "a-hash", appSettings: mockSettingsApp)

        // 1. then it should not clear the saved pin
        XCTAssertFalse(mockSettingsApp.clearPinCalled)

        // 2. when a different password hash is used (on password change)
        clearPinIfNeeded(for: "a-diff-hash", appSettings: mockSettingsApp)

        // 1. then it should clear the saved pin
        XCTAssertTrue(mockSettingsApp.clearPinCalled)
    }

    func test_wallet_decryption_outputs_decryption_failure_on_invalid_guid() {
        // note: the count of a guid and shared key should equal to 36
        // given a non valid guid
        let decryption = WalletDecryption(
            guid: "a",
            sharedKey: "b",
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        let expectedError = AuthenticationError(
            code: AuthenticationError.ErrorCode.errorDecryptingWallet,
            description: LocalizationConstants.Authentication.errorDecryptingWallet
        )

        XCTAssertEqual(CoreAppAction.decryptionFailure(expectedError), action)
    }

    func test_wallet_decryption_outputs_failure_on_invalid_sharedKey() {
        // note: the count of a guid and shared key should equal to 36
        // given a non valid sharedKey
        let guid = String(repeating: "a", count: 36)
        let decryption = WalletDecryption(
            guid: guid,
            sharedKey: "b",
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        let expectedError = AuthenticationError(
            code: AuthenticationError.ErrorCode.invalidSharedKey,
            description: LocalizationConstants.Authentication.invalidSharedKey
        )

        XCTAssertEqual(CoreAppAction.decryptionFailure(expectedError), action)
    }

    func test_wallet_decryption_outputs_success_on_valid_creds() {
        // note: the count of a guid and shared key should equal to 36
        // given a valid guid
        let guid = String(repeating: "a", count: 36)
        let sharedKey = String(repeating: "b", count: 36)
        let decryption = WalletDecryption(
            guid: guid,
            sharedKey: sharedKey,
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        XCTAssertEqual(CoreAppAction.didDecryptWallet(decryption), action)
    }

    func test_session_mismatch_deeplink_show_show_authorization() {
        mockFeatureFlagsService.enable(.pollingForEmailLogin)
            .subscribe()
            .store(in: &cancellables)
        mockDeviceVerificationService.expectedSessionMismatch = true
        let requestInfo = LoginRequestInfo(
            sessionId: "",
            base64Str: "",
            details: DeviceVerificationDetails(originLocation: "", originIP: "", originBrowser: ""),
            timestamp: Date(timeIntervalSince1970: 1000)
        )
        testStore.send(.loginRequestReceived(
            deeplink: MockDeviceVerificationService.validDeeplink
        ))
        mockMainQueue.advance()
        testStore.receive(
            .checkIfConfirmationRequired(
                sessionId: "",
                base64Str: ""
            )
        )
        testStore.receive(.proceedToDeviceAuthorization(requestInfo)) { state in
            state.deviceAuthorization = .init(loginRequestInfo: requestInfo)
        }
    }

    // MARK: - Helpers

    private func assertDidPerformSignIn(file: StaticString = #file, line: UInt = #line) {
        testStore.receive(.loggedIn(.start(.none)), file: file, line: line)
        testStore.receive(.mobileAuthSync(isLogin: true), file: file, line: line)
        mockMainQueue.advance()
        testStore.receive(.loggedIn(.handleExistingWalletSignIn), file: file, line: line)
        testStore.receive(.loggedIn(.showPostSignInOnboardingFlow), file: file, line: line) {
            $0.loggedIn?.displayPostSignInOnboardingFlow = true
        }
    }

    /// send logout to clear pending effects after logged in.
    private func logout(file: StaticString = #file, line: UInt = #line) {
        testStore.send(.loggedIn(.logout)) { state in
            state.loggedIn = nil
            state.onboarding = .init(
                pinState: nil,
                walletUpgradeState: nil,
                passwordRequiredState: .init(
                    walletIdentifier: self.mockSettingsApp.guid ?? ""
                )
            )
        }
    }
}

// swiftlint:enable type_body_length

// Copied from ERC20KitMock due to BlockchainTests not being able to import that dependency.
final class ERC20CryptoAssetServiceMock: ERC20CryptoAssetServiceAPI {

    var initializeCalled: Bool = false

    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        initializeCalled = true
        return .just(())
    }
}

final class DelegatedCustodySubscriptionsServiceMock: DelegatedCustodySubscriptionsServiceAPI {
    func subscribe() -> AnyPublisher<Void, Error> {
        .just(())
    }
}
