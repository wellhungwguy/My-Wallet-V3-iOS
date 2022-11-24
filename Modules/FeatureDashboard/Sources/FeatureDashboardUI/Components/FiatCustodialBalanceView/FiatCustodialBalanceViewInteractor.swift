// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class FiatCustodialBalanceViewInteractor {

    let balanceViewInteractor: FiatBalanceViewInteractor
    let currencyType: CurrencyType

    var fiatCurrency: Observable<FiatCurrency> {
        guard case .fiat(let currency) = currencyType else {
            fatalError("The base currency of `FiatCustodialBalanceViewInteractor` must be a fiat currency type")
        }
        return .just(currency)
    }

    init(account: SingleAccount) {
        self.currencyType = account.currencyType
        self.balanceViewInteractor = FiatBalanceViewInteractor(account: account)
    }

    init(balance: MoneyValue) {
        self.currencyType = balance.currency
        self.balanceViewInteractor = FiatBalanceViewInteractor(balance: balance)
    }
}

extension FiatCustodialBalanceViewInteractor: Equatable {
    static func == (lhs: FiatCustodialBalanceViewInteractor, rhs: FiatCustodialBalanceViewInteractor) -> Bool {
        lhs.currencyType == rhs.currencyType
    }
}
