// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

public enum HotWalletProduct: String {
    case swap
    case exchange
    case trading = "simplebuy"
    case rewards
}

/// HotWalletAddressService responsible for fetching the hot wallet receive addresses
/// for different products and crypto currencies.
public protocol HotWalletAddressServiceAPI {
    /// Provides hot wallet receive addresses for different products and crypto currencies
    /// - Parameter cryptoCurrency: A Crypto Currency.
    /// - Parameter product: One of the hot-wallets supported products.
    /// - Returns: Non-failable Publisher that emits the receive address String for the requested
    /// product x crypto currency. If it is not available, emits nil.
    func hotWalletAddress(
        for cryptoCurrency: CryptoCurrency,
        product: HotWalletProduct
    ) -> AnyPublisher<String?, Never>
}

final class HotWalletAddressService: HotWalletAddressServiceAPI {

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let walletOptions: WalletOptionsAPI

    init(
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        walletOptions: WalletOptionsAPI = resolve()
    ) {
        self.featureFlagsService = featureFlagsService
        self.walletOptions = walletOptions
    }

    func hotWalletAddress(
        for cryptoCurrency: CryptoCurrency,
        product: HotWalletProduct
    ) -> AnyPublisher<String?, Never> {
        isEnabled(cryptoCurrency: cryptoCurrency)
            .flatMap { [walletOptions] isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return .just(nil)
                }
                return walletOptions.walletOptions
                    .asPublisher()
                    .map(\.hotWalletAddresses?[product.rawValue])
                    .map { addresses -> String? in
                        guard let code = code(for: cryptoCurrency) else {
                            return nil
                        }
                        return addresses?[code]
                    }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func isEnabled(cryptoCurrency: CryptoCurrency) -> AnyPublisher<Bool, Never> {
        guard code(for: cryptoCurrency) != nil else {
            // No App support.
            return .just(false)
        }
        return featureFlagsService.isEnabled(.hotWalletCustodial)
    }
}

private func code(for cryptoCurrency: CryptoCurrency) -> String? {
    switch cryptoCurrency {
    case .ethereum:
        return Constants.ethKey
    case let model where model.assetModel.kind.erc20ParentChain == Constants.ethParentChain:
        return Constants.ethKey
    default:
        return nil
    }
}

private enum Constants {
    static let ethParentChain = "ETH"
    static let ethKey = "eth"
}
