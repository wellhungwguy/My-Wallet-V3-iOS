// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PrefillInfo: Equatable {
    public let fullName: String?
    public let dateOfBirth: Date?
    public let phone: String?

    public init(fullName: String?, dateOfBirth: Date?, phone: String?) {
        self.fullName = fullName
        self.dateOfBirth = dateOfBirth
        self.phone = phone
    }
}
