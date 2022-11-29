// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AccountResponse: Equatable, Codable {
    let label: String
    let archived: Bool
    let defaultDerivation: DerivationResponse.Format
    let derivations: [DerivationResponse]

    enum CodingKeys: String, CodingKey {
        case label
        case archived
        case defaultDerivation = "default_derivation"
        case derivations
    }

    init(from decoder: Decoder) throws {
        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        label = try keyed.decode(String.self, forKey: .label)
        // some clients might not send various properties, so we check and provide a default value
        archived = try keyed.decodeIfPresent(Bool.self, forKey: .archived) ?? false
        defaultDerivation = try keyed.decodeIfPresent(DerivationResponse.Format.self, forKey: .defaultDerivation) ?? .segwit
        derivations = try keyed.decode([DerivationResponse].self, forKey: .derivations)
    }

    init(
        label: String,
        archived: Bool,
        defaultDerivation: DerivationResponse.Format,
        derivations: [DerivationResponse]
    ) {
        self.label = label
        self.archived = archived
        self.defaultDerivation = defaultDerivation
        self.derivations = derivations
    }
}

extension WalletPayloadKit.Account {
    static func from(model: AccountResponse, index: Int) -> Account {
        Account(
            index: index,
            label: model.label,
            archived: model.archived,
            defaultDerivation: model.defaultDerivation.toType,
            derivations: model.derivations.map(WalletPayloadKit.Derivation.from(model:))
        )
    }

    var toAccountResponse: AccountResponse {
        AccountResponse(
            label: label,
            archived: archived,
            defaultDerivation: defaultDerivation.toDerivationFormat,
            derivations: derivations.map(\.derivationResponse)
        )
    }
}
