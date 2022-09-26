// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
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
    let app: AppProtocol

    private let disposeBag = DisposeBag()
    private lazy var setup: Void =  {
        selectionService
            .selectedData
            .bind { [weak self] selection in
                self?.selectionService.record(selection: selection)
            }
            .disposed(by: disposeBag)

        app.modePublisher()
            .asObservable()
            .bind {[weak self] _ in
                print("refresh")
                self?.selectionService.refresh()
            }
            .disposed(by: disposeBag)

    }()

    init(
        exchangeProviding: ExchangeProviding,
        fiatCurrency: FiatCurrencySettingsServiceAPI,
        selectionService: WalletPickerSelectionServiceAPI,
        app: AppProtocol
    ) {
        self.exchangeProviding = exchangeProviding
        self.fiatCurrency = fiatCurrency
        self.selectionService = selectionService
        self.app = app
    }
}
