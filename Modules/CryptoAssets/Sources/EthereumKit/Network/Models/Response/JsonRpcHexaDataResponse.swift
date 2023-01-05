// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A Json RPC response with a hexadecimal data field as 'result'.
/// The result field will be converted to a `Data` object.
struct JsonRpcHexaDataResponse: Decodable {

    // MARK: Types

    private enum CodingKeys: CodingKey {
        case result
    }

    // MARK: Properties

    let result: Data

    // MARK: Init

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .result)
        if value.isEmpty || value == "0x" {
            self.result = Data()
        } else {
            self.result = Data(hex: value)
        }
    }
}
