// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureWalletConnectData
import FeatureWalletConnectDomain
import Foundation
import PlatformKit
import ToolKit
import WalletPayloadKit

final class WalletConnectMetadata: NSObject, WalletConnectMetadataAPI {

    // MARK: Types

    typealias WalletAPI = LegacyWalletAPI & LegacyMnemonicAccessAPI

    // swiftlint:disable:next type_name
    private enum JS {
        enum Callback {
            static let updateSuccess = "objc_updateWalletConnect_success"
            static let updateFailure = "objc_updateWalletConnect_error"
        }

        enum Function {
            static let v1Sessions = "MyWalletPhone.walletConnect.v1Sessions()"

            static func updateV1Sessions(json: String) -> String {
                "MyWalletPhone.walletConnect.updateV1Sessions(\"\(json)\")"
            }
        }
    }

    // MARK: Private Properties

    private unowned let jsContextProvider: JSContextProviderAPI
    private let combineJSScheduler: DispatchQueue

    // MARK: Initializer

    init(
        jsContextProvider: JSContextProviderAPI,
        combineJSScheduler: DispatchQueue = DispatchQueue.main
    ) {
        self.jsContextProvider = jsContextProvider
        self.combineJSScheduler = combineJSScheduler
        super.init()
    }

    var v1Sessions: AnyPublisher<[WalletConnectSession], WalletConnectMetadataError> {
        v1SessionsJson
            .map { json in
                json
                    .flatMap { json in
                        try? JSONDecoder().decode(
                            [WalletConnectSession].self,
                            from: Data(json.utf8)
                        )
                    } ?? []
            }
            .eraseToAnyPublisher()
    }

    private var v1SessionsJson: AnyPublisher<String?, WalletConnectMetadataError> {
        Deferred { [jsContextProvider] in
            Future { [jsContextProvider] promise in
                guard WalletManager.shared.wallet.isInitialized() else {
                    promise(.failure(.unavailable))
                    return
                }
                guard let jsValue = jsContextProvider.jsContext
                    .evaluateScriptCheckIsOnMainQueue(JS.Function.v1Sessions)
                else {
                    promise(.success(nil))
                    return
                }
                guard !jsValue.isNull, !jsValue.isUndefined, jsValue.isString else {
                    promise(.success(nil))
                    return
                }
                guard let string = jsValue.toString() else {
                    promise(.success(nil))
                    return
                }
                guard !string.isEmpty else {
                    promise(.success(nil))
                    return
                }
                promise(.success(string))
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }

    func update(v1Sessions: [WalletConnectSession]) -> AnyPublisher<Void, WalletConnectMetadataError> {
        Deferred { [jsContextProvider] in
            Future { [jsContextProvider] promise in
                guard WalletManager.shared.wallet.isInitialized() else {
                    promise(.failure(.unavailable))
                    return
                }

                guard let data = try? JSONEncoder().encode(v1Sessions) else {
                    promise(.failure(.unavailable))
                    return
                }

                let script = JS.Function
                    .updateV1Sessions(
                        json: String(decoding: data, as: UTF8.self).escapedForJS()
                    )

                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.success(()))
                    },
                    forJsFunctionName: JS.Callback.updateSuccess as NSString
                )

                jsContextProvider.jsContext.invokeOnce(
                    functionBlock: {
                        promise(.failure(.updateFailed))
                    },
                    forJsFunctionName: JS.Callback.updateFailure as NSString
                )

                jsContextProvider.jsContext.evaluateScriptCheckIsOnMainQueue(script)
            }
        }
        .subscribe(on: combineJSScheduler)
        .eraseToAnyPublisher()
    }
}
