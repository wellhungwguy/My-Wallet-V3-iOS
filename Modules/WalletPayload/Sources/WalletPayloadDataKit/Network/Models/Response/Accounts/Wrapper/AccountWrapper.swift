// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// Helper wrapper for Account model variations
enum AccountWrapper {
    struct Version3: Equatable, Codable {
        let label: String
        let archived: Bool
        let xpriv: String
        let xpub: String
        let addressLabels: [AddressLabelResponse]
        let cache: AddressCacheResponse

        enum CodingKeys: String, CodingKey {
            case label
            case archived
            case xpriv
            case xpub
            case addressLabels = "address_labels"
            case cache
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            label = try container.decode(String.self, forKey: .label)
            // some clients might not send the `archived` key/value, so we check this and default to `false`
            archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            xpriv = try container.decode(String.self, forKey: .xpriv)
            xpub = try container.decode(String.self, forKey: .xpub)
            addressLabels = try container.decode([AddressLabelResponse].self, forKey: .addressLabels)
            cache = try container.decode(AddressCacheResponse.self, forKey: .cache)
        }

        init(
            label: String,
            archived: Bool,
            xpriv: String,
            xpub: String,
            addressLabels: [AddressLabelResponse],
            cache: AddressCacheResponse
        ) {
            self.label = label
            self.archived = archived
            self.xpriv = xpriv
            self.xpub = xpub
            self.addressLabels = addressLabels
            self.cache = cache
        }
    }

    struct Version4: Equatable, Codable {
        let label: String
        let archived: Bool
        let defaultDerivation: String
        let derivations: [DerivationResponse]

        enum CodingKeys: String, CodingKey {
            case label
            case archived
            case defaultDerivation = "default_derivation"
            case derivations
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            label = try container.decode(String.self, forKey: .label)
            // some clients might not send the `archived` key/value, so we check this and default to `false`
            archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            defaultDerivation = try container.decode(String.self, forKey: .defaultDerivation)
            derivations = try container.decode([DerivationResponse].self, forKey: .derivations)
        }

        init(
            label: String,
            archived: Bool,
            defaultDerivation: String,
            derivations: [DerivationResponse]
        ) {
            self.label = label
            self.archived = archived
            self.defaultDerivation = defaultDerivation
            self.derivations = derivations
        }
    }
}
