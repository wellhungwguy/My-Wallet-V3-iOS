// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol SupportedAssetsRemoteServiceAPI {
    func refreshCustodialAssetsCache() -> AnyPublisher<Void, Never>
    func refreshEthereumERC20AssetsCache() -> AnyPublisher<Void, Never>
    func refreshOtherERC20AssetsCache() -> AnyPublisher<Void, Never>
}
