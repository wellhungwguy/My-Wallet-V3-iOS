// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import Combine
import ComposableArchitecture
@testable import FeatureOnboardingUI
import XCTest

final class OnboardingChecklistReducerTests: XCTestCase {

    private var testStore: TestStore<
        OnboardingChecklist.State,
        OnboardingChecklist.State,
        OnboardingChecklist.Action,
        OnboardingChecklist.Action,
        OnboardingChecklist.Environment
    >!
    private var testMainScheduler: TestSchedulerOf<DispatchQueue>!
    private var userStateSubject: PassthroughSubject<UserState, Never>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userStateSubject = PassthroughSubject()
        testMainScheduler = DispatchQueue.test
        testStore = .init(
            initialState: OnboardingChecklist.State(),
            reducer: OnboardingChecklist.reducer,
            environment: OnboardingChecklist.Environment(
                userState: userStateSubject.eraseToAnyPublisher(),
                presentBuyFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(.complete)
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                presentKYCFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(.kycComplete)
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                presentPaymentMethodLinkingFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(.paymentMethodsLinked)
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                analyticsRecorder: MockAnalyticsRecorder(),
                mainQueue: testMainScheduler.eraseToAnyScheduler()
            )
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        testMainScheduler = nil
        userStateSubject = nil
        try super.tearDownWithError()
    }

    func test_action_didSelectItem_kycCompleted_no_items_completed() throws {
        resetUserStateToClean()
        testStore.send(.startObservingUserState)
        // user taps on verify identity item
        testStore.send(.didSelectItem(.verifyIdentity, .item))
        // kyc is done
        testMainScheduler.advance()
        // then they go through kyc
        testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_linkPaymentMethod_no_items_completed() throws {
        resetUserStateToClean()
        testStore.send(.startObservingUserState)
        // user taps on verify identity item
        testStore.send(.didSelectItem(.linkPaymentMethods, .item))
        // then they go through kyc
        testMainScheduler.advance()
        // kyc is done
        testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        // then they go through linking a payment method
        testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_linkPaymentMethod_kyc_completed() throws {
        resetUserStateToKYCCompleted()
        testStore.send(.startObservingUserState)
        // user taps on verify identity item
        testStore.send(.didSelectItem(.linkPaymentMethods, .item))
        testMainScheduler.advance()
        // then they go through linking a payment method
        testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        // then go through buy
        testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }
        testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_buyCrypto_no_items_completed() throws {
        resetUserStateToClean()
        testStore.send(.startObservingUserState)
        // user taps on verify identity item
        testStore.send(.didSelectItem(.buyCrypto, .item))
        testMainScheduler.advance()
        // then they go through kyc
        testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        // then they go through linking a payment method
        testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        // then they go through buy
        testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }
        testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_buyCrypto_kyc_completed() throws {
        resetUserStateToKYCCompleted()
        testStore.send(.startObservingUserState)
        // user taps on verify identity item
        testStore.send(.didSelectItem(.buyCrypto, .item))
        testMainScheduler.advance()
        // then they go through linking a payment method
        testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        // then they go through buy
        testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }
        testStore.send(.stopObservingUserState)
    }

    func test_action_didSelectItem_buyCrypto_kyc_and_payment_completed() throws {
        resetUserStateToKYCAndPaymentsCompleted()
        testStore.send(.startObservingUserState)
        // user taps on verify identity item
        testStore.send(.didSelectItem(.buyCrypto, .item))
        testMainScheduler.advance()
        // then they go through buy
        testStore.receive(.userStateDidChange(.complete)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
        }
        testStore.send(.stopObservingUserState)
    }

    func test_action_dismissFullScreenChecklist() throws {
        // user taps on close
        testStore.send(.dismissFullScreenChecklist)
        // then the full screen checklist gets dismissed
        testStore.receive(.dismiss())
    }

    func test_action_presentFullScreenChecklist() throws {
        // user taps on overview
        testStore.send(.presentFullScreenChecklist)
        // then the full screen checklist gets presented
        testStore.receive(.enter(into: .fullScreenChecklist, context: .none)) {
            $0.route = .enter(into: .fullScreenChecklist, context: .none)
        }
    }

    func test_action_startAndStopObservingUserState() throws {
        // view is displayed and starts listening to changes
        testStore.send(.startObservingUserState)
        // a new value is sent
        resetUserState(to: .kycComplete)
        // that new value is received
        testMainScheduler.advance()
        testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        // the view is dimissed and the values stream subscription is cancelled
        testStore.send(.stopObservingUserState)
        // the next do block serves to ensure no further changes are listened to
        resetUserStateToKYCAndPaymentsCompleted()
        testMainScheduler.advance()
    }
}

// MARK: - Helpers

extension OnboardingChecklistReducerTests {

    private func resetUserStateToClean() {
        testStore.send(.startObservingUserState)
        resetUserState(to: .initialState)
        testMainScheduler.advance()
        testStore.receive(.userStateDidChange(.initialState))
        testStore.send(.stopObservingUserState)
    }

    private func resetUserStateToKYCCompleted() {
        testStore.send(.startObservingUserState)
        resetUserState(to: .kycComplete)
        testMainScheduler.advance()
        testStore.receive(.userStateDidChange(.kycComplete)) {
            $0.completedItems = [.verifyIdentity]
        }
        testStore.send(.stopObservingUserState)
    }

    private func resetUserStateToKYCAndPaymentsCompleted() {
        testStore.send(.startObservingUserState)
        resetUserState(to: .paymentMethodsLinked)
        testMainScheduler.advance()
        testStore.receive(.userStateDidChange(.paymentMethodsLinked)) {
            $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
        }
        testStore.send(.stopObservingUserState)
    }

    private func resetUserState(to userState: UserState) {
        userStateSubject.send(userState)
    }
}

extension UserState {

    static var initialState: UserState {
        UserState(
            kycStatus: .notVerified,
            hasLinkedPaymentMethods: false,
            hasEverPurchasedCrypto: false
        )
    }

    static var kycComplete: UserState {
        UserState(
            kycStatus: .verified,
            hasLinkedPaymentMethods: false,
            hasEverPurchasedCrypto: false
        )
    }

    static var paymentMethodsLinked: UserState {
        UserState(
            kycStatus: .verified,
            hasLinkedPaymentMethods: true,
            hasEverPurchasedCrypto: false
        )
    }

    static var complete: UserState {
        UserState(
            kycStatus: .verified,
            hasLinkedPaymentMethods: true,
            hasEverPurchasedCrypto: true
        )
    }
}
