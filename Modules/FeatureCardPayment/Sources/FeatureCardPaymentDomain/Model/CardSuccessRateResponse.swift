// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors

public struct CardSuccessRate: Decodable {
    public let block: Bool
    public let ux: UX.Dialog?

    public struct Response: Equatable {
        public let bin: String
        public let block: Bool
        public let ux: UX.Dialog?

        public init(
            _ successRate: CardSuccessRate,
            bin: String
        ) {
            self.bin = bin
            block = successRate.block
            ux = successRate.ux
        }
    }
}
