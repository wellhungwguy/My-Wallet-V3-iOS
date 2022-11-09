// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Statement: Codable, Equatable {

    public let statementId: String

    public let month: Int

    public let year: Int

    public init(id: String, month: Int, year: Int) {
        statementId = id
        self.month = month
        self.year = year
    }
}
