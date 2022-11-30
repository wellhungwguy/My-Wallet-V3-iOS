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

private typealias LocalizedString = LocalizationConstants.ConfirmInformation

struct ConfirmInformation: ReducerProtocol {

    enum InputField: String {
        case firstName
        case lastName
        case address
        case dateOfBirth
        case phone

        static func answerId(index: Int) -> String {
            "\(InputField.address.rawValue)-\(index)"
        }
    }

    enum VerificationResult: Equatable {
        case abandoned
        case failure
        case success(confirmInfo: ConfirmInfo?)
    }

    let app: AppProtocol
    let confirmInfoService: ConfirmInfoServiceAPI
    let dismissFlow: (VerificationResult) -> Void

    init(
        app: AppProtocol,
        confirmInfoService: ConfirmInfoServiceAPI,
        dismissFlow: @escaping (VerificationResult) -> Void
    ) {
        self.app = app
        self.confirmInfoService = confirmInfoService
        self.dismissFlow = dismissFlow
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case confirmInfo
        case onConfirmInfoFetched(TaskResult<ConfirmInfo?>)
        case finishedWithError(NabuError?)
        case onClose
        case onContinue
        case onDismissError
    }

    struct State: Equatable {
        var title: String = LocalizedString.title
        var firstName: String?
        var lastName: String?
        var addresses: [Address]
        var selectedAddress: Address?
        var dateOfBirth: Date?
        var phone: String?

        @BindableState var form: Form = .init(
            header: .init(
                title: LocalizedString.Body.title,
                description: ""
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
        var conirmInfo: ConfirmInfo?
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
                state.form = .init(
                    header: .init(
                        title: LocalizedString.Body.title,
                        description: ""
                    ),
                    nodes: FormQuestion.personalInfoQuestions(
                        firstName: state.firstName,
                        lastName: state.lastName,
                        addresses: state.addresses,
                        selectedAddress: state.selectedAddress,
                        dateOfBirth: state.dateOfBirth,
                        phone: state.phone
                    ),
                    blocking: true
                )
                return .none

            case .onContinue:
                guard state.isValidForm else {
                    return .none
                }

                return Effect(value: .confirmInfo)

            case .onClose:
                return .fireAndForget {
                    dismissFlow(.abandoned)
                }

            case .onDismissError:
                return .fireAndForget {
                    dismissFlow(.failure)
                }

            case .confirmInfo:
                if state.addresses.count > 1 {
                    state.selectedAddress = state
                        .addresses
                        .enumerated()
                        .first { index, _ in
                            (try? state.form.nodes.answer(id: InputField.answerId(index: index))) ?? false
                        }?
                        .element
                }
                guard
                    let firstName: String = try? state.form.nodes.answer(id: InputField.firstName.rawValue),
                    let lastName: String = try? state.form.nodes.answer(id: InputField.lastName.rawValue),
                    let dateOfBirth: Date = try? state.form.nodes.answer(id: InputField.dateOfBirth.rawValue),
                    let phone: String = try? state.form.nodes.answer(id: InputField.phone.rawValue),
                    let address = state.selectedAddress
                else {
                    return .none
                }
                let confirmInfo: ConfirmInfo = .init(
                    firstName: firstName,
                    lastName: lastName,
                    address: address,
                    dateOfBirth: dateOfBirth,
                    phone: phone
                )
                state.isLoading = true
                return .task {
                    await .onConfirmInfoFetched(
                        TaskResult {
                            try await self.confirmInfoService.confirmInfo(confirmInfo: confirmInfo)
                        }
                    )
                }

            case let .onConfirmInfoFetched(.failure(error)):
                state.isLoading = false
                if let error = error as? NabuError {
                    return Effect(value: .finishedWithError(error))
                } else {
                    return Effect(value: .finishedWithError(nil))
                }

            case .onConfirmInfoFetched(.success(let conirmInfo)):
                state.isLoading = false
                state.conirmInfo = conirmInfo
                return .fireAndForget {
                    dismissFlow(.success(confirmInfo: conirmInfo))
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

extension FormQuestion {

    fileprivate static func addressQuestion(
        addresses: [Address],
        selectedAddress: Address?
    ) -> FormQuestion {
        if addresses.isEmpty {
            return FormQuestion(
                id: ConfirmInformation.InputField.address.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedString.Body.Form.addressNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.address.rawValue,
                        type: .openEnded,
                        isEnabled: false,
                        canHaveDisabledStyle: false,
                        input: ""
                    )
                ]
            )
        } else if addresses.count == 1 {
            return FormQuestion(
                id: ConfirmInformation.InputField.address.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedString.Body.Form.addressNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.address.rawValue,
                        type: .openEnded,
                        isEnabled: false,
                        canHaveDisabledStyle: false,
                        input: selectedAddress?.text
                    )
                ]
            )
        } else {
            let answers: [FormAnswer] = addresses.enumerated().map { index, address in
                FormAnswer(
                    id: ConfirmInformation.InputField.answerId(index: index),
                    type: .selection,
                    text: address.text,
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: address == selectedAddress
                )
            }
            return FormQuestion(
                id: ConfirmInformation.InputField.address.rawValue,
                type: .singleSelection,
                isDropdown: true,
                text: LocalizedString.Body.Form.addressNameInputTitle,
                instructions: nil,
                children: answers
            )
        }
    }

