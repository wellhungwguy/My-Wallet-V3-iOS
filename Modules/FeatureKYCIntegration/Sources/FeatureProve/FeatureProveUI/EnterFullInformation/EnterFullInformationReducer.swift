// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Errors
import Extensions
import FeatureFormDomain
import FeatureProveDomain
import Localization
import ToolKit

private typealias LocalizedString = LocalizationConstants.EnterFullInformation

struct EnterFullInformation: ReducerProtocol {

    enum InputField: String {
        case phone
        case dateOfBirth
    }

    enum VerificationResult: Equatable {
        case abandoned
        case failure
        case success(prefillInfo: PrefillInfo)
    }

    let app: AppProtocol
    let prefillInfoService: PrefillInfoServiceAPI
    let dismissFlow: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        prefillInfoService: PrefillInfoServiceAPI,
        dismissFlow: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.prefillInfoService = prefillInfoService
        self.dismissFlow = dismissFlow
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchPrefillInfo
        case onPrefillInfoFetched(TaskResult<PrefillInfo>)
        case finishedWithError(NabuError?)
        case loadForm(phone: String?, dateOfBirth: Date?)
        case onClose
        case onContinue
        case onDismissError
    }

    struct State: Equatable {
        var title: String = LocalizedString.title

        @BindableState var form: Form = .init(
            header: .init(
                title: LocalizedString.Body.title,
                description: LocalizedString.Body.subtitle
            ),
            nodes: [],
            blocking: true
        )

        var isValidForm: Bool {
            guard !form.nodes.isEmpty else {
                return false
            }
            return form.nodes.isValidForm
        }

        var isLoading: Bool = false
        var prefillInfo: PrefillInfo?
        var isConinueButtonVisible = true
        var uxError: UX.Error?
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .binding(\.$form):
                return .none

            case .onAppear:
                return Effect(value: .loadForm(phone: nil, dateOfBirth: nil))

            case let .loadForm(phone, dateOfBirth):
                state.form = .init(
                    header: .init(
                        title: LocalizedString.Body.title,
                        description: LocalizedString.Body.subtitle
                    ),
                    nodes: FormQuestion.enterFullInformation(
                        phone: phone,
                        dateOfBirth: dateOfBirth
                    ),
                    blocking: true
                )
                return .none

            case .onContinue:
                guard state.isValidForm else {
                    return .none
                }

                return Effect(value: .fetchPrefillInfo)

            case .onClose:
                return .fireAndForget {
                    dismissFlow(.abandoned)
                }

            case .onDismissError:
                return .fireAndForget {
                    dismissFlow(.failure)
                }

            case .fetchPrefillInfo:
                state.isLoading = true
                guard
                    let dateOfBirth: Date = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue)
                else {
                    return .none
                }
                return .task {
                    await .onPrefillInfoFetched(
                        TaskResult {
                            try await prefillInfoService.getPrefillInfo(dateOfBirth: dateOfBirth)
                        }
                    )
                }

            case .onPrefillInfoFetched(.failure(let error)):
                state.isLoading = false
                if let error = error as? NabuError {
                    return Effect(value: .finishedWithError(error))
                } else {
                    return Effect(value: .finishedWithError(nil))
                }

            case .onPrefillInfoFetched(.success(let prefillInfo)):
                state.isLoading = false
                state.prefillInfo = prefillInfo
                return .fireAndForget {
                    dismissFlow(.success(prefillInfo: prefillInfo))
                }

            case .finishedWithError(let error):
                if let error {
                    state.uxError = UX.Error(nabu: error)
                } else {
                    state.uxError = UX.Error(error: nil)
                }
                return .fireAndForget {
                    dismissFlow(.failure)
                }
            }
        }
    }
}

extension EnterFullInformation {

    static func preview(app: AppProtocol) -> EnterFullInformation {
        EnterFullInformation(
            app: app,
            prefillInfoService: NoPrefillInfoService(),
            dismissFlow: { _ in }
        )
    }
}
