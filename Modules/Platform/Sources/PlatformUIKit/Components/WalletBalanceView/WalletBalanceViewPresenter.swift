// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitectureExtensions
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class WalletBalanceViewPresenter {

    typealias AccessibilityId = Accessibility.Identifier.Activity.WalletBalance
    public typealias PresentationState = LoadingState<WalletBalance>

    public struct WalletBalance {
        /// The balance in fiat
        public let fiatBalance: LabelContent

        /// The fiat currency code
        public let currencyCode: LabelContent

        /// Descriptors that allows customized content and style
        public struct Descriptors {
            let fiatFont: UIFont
            let fiatTextColor: UIColor
            let descriptionFont: UIFont
            let descriptionTextColor: UIColor

            public init(
                fiatFont: UIFont,
                fiatTextColor: UIColor,
                descriptionFont: UIFont,
                descriptionTextColor: UIColor
            ) {
                self.fiatFont = fiatFont
                self.fiatTextColor = fiatTextColor
                self.descriptionFont = descriptionFont
                self.descriptionTextColor = descriptionTextColor
            }
        }

        // MARK: - Setup

        public init(
            with value: WalletBalanceViewInteractor.WalletBalance,
            descriptors: Descriptors = .default
        ) {
            self.fiatBalance = LabelContent(
                text: value.fiatValue.displayString,
                font: descriptors.fiatFont,
                color: descriptors.fiatTextColor,
                accessibility: .id(AccessibilityId.fiatBalance)
            )

            self.currencyCode = LabelContent(
                text: value.fiatCurrency.displayCode,
                font: descriptors.descriptionFont,
                color: descriptors.descriptionTextColor,
                accessibility: .id(AccessibilityId.currencyCode)
            )
        }
    }

    // MARK: - Exposed Properties

    let accessibility: Accessibility = .id(AccessibilityId.view)

    public var state: Observable<PresentationState> {
        stateRelay
            .observe(on: MainScheduler.instance)
    }

    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }

    // MARK: - Injected

    private let interactor: WalletBalanceViewInteractor

    // MARK: - Private Accessors

    private let alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: .fill)
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        alignment: UIStackView.Alignment = .trailing,
        interactor: WalletBalanceViewInteractor,
        descriptors: WalletBalanceViewPresenter.WalletBalance.Descriptors = .default
    ) {
        self.interactor = interactor
        alignmentRelay.accept(alignment)

        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map { .init(with: $0, descriptors: descriptors) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

extension WalletBalanceViewPresenter.WalletBalance.Descriptors {
    public typealias Descriptors = WalletBalanceViewPresenter.WalletBalance.Descriptors
    public static let `default` = Descriptors(
        fiatFont: .main(.semibold, 16.0),
        fiatTextColor: .textFieldText,
        descriptionFont: .main(.medium, 14.0),
        descriptionTextColor: .descriptionText
    )
}

extension LoadingState where Content == WalletBalanceViewPresenter.WalletBalance {
    init(
        with state: LoadingState<WalletBalanceViewInteractor.WalletBalance>,
        descriptors: WalletBalanceViewPresenter.WalletBalance.Descriptors
    ) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    descriptors: descriptors
                )
            )
        }
    }
}
