// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol AllCryptoAssetsServiceAPI {
    func getAllCryptoAssetsInfo() async -> [AssetBalanceInfo]
    func getAllCryptoAssetsInfoPublisher() -> AnyPublisher<[AssetBalanceInfo], Never>
    func getFiatAssetsInfo() async -> AssetBalanceInfo?
}
