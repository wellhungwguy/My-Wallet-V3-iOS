// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct AddressBookEntry: Equatable {
    public let addr: String
    public let label: String

    public init(
        addr: String,
        label: String
    ) {
        self.addr = addr
        self.label = label
    }
}
