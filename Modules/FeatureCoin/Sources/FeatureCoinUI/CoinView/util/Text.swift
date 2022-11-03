// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import SwiftUI

extension Text {

    init(amount: Double, currency: FiatCurrency) {
        self.init(.create(major: amount, currency: currency))
    }

    init(_ fiatValue: FiatValue) {
        do {
            if try fiatValue < .one(currency: fiatValue.currency) {
                self.init(fiatValue.toDisplayString(includeSymbol: true, precision: fiatValue.currencyType.storeExtraPrecision))
            } else {
                self.init(fiatValue.toDisplayString(includeSymbol: true))
            }
        } catch {
            self.init(fiatValue.displayString)
        }
    }
}

extension String {

    init(amount: Double, currency: FiatCurrency) {
        self.init(.create(major: amount, currency: currency))
    }

    init(_ fiatValue: FiatValue) {
        do {
            if try fiatValue < .one(currency: fiatValue.currency) {
                self = fiatValue.toDisplayString(includeSymbol: true, precision: fiatValue.currencyType.storeExtraPrecision)
            } else {
                self = fiatValue.toDisplayString(includeSymbol: true)
            }
        } catch {
            self = fiatValue.displayString
        }
    }
}
