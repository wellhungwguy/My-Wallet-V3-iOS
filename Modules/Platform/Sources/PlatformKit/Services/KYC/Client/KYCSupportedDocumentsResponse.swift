// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Network response for the `/kyc/supported-documents/{country_code}`
public struct KYCSupportedDocumentsResponse: Codable {
    public let countryCode: String
    public let documentTypes: [KYCDocumentType]

    private enum CodingKeys: String, CodingKey {
        case countryCode
        case documentTypes
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.countryCode = try values.decode(String.self, forKey: .countryCode)
        let documentTypesRaw = try values.decode([String].self, forKey: .documentTypes)
        self.documentTypes = documentTypesRaw.compactMap {
            KYCDocumentType(rawValue: $0)
        }
    }
}
