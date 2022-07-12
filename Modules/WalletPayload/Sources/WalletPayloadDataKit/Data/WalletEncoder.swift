// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletPayloadKit

/// Responsible for encoding a `Wrapper` and `Wallet` data types into network types.
///
/// - Note: There are two steps we need to take care of before we insert the wallet on the backend.
///
/// We first need to transform the `Wallet` to `WalletResponse` to `Data` and create `EncodedWalletPayload`
/// using the `tranform(wrapper:)` method.
///
/// We then call the `encode(payload:)` passing the `EncodedWalletPayload` with the updated **encrypted** value,
/// which we finally create the `WrapperResponse`.
final class WalletEncoder: WalletEncodingAPI {

    // `EncodedWalletPayload` > `WrapperResponse` > `Data` stored in `WalletCreationPayload`
    func encode(
        payload: EncodedWalletPayload,
        applyChecksum: @escaping (Data) -> String
    ) -> AnyPublisher<WalletCreationPayload, WalletEncodingError> {
        createInnerWrapperResponse(context: payload)
            .flatMap { wrapper -> Result<Data, WalletEncodingError> in
                encodeValue(of: wrapper)
                    .mapError(WalletEncodingError.encodingError)
            }
            .publisher
            .map { value in
                WalletCreationPayload(
                    data: value,
                    wrapper: payload.wrapper,
                    applyChecksum: applyChecksum
                )
            }
            .eraseToAnyPublisher()
    }

    // `Wrapper.Wallet` > `WalletResponse` > `Data` stored in `EncodedWalletPayload`
    func transform(wrapper: Wrapper) -> AnyPublisher<EncodedWalletPayload, WalletEncodingError> {
        encodeValue(of: wrapper.wallet.toWalletResponse)
            .map { data in
                EncodedWalletPayload(
                    payloadContext: .encoded(data),
                    wrapper: wrapper
                )
            }
            .publisher
            .mapError(WalletEncodingError.encodingError)
            .eraseToAnyPublisher()
    }
}

/// Creates `InnerWrapper` from the given encrypted payload
/// - Parameter context: An `EncodedWalletPayload` containing the wallet payload
/// - Returns: A `InnerWrapper`
func createInnerWrapperResponse(context: EncodedWalletPayload) -> Result<InnerWrapper, WalletEncodingError> {
    guard case .encrypted(let payload) = context.payloadContext else {
        return .failure(.expectedEncryptedPayload)
    }
    return .success(
        InnerWrapper(
            pbkdf2IterationCount: context.wrapper.pbkdf2Iterations,
            version: context.wrapper.version,
            payload: String(decoding: payload, as: UTF8.self)
        )
    )
}

private func encodeValue<T: Encodable>(of model: T) -> Result<Data, EncodingError> {
    Result {
        try JSONEncoder().encode(model)
    }
    .mapError { $0 as! EncodingError }
}
