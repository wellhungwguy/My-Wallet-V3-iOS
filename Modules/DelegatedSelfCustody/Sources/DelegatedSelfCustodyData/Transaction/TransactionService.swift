// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import Errors
import Foundation
import MoneyKit

final class TransactionService: DelegatedCustodyTransactionServiceAPI {

    private let authenticationDataRepository: AuthenticationDataRepositoryAPI
    private let client: TransactionsClientAPI
    private let signingService: DelegatedCustodySigningServiceAPI

    init(
        client: TransactionsClientAPI,
        authenticationDataRepository: AuthenticationDataRepositoryAPI,
        signingService: DelegatedCustodySigningServiceAPI
    ) {
        self.authenticationDataRepository = authenticationDataRepository
        self.client = client
        self.signingService = signingService
    }

    func buildTransaction(
        _ transaction: DelegatedCustodyTransactionInput
    ) -> AnyPublisher<DelegatedCustodyTransactionOutput, DelegatedCustodyTransactionServiceError> {
        authenticationDataRepository.authenticationData
            .mapError(DelegatedCustodyTransactionServiceError.authenticationError)
            .flatMap { [client] authenticationData in
                client.buildTx(
                    guidHash: authenticationData.guidHash,
                    sharedKeyHash: authenticationData.sharedKeyHash,
                    transaction: BuildTxRequestData(input: transaction)
                )
                .mapError(DelegatedCustodyTransactionServiceError.networkError)
            }
            .map(DelegatedCustodyTransactionOutput.init(response:))
            .eraseToAnyPublisher()
    }

    func sign(
        _ transaction: DelegatedCustodyTransactionOutput,
        privateKey: Data
    ) -> Result<DelegatedCustodySignedTransactionOutput, DelegatedCustodyTransactionServiceError> {
        transaction.preImages
            .map { [signingService] preImage in
                signingService.sign(
                    data: Data(hexValue: preImage.preImage),
                    privateKey: privateKey,
                    algorithm: preImage.signatureAlgorithm
                )
                .map { signedData -> DelegatedCustodySignedTransactionOutput.SignedPreImage in
                    DelegatedCustodySignedTransactionOutput.SignedPreImage(
                        preImage: preImage.preImage,
                        signingKey: preImage.signingKey,
                        signatureAlgorithm: preImage.signatureAlgorithm,
                        signature: signedData.toHexString
                    )
                }
            }
            .zip()
            .mapError(DelegatedCustodyTransactionServiceError.signing)
            .map { signatures in
                // TODO: @paulo Add rawTx
                DelegatedCustodySignedTransactionOutput(rawTx: transaction.rawTx, signatures: signatures)
            }
    }

    func pushTransaction(
        _ transaction: DelegatedCustodySignedTransactionOutput,
        currency: CryptoCurrency
    ) -> AnyPublisher<String, DelegatedCustodyTransactionServiceError> {
        authenticationDataRepository.authenticationData
            .mapError(DelegatedCustodyTransactionServiceError.authenticationError)
            .flatMap { [client] authenticationData in
                client.pushTx(
                    guidHash: authenticationData.guidHash,
                    sharedKeyHash: authenticationData.sharedKeyHash,
                    transaction: PushTxRequestData(currency: currency, transaction: transaction)
                )
                .mapError(DelegatedCustodyTransactionServiceError.networkError)
            }
            .map(\.txId)
            .eraseToAnyPublisher()
    }
}

extension DelegatedCustodyTransactionOutput {
    init(response: BuildTxResponse) {
        self.init(
            relativeFee: response.summary.relativeFee,
            absoluteFeeMaximum: response.summary.absoluteFeeMaximum,
            absoluteFeeEstimate: response.summary.absoluteFeeEstimate,
            amount: response.summary.amount,
            balance: response.summary.balance,
            rawTx: response.rawTx,
            preImages: response.preImages.map(PreImage.init(response:))
        )
    }
}

extension DelegatedCustodyTransactionOutput.PreImage {
    init(response: BuildTxResponse.PreImage) {
        self.init(
            preImage: response.preImage,
            signingKey: response.signingKey,
            descriptor: response.descriptor,
            signatureAlgorithm: response.signatureAlgorithm.delegatedCustodySignatureAlgorithm
        )
    }
}

extension DelegatedCustodySignatureAlgorithm {
    var signatureAlgorithmResponse: SignatureAlgorithmResponse {
        switch self {
        case .secp256k1:
            return .secp256k1
        }
    }
}

extension SignatureAlgorithmResponse {
    var delegatedCustodySignatureAlgorithm: DelegatedCustodySignatureAlgorithm {
        switch self {
        case .secp256k1:
            return .secp256k1
        }
    }
}

extension PushTxRequestData {
    init(currency: CryptoCurrency, transaction: DelegatedCustodySignedTransactionOutput) {
        self.currency = currency.code
        rawTx = transaction.rawTx
        signatures = transaction.signatures.map { signature in
            PushTxRequestData.Signature(
                preImage: signature.preImage,
                signingKey: signature.signingKey,
                signatureAlgorithm: signature.signatureAlgorithm.signatureAlgorithmResponse,
                signature: signature.signature
            )
        }
    }
}

extension Data {

    /// Initializes `Data` with a hex string representation.
    public init(hexValue hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                self = Data()
                return
            }
        }
        self = data
    }
}
