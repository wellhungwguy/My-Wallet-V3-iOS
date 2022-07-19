// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class FiatCustodialBalanceViewPresenter: Equatable {

    // MARK: - Types

    enum PresentationStyle {
        case border
        case plain
    }

    struct Descriptors {
        let currencyNameFont: UIFont
        let currencyNameFontColor: UIColor
        let currencyNameAccessibilityId: Accessibility
        let currencyCodeFont: UIFont
        let currencyCodeFontColor: UIColor
        let currencyCodeAccessibilityId: Accessibility
        let badgeImageAccessibilitySuffix: String
        let balanceViewDescriptors: FiatBalanceViewAsset.Value.Presentation.Descriptors
    }

    /// Emits tap events
    var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    let fiatBalanceViewPresenter: FiatBalanceViewPresenter

    /// The badge showing the currency symbol
    var badgeImageViewModel: Driver<BadgeImageViewModel> {
        badgeRelay.asDriver()
    }

    /// The name of the currency showed in the balance
    var currencyName: Driver<LabelContent> {
        currencyNameRelay.asDriver()
    }

    /// The currency code of the currency showed in the balance
    var currencyCode: Driver<LabelContent> {
        currencyCodeRelay.asDriver()
    }

    var currencyType: CurrencyType {
        interactor.currencyType
    }

    let tapRelay = PublishRelay<Void>()
    let respondsToTaps: Bool
    let presentationStyle: PresentationStyle

    private let badgeRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    private let currencyNameRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let currencyCodeRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let interactor: FiatCustodialBalanceViewInteractor
    private let disposeBag = DisposeBag()

    init(
        interactor: FiatCustodialBalanceViewInteractor,
        descriptors: Descriptors,
        respondsToTaps: Bool,
        presentationStyle: PresentationStyle
    ) {
        self.interactor = interactor
        self.respondsToTaps = respondsToTaps
        self.presentationStyle = presentationStyle
        fiatBalanceViewPresenter = FiatBalanceViewPresenter(
            interactor: interactor.balanceViewInteractor,
            descriptors: descriptors.balanceViewDescriptors
        )

        interactor
            .fiatCurrency
            .map { currency in
                .primary(
                    image: currency.logoResource,
                    contentColor: .white,
                    backgroundColor: currency.brandColor,
                    cornerRadius: .roundedHigh,
                    accessibilityIdSuffix: descriptors.badgeImageAccessibilitySuffix
                )
            }
            .bindAndCatch(to: badgeRelay)
            .disposed(by: disposeBag)

        interactor
            .fiatCurrency
            .map(\.code)
            .map {
                .init(
                    text: $0,
                    font: descriptors.currencyCodeFont,
                    color: descriptors.currencyCodeFontColor,
                    accessibility: descriptors.currencyCodeAccessibilityId
                )
            }
            .bindAndCatch(to: currencyCodeRelay)
            .disposed(by: disposeBag)

        interactor
            .fiatCurrency
            .map(\.name)
            .map {
                .init(
                    text: $0,
                    font: descriptors.currencyNameFont,
                    color: descriptors.currencyNameFontColor,
                    accessibility: descriptors.currencyNameAccessibilityId
                )
            }
            .bindAndCatch(to: currencyNameRelay)
            .disposed(by: disposeBag)
    }
}

extension FiatCustodialBalanceViewPresenter {
    static func == (lhs: FiatCustodialBalanceViewPresenter, rhs: FiatCustodialBalanceViewPresenter) -> Bool {
        lhs.interactor == rhs.interactor
    }
}

extension FiatCustodialBalanceViewPresenter.Descriptors {
    typealias Descriptors = FiatCustodialBalanceViewPresenter.Descriptors
    typealias DashboardAccessibility = Accessibility.Identifier.Dashboard.FiatCustodialCell

    static func dashboard(
        baseAccessibilitySuffix: String = "",
        quoteAccessibilitySuffix: String = ""
    ) -> Descriptors {
        Descriptors(
            currencyNameFont: .main(.semibold, 20.0),
            currencyNameFontColor: .textFieldText,
            currencyNameAccessibilityId: .id(DashboardAccessibility.currencyName),
            currencyCodeFont: .main(.medium, 14.0),
            currencyCodeFontColor: .descriptionText,
            currencyCodeAccessibilityId: .id(DashboardAccessibility.currencyCode),
            badgeImageAccessibilitySuffix: DashboardAccessibility.currencyBadgeView,
            balanceViewDescriptors: .dashboard(
                baseAccessibilitySuffix: baseAccessibilitySuffix,
                quoteAccessibilitySuffix: quoteAccessibilitySuffix
            )
        )
    }

    static func paymentMethods(
        baseAccessibilitySuffix: String = "",
        quoteAccessibilitySuffix: String = ""
    ) -> Descriptors {
        Descriptors(
            currencyNameFont: .main(.semibold, 16),
            currencyNameFontColor: .textFieldText,
            currencyNameAccessibilityId: .id(DashboardAccessibility.currencyName),
            currencyCodeFont: .main(.medium, 14),
            currencyCodeFontColor: .descriptionText,
            currencyCodeAccessibilityId: .id(DashboardAccessibility.currencyCode),
            badgeImageAccessibilitySuffix: DashboardAccessibility.currencyBadgeView,
            balanceViewDescriptors: .paymentMethods(
                baseAccessibilitySuffix: baseAccessibilitySuffix,
                quoteAccessibilitySuffix: quoteAccessibilitySuffix
            )
        )
    }
}
