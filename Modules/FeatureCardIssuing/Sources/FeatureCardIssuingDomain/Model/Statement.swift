// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Statement: Codable, Equatable {

    public let id: String

    public let month: String

    public let year: String

    public init(id: String, month: String, year: String) {
        self.id = id
        self.month = month
        self.year = year
    }
}
