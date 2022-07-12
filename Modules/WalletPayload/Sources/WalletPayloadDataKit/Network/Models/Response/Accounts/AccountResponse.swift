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
        // some clients might not send the `archived` key/value, so we check this and default to `false`
        archived = try keyed.decodeIfPresent(Bool.self, forKey: .archived) ?? false
        defaultDerivation = try keyed.decode(DerivationResponse.Format.self, forKey: .defaultDerivation)
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
            defaultDerivation: DerivationResponse.Format.create(from: model.defaultDerivation),
            derivations: model.derivations.map(WalletPayloadKit.Derivation.from(model:))
        )
    }

    var toAccountResponse: AccountResponse {
        AccountResponse(
            label: label,
            archived: archived,
            defaultDerivation: DerivationResponse.Format.create(type: defaultDerivation),
            derivations: derivations.map(\.derivationResponse)
        )
    }
}
