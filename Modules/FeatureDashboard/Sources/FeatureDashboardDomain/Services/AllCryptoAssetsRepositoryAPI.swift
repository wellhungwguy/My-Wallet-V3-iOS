// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol AllCryptoAssetsRepositoryAPI {
    var assetsInfo: AnyPublisher<[AssetBalanceInfo], Error> { get }
}
