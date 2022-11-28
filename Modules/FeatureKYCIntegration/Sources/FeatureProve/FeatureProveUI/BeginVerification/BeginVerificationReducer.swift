// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Errors
import FeatureProveDomain
import Localization

struct BeginVerification: ReducerProtocol {
    private typealias LocalizedString = LocalizationConstants.BeginVerification

    let app: AppProtocol
    let mobileAuthInfoService: MobileAuthInfoServiceAPI
    let dismissFlow: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        mobileAuthInfoService: MobileAuthInfoServiceAPI,
        dismissFlow: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.mobileAuthInfoService = mobileAuthInfoService
        self.dismissFlow = dismissFlow
    }

    enum Action: Equatable {
        case onAppear
        case fetchMobileAuthInfo
        case onMobileAuthInfoFetched(TaskResult<MobileAuthInfo?>)
        case finishedWithSuccess
        case finishedWithError(NabuError?)
        case onClose
        case onContinue
        case onDismissError
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
        var isLoading: Bool = false
        var mobileAuthInfo: MobileAuthInfo?
        var isConinueButtonVisible = true
        var uxError: UX.Error?
        var termsUrl: URL?
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.termsUrl = try? app.remoteConfiguration.get(
                    blockchain.app.configuration.kyc.integration.prove.begin.verification.privacy.url,
                    as: URL.self
                )
                return .none

            case .onContinue:
                return Effect(value: .fetchMobileAuthInfo)

            case .onClose:
                return .fireAndForget {
                    dismissFlow(.abandoned)
                }

            case .onDismissError:
                return .fireAndForget {
                    dismissFlow(.failure)
                }

            case .fetchMobileAuthInfo:
                state.isLoading = true
                return .task {
                    await .onMobileAuthInfoFetched(
                        TaskResult {
                            try await self.mobileAuthInfoService.getMobileAuthInfo()
                        }
                    )
                }

            case let .onMobileAuthInfoFetched(.failure(error)):
                state.isLoading = false
                if let error = error as? NabuError {
                    return Effect(value: .finishedWithError(error))
                } else {
                    return Effect(value: .finishedWithError(nil))
                }

            case .onMobileAuthInfoFetched(.success(let mobileAuthInfo)):
                state.isLoading = false
                state.mobileAuthInfo = mobileAuthInfo
                return Effect(value: .finishedWithSuccess)

            case .finishedWithSuccess:
                return .fireAndForget {
                    dismissFlow(.success)
                }

            case .finishedWithError(let error):
                if let error {
                    state.uxError = UX.Error(nabu: error)
                } else {
                    state.uxError = UX.Error(error: nil)
                }
                return .none
            }
        }
    }
}
