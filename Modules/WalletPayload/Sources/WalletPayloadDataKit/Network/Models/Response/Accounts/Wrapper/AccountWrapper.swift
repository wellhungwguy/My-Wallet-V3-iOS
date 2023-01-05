// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// Helper wrapper for Account model variations
enum AccountWrapper {
    struct Version3: Equatable, Codable {
        let label: String
        let archived: Bool
        let xpriv: String?
        let xpub: String?
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
            self.label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
            // some clients might not send the `archived` key/value, so we check this and default to `false`
            self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            self.xpriv = try container.decodeIfPresent(String.self, forKey: .xpriv)
            self.xpub = try container.decodeIfPresent(String.self, forKey: .xpub)
            self.addressLabels = try container.decodeIfPresent([AddressLabelResponse].self, forKey: .addressLabels) ?? []
            self.cache = try container.decodeIfPresent(AddressCacheResponse.self, forKey: .cache) ?? AddressCacheResponse.empty
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
            self.label = try container.decode(String.self, forKey: .label)
            // some clients might not send various properties, so we check and provide a default value
            self.archived = try container.decodeIfPresent(Bool.self, forKey: .archived) ?? false
            let defaultDerivationFallback = DerivationResponse.Format.segwit.rawValue
            self.defaultDerivation = try container.decodeIfPresent(String.self, forKey: .defaultDerivation) ?? defaultDerivationFallback
            self.derivations = try container.decode([DerivationResponse].self, forKey: .derivations)
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
