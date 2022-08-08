// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit
import WalletPayloadKit

public enum CreateAccountIds {
    public struct CreationId: Hashable {}
    public struct ImportId: Hashable {}
}

public enum CreateAccountContext: Equatable {
    case importWallet(mnemonic: String)
    case createWallet

    var mnemonic: String? {
        switch self {
        case .importWallet(let mnemonic):
            return mnemonic
        case .createWallet:
            return nil
        }
    }
}

public enum CreateAccountRoute: NavigationRoute {
    private typealias LocalizedStrings = LocalizationConstants.Authentication.CountryAndStatePickers

    case countryPicker
    case statePicker

    @ViewBuilder
    public func destination(in store: Store<CreateAccountState, CreateAccountAction>) -> some View {
        switch self {
        case .countryPicker:
            WithViewStore(store) { viewStore in
                ModalContainer(
                    title: LocalizedStrings.countriesPickerTitle,
                    subtitle: LocalizedStrings.countriesPickerSubtitle,
                    onClose: viewStore.send(.set(\.$selectedAddressSegmentPicker, nil))
                ) {
                    CountryPickerView(selectedItem: viewStore.binding(\.$country))
                }
            }

        case .statePicker:
            WithViewStore(store) { viewStore in
                ModalContainer(
                    title: LocalizedStrings.statesPickerTitle,
                    subtitle: LocalizedStrings.statesPickerSubtitle,
                    onClose: viewStore.send(.set(\.$selectedAddressSegmentPicker, nil))
                ) {
                    StatePickerView(selectedItem: viewStore.binding(\.$countryState))
                }
            }
        }
    }
}

public struct CreateAccountState: Equatable, NavigationState {

    public enum InputValidationError: Equatable {
        case invalidEmail
        case weakPassword
        case noCountrySelected
        case noCountryStateSelected
        case termsNotAccepted
        case invalidReferralCode
    }

    public enum InputValidationState: Equatable {
        case unknown
        case valid
        case invalid(InputValidationError)

        var isInvalid: Bool {
            switch self {
            case .invalid:
                return true
            case .valid, .unknown:
                return false
            }
        }
    }

    public enum Field: Equatable {
        case email
        case password
        case referralCode
    }

    enum AddressSegmentPicker: Hashable {
        case country
        case countryState
    }

    public var route: RouteIntent<CreateAccountRoute>?
    public var context: CreateAccountContext

    // User Input
    @BindableState public var emailAddress: String
    @BindableState public var password: String
    @BindableState public var referralCode: String
    @BindableState public var country: SearchableItem<String>?
    @BindableState public var countryState: SearchableItem<String>?
    @BindableState public var termsAccepted: Bool = false

    // Form interaction
    @BindableState public var passwordFieldTextVisible: Bool = false
    @BindableState public var selectedInputField: Field?
    @BindableState var selectedAddressSegmentPicker: AddressSegmentPicker?

    // Validation
    public var validatingInput: Bool = false
    public var passwordStrength: PasswordValidationScore
    public var inputValidationState: InputValidationState
    public var referralCodeValidationState: InputValidationState
    public var failureAlert: AlertState<CreateAccountAction>?

    public var isCreatingWallet = false
    public var referralFieldEnabled = false

    var isCreateButtonDisabled: Bool {
        validatingInput || inputValidationState.isInvalid || isCreatingWallet || referralCodeValidationState.isInvalid
    }

    var shouldDisplayCountryStateField: Bool {
        country?.id.lowercased() == "us"
    }

    public init(
        context: CreateAccountContext,
        countries: [SearchableItem<String>] = CountryPickerView.countries,
        states: [SearchableItem<String>] = StatePickerView.usaStates
    ) {
        self.context = context
        emailAddress = ""
        password = ""
        referralCode = ""
        passwordStrength = .none
        inputValidationState = .unknown
        referralCodeValidationState = .unknown
    }
}

