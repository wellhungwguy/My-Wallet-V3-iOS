// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import SwiftUI

extension Text {

    init(amount: Double, currency: FiatCurrency) {
        self.init(.create(major: amount, currency: currency))
    }

    init(_ fiatValue: FiatValue) {
        self.init(fiatValue.displayString)
    }
}

extension String {

    init(amount: Double, currency: FiatCurrency) {
        self.init(.create(major: amount, currency: currency))
    }

    init(_ fiatValue: FiatValue) {
        self = fiatValue.displayString
    }
}
