// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct LinkedBankData {
    public let identifier: String
    public let state: LinkedBankState
    public let partner: LinkedBankPartner

    public init(
        identifier: String,
        state: LinkedBankState,
        partner: LinkedBankPartner
    ) {
        self.identifier = identifier
        self.state = state
        self.partner = partner
    }

    public var isActive: Bool {
        state == .active
    }

    public var isLinkedWithPlaid: Bool {
        partner == .plaid
    }
}
