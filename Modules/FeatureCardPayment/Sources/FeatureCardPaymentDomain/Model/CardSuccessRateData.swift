// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation

public struct CardSuccessRateData: Equatable {
    public init(
        block: Bool,
        bin: String,
        ux: UX.Dialog? = nil
    ) {
        self.block = block
        self.bin = bin
        self.ux = ux
    }

    /// Whether or not the card can be used successfully
    /// Per docs, red if true & orange if false
    public let block: Bool

    // Dialog which should be displayed. Optional.
    public let ux: UX.Dialog?

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
        self.block = response.block
        self.ux = response.ux
        self.bin = response.bin
    }
}
