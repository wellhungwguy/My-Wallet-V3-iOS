// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

protocol SupportedAssetsRepositoryAPI {
    var ethereumERC20Assets: SupportedAssets { get }
    var otherERC20Assets: SupportedAssets { get }
    var custodialAssets: SupportedAssets { get }
}

final class SupportedAssetsRepository: SupportedAssetsRepositoryAPI {

    var ethereumERC20Assets: SupportedAssets {
        switch localService.ethereumERC20Assets {
        case .success(let response):
            return SupportedAssets(response: response, sanitizeEVMAssets: sanitizeEVMAssets)
        case .failure(let error):
            if BuildFlag.isInternal {
                fatalError("Can' load local ERC20 assets. \(error.localizedDescription)")
            }
            return SupportedAssets.empty
        }
    }

    var otherERC20Assets: SupportedAssets {
        switch localService.otherERC20Assets {
        case .success(let response):
            return SupportedAssets(response: response, sanitizeEVMAssets: sanitizeEVMAssets)
        case .failure(let error):
            if BuildFlag.isInternal {
                fatalError("Can' load local Other ERC20 assets. \(error.localizedDescription)")
            }
            return SupportedAssets.empty
        }
    }

    var custodialAssets: SupportedAssets {
        switch localService.custodialAssets {
        case .success(let response):
            return SupportedAssets(response: response, sanitizeEVMAssets: sanitizeEVMAssets)
        case .failure(let error):
            if BuildFlag.isInternal {
                fatalError("Can' load local custodial assets. \(error.localizedDescription)")
            }
            return SupportedAssets.empty
        }
    }

    private let localService: SupportedAssetsServiceAPI
    private let evmSupport: EVMSupportAPI
    private var sanitizeEVMAssets: Bool {
        evmSupport.sanitizeTokenNamesEnabled
    }

    init(
        localService: SupportedAssetsServiceAPI,
        evmSupport: EVMSupportAPI
    ) {
        self.localService = localService
        self.evmSupport = evmSupport
    }
}
