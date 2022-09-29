// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxSwift
@testable import StellarKit
import stellarsdk

final class HorizonProxyMock: HorizonProxyAPI {

    /// Add an entry for each account you want to mock:
    /// e.g. "<id>":  AccountResponse.JSON.valid(accountID: "1", balance: "10000")
    var underlyingAccountResponseJSONMap: [String: String] = [:]

    func accountResponse(
        for accountID: String
    ) -> AnyPublisher<AccountResponse, StellarNetworkError> {
        guard let json = underlyingAccountResponseJSONMap[accountID] else {
            return .failure(.notFound)
        }
        let decoder = JSONDecoder()
        do {
            let data: Data = json.data(using: .utf8)!
            let result = try decoder.decode(AccountResponse.self, from: data)
            return .just(result)
        } catch {
            fatalError(String(describing: error))
        }
    }

    var underlyingMinimumBalance: CryptoValue = .create(minor: 1, currency: .stellar)

    func minimumBalance(subentryCount: UInt) -> CryptoValue {
        underlyingMinimumBalance
    }

    func sign(transaction: Transaction, keyPair: stellarsdk.KeyPair) -> Completable {
        .empty()
    }

    func submitTransaction(transaction: Transaction) -> Single<TransactionPostResponseEnum> {
        .never()
    }
}

extension AccountResponse {
    enum JSON {}
}

extension AccountResponse.JSON {
    static func valid(accountID: String, balance: String) -> String {
        """
        {
        "_links": {},
        "id": "\(accountID)",
        "paging_token": "",
        "account_id": "\(accountID)",
        "sequence": "0",
        "subentry_count": 0,
        "thresholds": {
          "low_threshold": 0,
          "med_threshold": 0,
          "high_threshold": 0
        },
        "flags": {
          "auth_required": false,
          "auth_revocable": false,
          "auth_immutable": false
        },
        "balances": [
          {
            "balance": "\(balance)",
            "buying_liabilities": "0.0000000",
            "selling_liabilities": "0.0000000",
            "asset_type": "native"
          }
        ],
        "signers": [],
        "data": {}
        }
        """
    }
}
