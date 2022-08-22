// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

struct TypedDataPayload: Decodable {
    let message: [String: JSONValue]
}
