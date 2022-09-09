// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureWalletConnectDomain
import Foundation
import MetadataKit

public enum WalletConnectMetadataError: Error {
    case unavailable
    case updateFailed
}

public protocol WalletConnectMetadataAPI: AnyObject {
    var v1Sessions: AnyPublisher<[WalletConnectSession], WalletConnectMetadataError> { get }

    func update(v1Sessions: [WalletConnectSession]) -> AnyPublisher<Void, WalletConnectMetadataError>
}
