// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AnalyticsKitMock
import ComposableArchitecture
@testable import FeatureKYCDomainMock
@testable import FeatureKYCUI
@testable import FeatureKYCUIMock
import SnapshotTesting
import SwiftUI
import TestKit
import XCTest

final class EmailVerificationSnapshotTests: XCTestCase {

    private var environment: EmailVerificationEnvironment!
    private var rootStore: Store<EmailVerificationState, EmailVerificationAction>!
    private var mockEmailVerificationService: MockEmailVerificationService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = false

        mockEmailVerificationService = MockEmailVerificationService()
        environment = EmailVerificationEnvironment(
            analyticsRecorder: MockAnalyticsRecorder(),
            emailVerificationService: mockEmailVerificationService,
            flowCompletionCallback: { _ in },
            openMailApp: { .none },
            mainQueue: .immediate,
            pollingQueue: .immediate
        )
        rebuildRootStore()
    }

    override func tearDownWithError() throws {
        mockEmailVerificationService = nil
        environment = nil
        rootStore = nil
        try super.tearDownWithError()
    }

    func test_iPhoneSE_snapshot_step_verify_email() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.verifyEmailPrompt))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_verify_email() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.verifyEmailPrompt))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_verify_email() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.verifyEmailPrompt))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_help() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_help() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help_resending() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.emailVerificationHelp(.sendVerificationEmail))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_help_resending() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.emailVerificationHelp(.sendVerificationEmail))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_help_resending() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        mockEmailVerificationService.stubbedResults.sendVerificationEmail = .empty()
        view.viewStore.send(.emailVerificationHelp(.sendVerificationEmail))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_help_resend_failed() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        view.viewStore.send(.emailVerificationHelp(.didReceiveEmailSendingResponse(.failure(.missingCredentials))))
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_help_resend_failed() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        view.viewStore.send(.emailVerificationHelp(.didReceiveEmailSendingResponse(.failure(.missingCredentials))))
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_help_resend_failed() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerificationHelp))
        view.viewStore.send(.emailVerificationHelp(.didReceiveEmailSendingResponse(.failure(.missingCredentials))))
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    func test_iPhoneSE_snapshot_step_edit_email() throws {
        try XCTSkipIf(true)
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_edit_email() throws {
        try XCTSkipIf(true)
        let view = presentEditEmailScreen()
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_edit_email() throws {
        try XCTSkipIf(true)
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_email_invalid() throws {
        try XCTSkipIf(true)
        rebuildRootStore(emailAddress: "test_example.com")
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_edit_email_invalid() throws {
        try XCTSkipIf(true)
        rebuildRootStore(emailAddress: "test_example.com")
        let view = presentEditEmailScreen()
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_edit_email_invalid() throws {
        try XCTSkipIf(true)
        rebuildRootStore(emailAddress: "test_example.com")
        let view = presentEditEmailScreen()
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_saving() throws {
        try XCTSkipIf(true)
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.save))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_edit_saving() throws {
        try XCTSkipIf(true)
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.save))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_edit_saving() throws {
        try XCTSkipIf(true)
        mockEmailVerificationService.stubbedResults.updateEmailAddress = .empty()
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.save))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_edit_save_failed() throws {
        try XCTSkipIf(true)
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.didReceiveSaveResponse(.failure(.missingCredentials))))
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_edit_save_failed() throws {
        try XCTSkipIf(true)
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.didReceiveSaveResponse(.failure(.missingCredentials))))
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_edit_save_failed() throws {
        try XCTSkipIf(true)
        let view = presentEditEmailScreen()
        ViewStore(rootStore).send(.editEmailAddress(.didReceiveSaveResponse(.failure(.missingCredentials))))
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    func test_iPhoneSE_snapshot_step_email_verified() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerifiedPrompt))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_email_verified() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerifiedPrompt))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_email_verified() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.emailVerifiedPrompt))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_loading_verification_status() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.loadingVerificationState))
        assert(view, on: .iPhoneSe)
    }

    func test_iPhone8_snapshot_step_loading_verification_status() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.loadingVerificationState))
        assert(view, on: .iPhone8)
    }

    func test_iPhoneX_snapshot_step_loading_verification_status() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.presentStep(.loadingVerificationState))
        assert(view, on: .iPhoneX)
    }

    func test_iPhoneSE_snapshot_step_loading_verification_status_failed() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown))))
        assert(view, on: .iPhoneSe, renderInWindow: true)
    }

    func test_iPhone8_snapshot_step_loading_verification_status_failed() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown))))
        assert(view, on: .iPhone8, renderInWindow: true)
    }

    func test_iPhoneX_snapshot_step_loading_verification_status_failed() throws {
        try XCTSkipIf(true)
        let view = EmailVerificationView(store: rootStore)
        view.viewStore.send(.didReceiveEmailVerficationResponse(.failure(.unknown(MockError.unknown))))
        assert(view, on: .iPhoneX, renderInWindow: true)
    }

    // MARK: - Helpers

    private func rebuildRootStore(emailAddress: String = "test@example.com") {
        rootStore = Store(
            initialState: EmailVerificationState(emailAddress: emailAddress),
            reducer: emailVerificationReducer,
            environment: environment
        )
    }

    private func presentEditEmailScreen() -> some View {
        // due to what seems a limitation on SwiftUI, trying to push twice programmatically from the root view doesn't work
        NavigationView {
            EditEmailView(
                store: rootStore.scope(
                    state: \.editEmailAddress,
                    action: EmailVerificationAction.editEmailAddress
                )
            )
            .trailingNavigationButton(.close, action: {})
            .navigationBarTitle("", displayMode: .inline)
            .whiteNavigationBarStyle()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
