// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Country: Decodable, Equatable {
    public let code: String
    public let name: String

    public init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}
