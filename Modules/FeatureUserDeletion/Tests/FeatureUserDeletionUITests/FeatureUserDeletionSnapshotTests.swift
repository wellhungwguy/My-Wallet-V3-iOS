import ComposableArchitecture
import ComposableArchitectureExtensions
@testable import FeatureUserDeletionDomainMock
@testable import FeatureUserDeletionUI
import SnapshotTesting
import SwiftUI
import TestKit
import XCTest

//// swiftlint:disable type_body_length
final class FeatureUserDeletionSnapshotTests: XCTestCase {

    private var environment: UserDeletionEnvironment!
    private var mockEmailVerificationService: MockUserDeletionRepositoryAPI!
    private var userDeletionState: UserDeletionState!

    enum Config {
        static let recordingSnapshots: Bool = false
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = Config.recordingSnapshots

        mockEmailVerificationService = MockUserDeletionRepositoryAPI()
        environment = UserDeletionEnvironment(
            mainQueue: .immediate,
            userDeletionRepository: mockEmailVerificationService,
            dismissFlow: {},
            logoutAndForgetWallet: {}
        )
    }

    override func tearDownWithError() throws {
        mockEmailVerificationService = nil
        environment = nil
        try super.tearDownWithError()
    }

    func test_iPhoneSE_onAppear() throws {
        let view = UserDeletionView(store: buildStore())
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneXsMax_onAppear() throws {
        let view = UserDeletionView(store: buildStore())
        assert(view, on: .iPhoneXsMax)
    }

    // MARK: - Helpers

    private func buildStore(
        confirmViewState: DeletionConfirmState? = DeletionConfirmState(),
        route: RouteIntent<UserDeletionRoute>? = nil
    ) -> Store<UserDeletionState, UserDeletionAction> {
        .init(
            initialState: UserDeletionState(
                confirmViewState: confirmViewState,
                route: route
            ),
            reducer: UserDeletionModule.reducer,
            environment: environment
        )
    }
}
