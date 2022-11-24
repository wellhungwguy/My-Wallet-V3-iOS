// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

struct MetadataResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case version
        case payload
        case signature
        case prevMagicHash = "prev_magic_hash"
        case typeId = "type_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case address
    }

    var version = 0
    var payload = ""
    var signature = ""
    var prevMagicHash: String?
    var typeId = 0
    var createdAt = 0
    var updatedAt = 0
    var address = ""

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.payload = try values.decode(String.self, forKey: .payload)
        self.version = try values.decode(Int.self, forKey: .version)
        self.typeId = try values.decode(Int.self, forKey: .typeId)
        self.signature = try values.decode(String.self, forKey: .signature)
        self.prevMagicHash = try values.decodeIfPresent(String.self, forKey: .prevMagicHash)
        self.createdAt = try values.decode(Int.self, forKey: .createdAt)
        self.updatedAt = try values.decode(Int.self, forKey: .updatedAt)
        self.address = try values.decode(String.self, forKey: .address)
    }
}

extension MetadataPayload {

    init(from response: MetadataResponse) {
        self.init(
            version: response.version,
            payload: response.payload,
            signature: response.signature,
            prevMagicHash: response.prevMagicHash,
            typeId: response.typeId,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            address: response.address
        )
    }
}
