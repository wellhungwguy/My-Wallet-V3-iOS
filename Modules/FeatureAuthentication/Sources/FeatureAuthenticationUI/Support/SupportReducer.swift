// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import ToolKit

public enum SupportViewAction: Equatable {
    public enum URLContent {
        case contactUs
        case viewFAQ
    }

    case loadAppStoreVersionInformation
    case failedToRetrieveAppStoreInfo
    case appStoreVersionInformationReceived(AppStoreApplicationInfo)
    case openURL(URLContent)
}

struct SupportViewState: Equatable {
    let applicationVersion: String
    let bundleIdentifier: String
    var appStoreVersion: String?
    var isApplicationUpdated: Bool

    init(
        applicationVersion: String,
        bundleIdentifier: String
    ) {
        self.applicationVersion = applicationVersion
        self.bundleIdentifier = bundleIdentifier
        self.appStoreVersion = nil
        self.isApplicationUpdated = true
    }
}

let supportViewReducer = Reducer<
    SupportViewState,
    SupportViewAction,
    SupportViewEnvironment
> { state, action, environment in
    switch action {
    case .loadAppStoreVersionInformation:
        return environment
            .appStoreInformationRepository
            .verifyTheCurrentAppVersionIsTheLatestVersion(
                state.applicationVersion,
                bundleId: "com.rainydayapps.Blockchain"
            )
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> SupportViewAction in
                guard let applicationInfo = result.success else {
                    return .failedToRetrieveAppStoreInfo
                }
                return .appStoreVersionInformationReceived(applicationInfo)
            }
    case .appStoreVersionInformationReceived(let applicationInfo):
        state.isApplicationUpdated = applicationInfo.isApplicationUpToDate
        state.appStoreVersion = applicationInfo.version
        return .none
    case .failedToRetrieveAppStoreInfo:
        return .none
    case .openURL(let content):
        switch content {
        case .contactUs:
            environment.externalAppOpener.open(URL(string: Constants.SupportURL.PIN.contactUs)!)
        case .viewFAQ:
            environment.externalAppOpener.open(URL(string: Constants.SupportURL.PIN.viewFAQ)!)
        }
        return .none
    }
}
.analytics()

struct SupportViewEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener
}

extension SupportViewEnvironment {
    static let `default`: SupportViewEnvironment = .init(
        mainQueue: .main,
        appStoreInformationRepository: resolve(),
        analyticsRecorder: resolve(),
        externalAppOpener: resolve()
    )
}

// MARK: - Private

extension Reducer where
    Action == SupportViewAction,
    State == SupportViewState,
    Environment == SupportViewEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                SupportViewState,
                SupportViewAction,
                SupportViewEnvironment
            > { _, action, environment in
                switch action {
                case .loadAppStoreVersionInformation:
                    environment.analyticsRecorder.record(event: .customerSupportClicked)
                    return .none
                case .openURL(let content):
                    switch content {
                    case .contactUs:
                        environment.analyticsRecorder.record(event: .contactUsClicked)
                    case .viewFAQ:
                        environment.analyticsRecorder.record(event: .viewFAQsClicked)
                    }
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
