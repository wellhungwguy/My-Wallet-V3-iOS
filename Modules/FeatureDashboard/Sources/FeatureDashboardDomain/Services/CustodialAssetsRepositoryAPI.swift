// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol CustodialAssetsRepositoryAPI {
    var assetsInfo: AnyPublisher<[AssetBalanceInfo], Error> { get }
}