public enum CreateAccountAction: Equatable, NavigationAction, BindableAction {

    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case onAppear
    case alert(AlertAction)
    case binding(BindingAction<CreateAccountState>)
    // use `createAccount` to perform the account creation. this action is fired after the user confirms the details and the input is validated.
    case createOrImportWallet(CreateAccountContext)
    case createAccount
    case importAccount(_ mnemonic: String)
    case createButtonTapped
    case referralFieldIsEnabled(Bool)
    case didValidateAfterFormSubmission
    case didUpdatePasswordStrenght(PasswordValidationScore)
    case didUpdateInputValidation(CreateAccountState.InputValidationState)
    case didUpdateReferralValidation(CreateAccountState.InputValidationState)
    case validateReferralCode
    case openExternalLink(URL)
    case onWillDisappear
    case route(RouteIntent<CreateAccountRoute>?)
    case validatePasswordStrength
    case accountRecoveryFailed(WalletRecoveryError)
    case accountCreation(Result<WalletCreatedContext, WalletCreationServiceError>)
    case accountImported(Result<Either<WalletCreatedContext, EmptyValue>, WalletCreationServiceError>)
    case walletFetched(Result<Either<EmptyValue, WalletFetchedContext>, WalletFetcherServiceError>)
    case informWalletFetched(WalletFetchedContext)
    // required for legacy flow
    case triggerAuthenticate
    case none
}

struct CreateAccountEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let walletRecoveryService: WalletRecoveryService
    let walletCreationService: WalletCreationService
    let walletFetcherService: WalletFetcherService
    let checkReferralClient: CheckReferralClientAPI?
    let featureFlagsService: FeatureFlagsServiceAPI
    let app: AppProtocol?

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        passwordValidator: PasswordValidatorAPI,
        externalAppOpener: ExternalAppOpener,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        walletRecoveryService: WalletRecoveryService,
        walletCreationService: WalletCreationService,
        walletFetcherService: WalletFetcherService,
        featureFlagsService: FeatureFlagsServiceAPI,
        checkReferralClient: CheckReferralClientAPI? = nil,
        app: AppProtocol? = nil
    ) {
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
        self.walletRecoveryService = walletRecoveryService
        self.walletCreationService = walletCreationService
        self.walletFetcherService = walletFetcherService
        self.checkReferralClient = checkReferralClient
        self.featureFlagsService = featureFlagsService
        self.app = app
    }
}

typealias CreateAccountLocalization = LocalizationConstants.FeatureAuthentication.CreateAccount

let createAccountReducer = Reducer<
    CreateAccountState,
    CreateAccountAction,
    CreateAccountEnvironment
        // swiftlint:disable:next closure_body_length
