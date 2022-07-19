// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public protocol ActivityServiceContaining {
    var exchangeProviding: ExchangeProviding { get }
    var fiatCurrency: FiatCurrencySettingsServiceAPI { get }
    var selectionService: WalletPickerSelectionServiceAPI { get }
}

final class ActivityServiceContainer: ActivityServiceContaining {
    let exchangeProviding: ExchangeProviding
    let fiatCurrency: FiatCurrencySettingsServiceAPI
    let selectionService: WalletPickerSelectionServiceAPI

    private let disposeBag = DisposeBag()
    private lazy var setup: Void = selectionService
        .selectedData
        .bind { [weak self] selection in
            self?.selectionService.record(selection: selection)
        }
        .disposed(by: disposeBag)

    init(
        exchangeProviding: ExchangeProviding,
        fiatCurrency: FiatCurrencySettingsServiceAPI,
        selectionService: WalletPickerSelectionServiceAPI
    ) {
        self.exchangeProviding = exchangeProviding
        self.fiatCurrency = fiatCurrency
        self.selectionService = selectionService
    }
}
