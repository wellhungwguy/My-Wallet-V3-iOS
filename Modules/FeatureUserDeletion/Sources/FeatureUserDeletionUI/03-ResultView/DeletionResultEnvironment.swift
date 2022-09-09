import AnalyticsKit
import ComposableArchitecture
import Foundation

public struct DeletionResultEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let analyticsRecorder: AnalyticsEventRecorderAPI
    public let logoutAndForgetWallet: () -> Void
    public let dismissFlow: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        dismissFlow: @escaping () -> Void,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.analyticsRecorder = analyticsRecorder
        self.dismissFlow = dismissFlow
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }
}
