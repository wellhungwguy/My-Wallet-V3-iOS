// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation

public struct CardSuccessRateData: Equatable {
    public init(
        block: Bool,
        bin: String,
        ux: Nabu.Error.UX? = nil
    ) {
        self.block = block
        self.bin = bin
        self.ux = ux
    }

    /// Whether or not the card can be used successfully
    /// Per docs, red if true & orange if false
    public let block: Bool

    // Error which should be displayed. Optional.
    public let ux: Nabu.Error.UX?

    /// The bin number associated with the card
    public let bin: String
}

extension CardSuccessRateData {
    public static func `default`(bin: String) -> CardSuccessRateData {
        .init(block: false, bin: bin)
    }
}

// MARK: - Response Setup

extension CardSuccessRateData {

    public init(response: CardSuccessRate.Response) {
        block = response.block
        ux = response.ux
        bin = response.bin
    }
}