> { state, action, environment in
    switch action {
    case .binding(\.$emailAddress):
        return Effect(value: .didUpdateInputValidation(.unknown))

    case .binding(\.$password):
        return .merge(
            Effect(value: .didUpdateInputValidation(.unknown)),
            Effect(value: .validatePasswordStrength)
        )

    case .binding(\.$termsAccepted):
        return Effect(value: .didUpdateInputValidation(.unknown))

    case .binding(\.$referralCode):
        return Effect(value: .validateReferralCode)

    case .binding(\.$country):
        return .merge(
            Effect(value: .didUpdateInputValidation(.unknown)),
            Effect(value: .set(\.$selectedAddressSegmentPicker, nil))
        )

    case .binding(\.$countryState):
        return .merge(
            Effect(value: .didUpdateInputValidation(.unknown)),
            Effect(value: .set(\.$selectedAddressSegmentPicker, nil))
        )

    case .binding(\.$selectedAddressSegmentPicker):
        guard let selection = state.selectedAddressSegmentPicker else {
            return Effect(value: .dismiss())
        }
        state.selectedInputField = nil
        switch selection {
        case .country:
            return .enter(into: .countryPicker, context: .none)
        case .countryState:
            return .enter(into: .statePicker, context: .none)
        }

    case .createAccount:
        // by this point we have validated all the fields neccessary
        state.isCreatingWallet = true
        let accountName = CreateAccountLocalization.defaultAccountName
        return .merge(
            Effect(value: .triggerAuthenticate),
            environment.walletCreationService
                .createWallet(
                    state.emailAddress,
                    state.password,
                    accountName
                )
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: CreateAccountIds.CreationId(), cancelInFlight: true)
                .map(CreateAccountAction.accountCreation)
        )

    case .createOrImportWallet(.createWallet):
        guard state.inputValidationState == .valid else {
            return .none
        }
        return Effect(value: .createAccount)

    case .createOrImportWallet(.importWallet(let mnemonic)):
        guard state.inputValidationState == .valid else {
            return .none
        }
        return Effect(value: .importAccount(mnemonic))

    case .validateReferralCode:
        return environment
            .validateReferralInput(code: state.referralCode)
            .map(CreateAccountAction.didUpdateReferralValidation)
            .receive(on: environment.mainQueue)
            .eraseToEffect()

    case .importAccount(let mnemonic):
        state.isCreatingWallet = true
        let accountName = CreateAccountLocalization.defaultAccountName
        return .merge(
            Effect(value: .triggerAuthenticate),
            environment.walletCreationService
                .importWallet(
                    state.emailAddress,
                    state.password,
                    accountName,
                    mnemonic
                )
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: CreateAccountIds.ImportId(), cancelInFlight: true)
                .map(CreateAccountAction.accountImported)
        )

    case .accountCreation(.failure(let error)),
         .accountImported(.failure(let error)):
        state.isCreatingWallet = false
        let title = LocalizationConstants.Errors.error
        let message = String(describing: error)
        return .merge(
            Effect(
                value: .alert(
                    .show(title: title, message: message)
                )
            ),
            .cancel(id: CreateAccountIds.CreationId()),
            .cancel(id: CreateAccountIds.ImportId())
        )

    case .accountCreation(.success(let context)),
         .accountImported(.success(.left(let context))):
        guard let selectedCountry = state.country else {
            return Effect(value: .didUpdateInputValidation(.invalid(.noCountrySelected)))
        }
        guard state.countryState != nil || !state.shouldDisplayCountryStateField else {
            return Effect(value: .didUpdateInputValidation(.invalid(.noCountryStateSelected)))
        }

        return .concatenate(
            Effect(value: .triggerAuthenticate),
            environment
                .saveReferral(with: state.referralCode)
                .fireAndForget(),
            .merge(
                .cancel(id: CreateAccountIds.CreationId()),
                .cancel(id: CreateAccountIds.ImportId()),
                environment
                    .walletCreationService
                    .setResidentialInfo(selectedCountry.id, state.countryState?.id)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                environment.walletCreationService
                    .updateCurrencyForNewWallets(selectedCountry.id, context.guid, context.sharedKey)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .fireAndForget(),
                environment.walletFetcherService
                    .fetchWallet(context.guid, context.sharedKey, context.password)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(CreateAccountAction.walletFetched)
            )
        )

    case .walletFetched(.success(.left(.noValue))):
        // do nothing, this for the legacy JS, to be removed
        return .none

    case .walletFetched(.success(.right(let context))):
        return Effect(value: .informWalletFetched(context))

    case .walletFetched(.failure(let error)):
        let title = LocalizationConstants.ErrorAlert.title
        let message = error.errorDescription ?? LocalizationConstants.ErrorAlert.message
        return Effect(
            value: .alert(
                .show(title: title, message: message)
            )
        )

    case .informWalletFetched:
        return .none

    case .accountImported(.success(.right(.noValue))):
        // this will only be true in case of legacy wallet
        return .cancel(id: CreateAccountIds.ImportId())

    case .createButtonTapped:
        state.validatingInput = true
        state.selectedInputField = nil

        return Effect.concatenate(
            environment
                .validateInputs(state: state)
                .map(CreateAccountAction.didUpdateInputValidation)
                .receive(on: environment.mainQueue)
                .eraseToEffect(),

            environment
                .featureFlagsService.isEnabled(.referral)
                .flatMap { [state] isEnabled -> Effect<CreateAccountAction, Never> in
                    guard isEnabled == true else {
                        return .none
                    }
                    return environment
                        .checkReferralCode(state.referralCode)
                        .map(CreateAccountAction.didUpdateReferralValidation)
                        .receive(on: environment.mainQueue)
                        .eraseToEffect()
                }
                .eraseToEffect(),

            Effect(value: .didValidateAfterFormSubmission)
        )

    case .didValidateAfterFormSubmission:
        guard !state.inputValidationState.isInvalid,
              !state.referralCodeValidationState.isInvalid
        else {
            return .none
        }

        return Effect(value: .createOrImportWallet(state.context))

    case .didUpdatePasswordStrenght(let score):
        state.passwordStrength = score
        return .none

    case .didUpdateInputValidation(let validationState):
        state.validatingInput = false
        state.inputValidationState = validationState
        return .none

    case .didUpdateReferralValidation(let validationState):
        state.referralCodeValidationState = validationState
        return .none

    case .openExternalLink(let url):
        environment.externalAppOpener.open(url)
        return .none

    case .onWillDisappear:
        return .none

    case .route(let route):
        state.route = route
        return .none

    case .validatePasswordStrength:
        return environment
            .passwordValidator
            .validate(password: state.password)
            .map(CreateAccountAction.didUpdatePasswordStrenght)
            .receive(on: environment.mainQueue)
            .eraseToEffect()

    case .accountRecoveryFailed(let error):
        let title = LocalizationConstants.Errors.error
        let message = error.localizedDescription
        return Effect(value: .alert(.show(title: title, message: message)))

    case .alert(.show(let title, let message)):
        state.failureAlert = AlertState(
            title: TextState(verbatim: title),
            message: TextState(verbatim: message),
            dismissButton: .default(
                TextState(LocalizationConstants.okString),
                action: .send(.alert(.dismiss))
            )
        )
        return .none

    case .alert(.dismiss):
        state.failureAlert = nil
        return .none

    case .triggerAuthenticate:
        return .none

    case .none:
        return .none

    case .binding:
        return .none

    case .referralFieldIsEnabled(let enabled):
        state.referralFieldEnabled = enabled
        return .none

    case .onAppear:
        return environment
            .featureFlagsService
            .isEnabled(.referral)
            .map(CreateAccountAction.referralFieldIsEnabled)
            .receive(on: environment.mainQueue)
            .eraseToEffect()
    }
}
.binding()
.analytics()

