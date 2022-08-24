// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit
import ToolKit

public protocol DelegatedCustodyTransactionServiceAPI {
    func buildTransaction(
        _ transaction: DelegatedCustodyTransactionInput
    ) -> AnyPublisher<DelegatedCustodyTransactionOutput, DelegatedCustodyTransactionServiceError>

    func sign(
        _ transaction: DelegatedCustodyTransactionOutput,
        privateKey: Data
    ) -> Result<DelegatedCustodySignedTransactionOutput, DelegatedCustodyTransactionServiceError>

    func pushTransaction(
        _ transaction: DelegatedCustodySignedTransactionOutput,
        currency: CryptoCurrency
    ) -> AnyPublisher<String, DelegatedCustodyTransactionServiceError>
}

public enum DelegatedCustodyTransactionServiceError: Error {
    case authenticationError(AuthenticationDataRepositoryError)
    case networkError(NetworkError)
    case signing(DelegatedCustodySigningError)
}

public enum AuthenticationDataRepositoryError: Error {
    case missingGUID
    case missingSharedKey
}

public struct DelegatedCustodySignedTransactionOutput {
    public struct SignedPreImage {
        public let preImage: String
        public let signingKey: String
        public let signatureAlgorithm: DelegatedCustodySignatureAlgorithm
        public let signature: String

        public init(
            preImage: String,
            signingKey: String,
            signatureAlgorithm: DelegatedCustodySignatureAlgorithm,
            signature: String
        ) {
            self.preImage = preImage
            self.signingKey = signingKey
            self.signatureAlgorithm = signatureAlgorithm
            self.signature = signature
        }
    }

    public let rawTx: JSONValue
    public let signatures: [SignedPreImage]

    public init(
        rawTx: JSONValue,
        signatures: [DelegatedCustodySignedTransactionOutput.SignedPreImage]
    ) {
        self.rawTx = rawTx
        self.signatures = signatures
    }
}
