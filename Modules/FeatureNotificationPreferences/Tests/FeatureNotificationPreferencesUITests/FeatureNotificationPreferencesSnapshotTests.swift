// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import CoreMedia
import Errors
import FeatureNotificationPreferencesMocks
@testable import FeatureNotificationPreferencesUI
import Foundation
import SnapshotTesting
import TestKit
import XCTest

final class FeatureNotificationPreferencesSnapshotTests: XCTestCase {
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private var notificationRepoMock: NotificationPreferencesRepositoryMock!
    private var rootStore: Store<NotificationPreferencesState, NotificationPreferencesAction>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = false

        let preferencesToReturn = [
            MockGenerator.marketingNotificationPreference,
            MockGenerator.transactionalNotificationPreference,
            MockGenerator.priceAlertNotificationPreference
        ]

        notificationRepoMock = NotificationPreferencesRepositoryMock()
        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)
    }

    override func tearDownWithError() throws {
        notificationRepoMock = nil
        try super.tearDownWithError()
    }

//    func test_iPhoneX_snapshot_loading_view() throws {
//        rootStore = Store(
//            initialState: .init(viewState: .loading),
//            reducer: notificationPreferencesReducer,
//            environment: NotificationPreferencesEnvironment(
//                mainQueue: mainScheduler.eraseToAnyScheduler(),
//                notificationPreferencesRepository: notificationRepoMock,
//                analyticsRecorder: MockAnalyticsRecorder()
//            )
//        )
//
//        let view = FeatureNotificationPreferencesView(store: rootStore)
//        assert(view, on: .iPhoneX)
//        assert(view, on: .iPhone8)
//
//    }
//
//    func test_iPhoneX_snapshot_display_preferences_view() throws {
//        let preferencesToReturn = [
//            MockGenerator.marketingNotificationPreference,
//            MockGenerator.transactionalNotificationPreference,
//            MockGenerator.priceAlertNotificationPreference
//        ]
//
//        rootStore = Store(
//            initialState: .init(viewState: .data(notificationDetailsState: preferencesToReturn)),
//            reducer: notificationPreferencesReducer,
//            environment: NotificationPreferencesEnvironment(
//                mainQueue: mainScheduler.eraseToAnyScheduler(),
//                notificationPreferencesRepository: notificationRepoMock,
//                analyticsRecorder: MockAnalyticsRecorder()
//            )
//        )
//
//        let view = FeatureNotificationPreferencesView(store: rootStore)
//        assert(view, on: .iPhoneX)
//        assert(view, on: .iPhone8)
//    }
//
//    func test_iPhoneX_snapshot_error_preferences_view() throws {
//        let rootStore = Store(
//            initialState: .init(viewState: .error),
//            reducer: notificationPreferencesReducer,
//            environment: NotificationPreferencesEnvironment(
//                mainQueue: mainScheduler.eraseToAnyScheduler(),
//                notificationPreferencesRepository: notificationRepoMock,
//                analyticsRecorder: MockAnalyticsRecorder()
//            )
//        )
//
//        let view = FeatureNotificationPreferencesView(store: rootStore)
//        assert(view, on: .iPhoneX)
//        assert(view, on: .iPhone8)
//    }
}