extension CreateAccountEnvironment {

    fileprivate func validateInputs(
        state: CreateAccountState
    ) -> AnyPublisher<CreateAccountState.InputValidationState, Never> {
        guard state.emailAddress.isEmail else {
            return .just(.invalid(.invalidEmail))
        }
        let didAcceptTerm = state.termsAccepted
        let hasValidCountry = state.country != nil
        let hasValidCountryState = state.countryState != nil || !state.shouldDisplayCountryStateField
        return passwordValidator
            .validate(password: state.password)
            .map { passwordStrength -> CreateAccountState.InputValidationState in
                guard passwordStrength.isValid else {
                    return .invalid(.weakPassword)
                }
                guard hasValidCountry else {
                    return .invalid(.noCountrySelected)
                }
                guard hasValidCountryState else {
                    return .invalid(.noCountryStateSelected)
                }
                guard didAcceptTerm else {
                    return .invalid(.termsNotAccepted)
                }
                return .valid
            }
            .eraseToAnyPublisher()
    }

    fileprivate func validateReferralInput(
        code: String
    ) -> AnyPublisher<CreateAccountState.InputValidationState, Never> {
        guard code.range(
            of: TextRegex.noSpecialCharacters.rawValue,
            options: .regularExpression
        ) != nil else { return .just(.invalid(.invalidReferralCode)) }

        return .just(.unknown)
    }

    fileprivate func checkReferralCode(_
        code: String
    ) -> AnyPublisher<CreateAccountState.InputValidationState, Never> {
        guard code.isNotEmpty, let client = checkReferralClient else { return .just(.unknown) }
        return client
            .checkReferral(with: code)
            .map { _ in
                CreateAccountState.InputValidationState.valid
            }
            .catch { _ -> AnyPublisher<CreateAccountState.InputValidationState, Never> in
                .just(.invalid(.invalidReferralCode))
            }
            .eraseToAnyPublisher()
    }

    func saveReferral(with code: String) -> Effect<Void, Never> {
        if code.isNotEmpty {
            app?.post(value: code, of: blockchain.user.creation.referral.code)
        }
        return .none
    }
}

// MARK: - Private

extension Reducer where
    Action == CreateAccountAction,
    State == CreateAccountState,
    Environment == CreateAccountEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CreateAccountState,
                CreateAccountAction,
                CreateAccountEnvironment
            > { state, action, environment in
                switch action {
                case .onWillDisappear:
                    if case .importWallet = state.context {
                        environment.analyticsRecorder.record(
                            event: .importWalletCancelled
                        )
                    }
                    return .none
                case .createButtonTapped:
                    if case .importWallet = state.context {
                        environment.analyticsRecorder.record(
                            event: .importWalletConfirmed
                        )
                    }
                    return .none
                case .accountCreation(.success):
                    environment.analyticsRecorder.record(
                        event: AnalyticsEvents.New.SignUpFlow.walletSignedUp
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
