// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import Localization
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

extension Accessibility.Identifier {
    enum Amount {
        static let max = "Amount.useMaxButton"
        static let min = "Amount.useMinButton"
        static let warning = "Amount.warning"
        static let error = "Amount.error"
    }
}

public final class AmountTranslationPresenter: AmountViewPresenting {

    // MARK: - Types

    public struct DisplayBundle {
        public struct Events {
            public let minTappedAnalyticsEvent: AnalyticsEvent
            public let maxTappedAnalyticsEvent: AnalyticsEvent

            public init(min: AnalyticsEvent, max: AnalyticsEvent) {
                minTappedAnalyticsEvent = min
                maxTappedAnalyticsEvent = max
            }
        }

        public struct Strings {
            public let useMin: String
            public let useMax: String

            public init(useMin: String, useMax: String) {
                self.useMin = useMin
                self.useMax = useMax
            }
        }

        public struct AccessibilityIdentifiers {
            public init() {}
        }

        public let strings: Strings
        public let events: Events?
        public let accessibilityIdentifiers: AccessibilityIdentifiers

        public init(
            events: Events?,
            strings: Strings,
            accessibilityIdentifiers: AccessibilityIdentifiers
        ) {
            self.events = events
            self.strings = strings
            self.accessibilityIdentifiers = accessibilityIdentifiers
        }
    }

    public enum Input {
        case input(Character)
        case delete
    }

    private typealias AccessibilityId = Accessibility.Identifier.Amount

    // MARK: - Public Properties

    public let swapButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    public let auxiliaryButtonEnabledRelay = BehaviorRelay<Bool>(value: true)

    // MARK: - Internal Properties

    var activeAmountInput: Driver<ActiveAmountInput> {
        interactor.activeInputRelay.asDriver()
    }

    var state: Driver<AmountPresenterState> {
        stateRelay.asDriver()
    }

    var swapButtonVisibility: Driver<Visibility> {
        swapButtonVisibilityRelay.asDriver()
    }

    let swapButtonTapRelay = PublishRelay<Void>()
    let auxiliaryButtonTappedRelay = PublishRelay<Void>()

    var auxiliaryButtonEnabled: Driver<Bool> {
        auxiliaryButtonEnabledRelay.asDriver()
    }

    let maxLimitPublisher: AnyPublisher<FiatValue, Never>
    var lastPurchasePublisher: AnyPublisher<FiatValue, Never> {
        let amount = app.publisher(
            for: blockchain.ux.transaction.source.target.previous.input.amount,
            as: BigInt.self
        )
        .map(\.value)
        let currency = app.publisher(
            for: blockchain.ux.transaction.source.target.previous.input.currency.code,
            as: FiatCurrency.self
        )
        .map(\.value)
        let tradingCurrency = app.publisher(
            for: blockchain.user.currency.preferred.fiat.trading.currency,
            as: FiatCurrency.self
        )
        .compactMap(\.value)
        return amount.combineLatest(currency, tradingCurrency)
            .map { amount, currency, tradingCurrency in
                if let amount = amount, let currency = currency {
                    return FiatValue(amount: amount, currency: currency)
                } else {
                    // If there's no previous purchase default to 50.00 of trading currency
                    return FiatValue(amount: 5000, currency: tradingCurrency)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Injected

    let interactor: AmountTranslationInteractor
    let fiatPresenter: InputAmountLabelPresenter
    let cryptoPresenter: InputAmountLabelPresenter
    let displayBundle: DisplayBundle

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let app: AppProtocol

    // MARK: - Accessors

    private let stateRelay = BehaviorRelay<AmountPresenterState>(value: .validInput(nil))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interactor: AmountTranslationInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        displayBundle: DisplayBundle,
        inputTypeToggleVisibility: Visibility,
        app: AppProtocol,
        maxLimitPublisher: AnyPublisher<FiatValue, Never> = .empty()
    ) {
        self.interactor = interactor
        self.analyticsRecorder = analyticsRecorder
        self.displayBundle = displayBundle
        self.app = app
        self.maxLimitPublisher = maxLimitPublisher

        swapButtonVisibilityRelay.accept(inputTypeToggleVisibility)
        fiatPresenter = .init(interactor: interactor.fiatInteractor, currencyCodeSide: .leading)
        cryptoPresenter = .init(interactor: interactor.cryptoInteractor, currencyCodeSide: .trailing)

        swapButtonTapRelay
            .withLatestFrom(interactor.activeInput)
            .map(\.inverted)
            .bindAndCatch(to: interactor.activeInputRelay)
            .disposed(by: disposeBag)

        auxiliaryButtonTappedRelay
            .bindAndCatch(to: interactor.auxiliaryButtonTappedRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                interactor.state,
                interactor.activeInput
            )
            .map(weak: self) { (self, payload) in
                self.setupButton(by: payload.0)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        interactor.auxiliaryViewEnabledRelay
            .bindAndCatch(to: auxiliaryButtonEnabledRelay)
            .disposed(by: disposeBag)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        interactor.connect(input: input.map(\.toInteractorInput))
            .map { [weak self] state -> AmountPresenterState in
                guard let self = self else { return .validInput(nil) }
                return self.setupButton(by: state)
            }
    }

    private func setupButton(by state: AmountInteractorState) -> AmountPresenterState {
        switch state {
        case .validInput(let messageState):
            return .validInput(buttonViewModel(state: messageState))
        case .invalidInput(let messageState):
            return .invalidInput(buttonViewModel(state: messageState))
        }
    }

    private func buttonViewModel(state: AmountInteractorState.MessageState) -> ButtonViewModel? {
        let viewModel: ButtonViewModel?
        switch state {
        case .none:
            return nil
        case .info(let message):
            viewModel = ButtonViewModel.info(with: message, accessibilityId: message)

        case .warning(let message):
            viewModel = ButtonViewModel.warning(with: message, accessibilityId: message)

        case .error(let message):
            viewModel = ButtonViewModel.error(with: message, accessibilityId: message)
        }

        viewModel?.tap
            .emit(
                onNext: { [interactor] in
                    interactor.auxiliaryButtonTappedRelay.accept(())
                }
            )
            .disposed(by: disposeBag)

        return viewModel
    }
}

extension AmountPresenterInput {
    internal var toInteractorInput: AmountInteractorInput {
        switch self {
        case .input(let value):
            return .insert(value)
        case .delete:
            return .remove
        }
    }
}
