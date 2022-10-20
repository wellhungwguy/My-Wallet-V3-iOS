// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct RecurringBuyRequest: Encodable {
    let inputValue: String
    let inputCurrency: String
    let destinationCurrency: String
    let paymentMethod: String
    let period: String
    let beneficiaryId: String
}