    fileprivate static func personalInfoQuestions(
        firstName: String?,
        lastName: String?,
        addresses: [Address],
        selectedAddress: Address?,
        dateOfBirth: Date?,
        phone: String?
    ) -> [FormQuestion] {
        [
            FormQuestion(
                id: ConfirmInformation.InputField.firstName.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedString.Body.Form.firstNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.firstName.rawValue,
                        type: .openEnded,
                        input: firstName
                    )
                ]
            ),
            FormQuestion(
                id: ConfirmInformation.InputField.lastName.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedString.Body.Form.lastNameInputTitle,
                instructions: nil,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.lastName.rawValue,
                        type: .openEnded,
                        input: lastName
                    )
                ]
            ),
            addressQuestion(addresses: addresses, selectedAddress: selectedAddress),
            FormQuestion(
                id: ConfirmInformation.InputField.dateOfBirth.rawValue,
                type: .openEnded,
                isEnabled: false,
                isDropdown: false,
                text: LocalizedString.Body.Form.dateOfBirthInputTitle,
                instructions: LocalizedString.Body.Form.dateOfBirthInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.dateOfBirth.rawValue,
                        type: .date,
                        isEnabled: false,
                        validation: FormAnswer.Validation(
                            rule: .withinRange,
                            metadata: [
                                .maxValue: String(
                                    (Calendar.current.eighteenYearsAgo ?? Date()).timeIntervalSince1970
                                )
                            ]
                        ),
                        text: nil,
                        input: dateOfBirth?.timeIntervalSince1970.description
                    )
                ]
            ),
            FormQuestion(
                id: ConfirmInformation.InputField.phone.rawValue,
                type: .openEnded,
                isEnabled: false,
                isDropdown: false,
                text: LocalizedString.Body.Form.phoneInputTitle,
                instructions: LocalizedString.Body.Form.phoneInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: ConfirmInformation.InputField.phone.rawValue,
                        type: .openEnded,
                        isEnabled: false,
                        input: phone
                    )
                ]
            )
        ]
    }
}

extension Address {
    fileprivate var text: String {
        let stateAndPostalCode = [
            state,
            postCode
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: " ")

        return [
            line1,
            line2,
            city,
            stateAndPostalCode
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: ", ")
    }
}

extension ConfirmInformation {

    static func preview(app: AppProtocol) -> ConfirmInformation {
        ConfirmInformation(
            app: app,
            confirmInfoService: NoConfirmInfoService(),
            dismissFlow: { _ in }
        )
    }
}

final class NoConfirmInfoService: ConfirmInfoServiceAPI {
    func confirmInfo(confirmInfo: ConfirmInfo) async throws -> ConfirmInfo? { nil }
}
