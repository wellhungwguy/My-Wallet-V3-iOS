// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import ToolKit

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
        struct ExtraData: Encodable {
            let memo: String
            let feeCurrency: String
        }

        let account: Int
        let amount: String
        let auth: AuthDataPayload
        let currency: String
        let destination: String
        let extraData: ExtraData
        let fee: String
        let maxVerificationVersion: Int?
        let type: String
    }

    private struct PushTxRequestPayload: Encodable {
        struct Signature: Encodable {
            let preImage: String
            let signingKey: String
            let signatureAlgorithm: SignatureAlgorithmResponse
            let signature: String
        }

        let auth: AuthDataPayload
        let currency: String
        let rawTx: JSONValue
        let signatures: [Signature]
    }

    func buildTx(
        guidHash: String,
        sharedKeyHash: String,
        transaction: BuildTxRequestData
    ) -> AnyPublisher<BuildTxResponse, NetworkError> {
        let payload = BuildTxRequestPayload(
            account: transaction.account,
            amount: transaction.amount,
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            currency: transaction.currency,
            destination: transaction.destination,
            extraData: BuildTxRequestPayload.ExtraData(memo: transaction.memo, feeCurrency: transaction.feeCurrency),
            fee: transaction.fee,
            maxVerificationVersion: transaction.maxVerificationVersion,
            type: transaction.type
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
            rawTx: transaction.rawTx,
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
