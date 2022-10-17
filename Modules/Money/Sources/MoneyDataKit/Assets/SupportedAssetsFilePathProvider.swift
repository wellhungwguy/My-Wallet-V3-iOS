// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

protocol SupportedAssetsFilePathProviderAPI {
    var localCustodialAssets: URL? { get }
    var remoteCustodialAssets: URL? { get }
    var localEthereumERC20Assets: URL? { get }
    var remoteEthereumERC20Assets: URL? { get }
    var localOtherERC20Assets: URL? { get }
    var remoteOtherERC20Assets: URL? { get }
}

final class SupportedAssetsFilePathProvider: SupportedAssetsFilePathProviderAPI {

    private enum FileName {
        enum Local {
            static var custodial: String { "local-currencies-custodial.json" }
            static var ethereumERC20: String { "local-currencies-ethereum-erc20.json" }
            static var otherERC20: String { "local-currencies-other-erc20.json" }
        }

        enum Remote {
            static var custodial: String { "remote-currencies-custodial.json" }
            static var ethereumERC20: String { "remote-currencies-erc20.json" }
            static var otherERC20: String { "remote-currencies-other-erc20.json" }
        }
    }

    private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    var localEthereumERC20Assets: URL? {
        Bundle.module.url(forResource: FileName.Local.ethereumERC20, withExtension: nil)
    }

    var localOtherERC20Assets: URL? {
        Bundle.module.url(forResource: FileName.Local.otherERC20, withExtension: nil)
    }

    var localCustodialAssets: URL? {
        Bundle.module.url(forResource: FileName.Local.custodial, withExtension: nil)
    }

    var remoteEthereumERC20Assets: URL? {
        guard let documentsDirectory = documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(FileName.Remote.ethereumERC20)
    }

    var remoteOtherERC20Assets: URL? {
        guard let documentsDirectory = documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(FileName.Remote.otherERC20)
    }

    var remoteCustodialAssets: URL? {
        guard let documentsDirectory = documentsDirectory else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(FileName.Remote.custodial)
    }

    private var documentsDirectory: URL? {
        try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
}
