// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxRelay
import RxSwift

extension Notification.Name {
    public static let fiatCurrencySelected = Notification.Name("fiat_currency_selected")
}

public final class FiatCurrencySelectionService: SelectionServiceAPI {

    public var dataSource: Observable<[SelectionItemViewModel]> {
        provider.currencies
            .map { $0.map(\.selectionItem).sorted() }
    }

    public let selectedDataRelay: BehaviorRelay<SelectionItemViewModel>

    public var selectedData: Observable<SelectionItemViewModel> {
        selectedDataRelay.distinctUntilChanged()
    }

    private let provider: FiatCurrencySelectionProviderAPI

    public init(
        defaultSelectedData: FiatCurrency = .locale,
        provider: FiatCurrencySelectionProviderAPI = DefaultFiatCurrencySelectionProvider()
    ) {
        self.provider = provider
        self.selectedDataRelay = BehaviorRelay(value: defaultSelectedData.selectionItem)
    }
}

extension FiatCurrency {
    fileprivate var selectionItem: SelectionItemViewModel {
        SelectionItemViewModel(
            id: code,
            title: name,
            subtitle: code,
            thumb: .none
        )
    }
}
