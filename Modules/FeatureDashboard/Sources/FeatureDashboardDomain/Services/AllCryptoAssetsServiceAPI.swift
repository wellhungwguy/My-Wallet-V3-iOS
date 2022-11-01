// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

enum CryptoAssetLoadError {
    case general
}

public protocol AllCryptoAssetsServiceAPI {
    func getAllCryptoAssetsInfo() async -> [CryptoAssetInfo]
    func getAllCryptoAssetsInfoPublisher() -> AnyPublisher<[CryptoAssetInfo], Never>
}
