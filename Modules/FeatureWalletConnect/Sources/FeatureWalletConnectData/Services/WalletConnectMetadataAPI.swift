// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureWalletConnectDomain
import Foundation
import MetadataKit

public enum WalletConnectMetadataError: Error {
    case unavailable
    case updateFailed
}
