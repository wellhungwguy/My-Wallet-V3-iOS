// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

protocol TransactionsClientAPI {
    func buildTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: BuildTxRequestData
    ) -> AnyPublisher<BuildTxResponse, NetworkError>

    func pushTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: PushTxRequestData
    ) -> AnyPublisher<PushTxResponse, NetworkError>
}

extension Client: TransactionsClientAPI {
    private struct BuildTxRequestPayload: Encodable {
        let auth: AuthDataPayload
        let currency: String
        let account: Int
        let type: String
        let destination: String
        let amount: String
        let fee: String
        let maxVerificationVersion: Int?
    }

    private struct PushTxRequestPayload: Encodable {
        struct Signature: Encodable {
            let preImage: String
            let signingKey: String
            let signatureAlgorithm: String
            let signature: String
        }

        let auth: AuthDataPayload
        let currency: String
        let signatures: [Signature]
    }

    func buildTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: BuildTxRequestData
    ) -> AnyPublisher<BuildTxResponse, NetworkError> {
        let payload = BuildTxRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            currency: transaction.currency,
            account: transaction.account,
            type: transaction.type,
            destination: transaction.destination,
            amount: transaction.amount,
            fee: transaction.fee,
            maxVerificationVersion: transaction.maxVerificationVersion
        )
        let request = requestBuilder
            .post(
                path: Endpoint.buildTx,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
    }

    func pushTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: PushTxRequestData
    ) -> AnyPublisher<PushTxResponse, NetworkError> {
        let payload = PushTxRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            currency: transaction.currency,
            signatures: transaction.signatures.map { signature in
                PushTxRequestPayload.Signature(
                    preImage: signature.preImage,
                    signingKey: signature.signingKey,
                    signatureAlgorithm: signature.signatureAlgorithm,
                    signature: signature.signature
                )
            }
        )
        let request = requestBuilder
            .post(
                path: Endpoint.pushTx,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
    }
}
