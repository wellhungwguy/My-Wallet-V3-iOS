// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol CryptoValueFormatterAPI {
    func format(amount: String, currency: String) -> String
}
