// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import Foundation
import ToolKit

protocol AppUpgradeStateServiceAPI {
    var state: AnyPublisher<AppUpgradeState?, Never> { get }
}

final class AppUpgradeStateService: AppUpgradeStateServiceAPI {

    private let deviceInfo: DeviceInfo
    private let app: AppProtocol

    init(
        app: AppProtocol,
        deviceInfo: DeviceInfo
    ) {
        self.app = app
        self.deviceInfo = deviceInfo
    }

    var state: AnyPublisher<AppUpgradeState?, Never> {
        app
            .publisher(
                for: blockchain.app.configuration.app.maintenance,
                as: AppUpgradeData.self
            )
            .prefix(1)
            .map(\.value)
            .map { [deviceInfo] data in
                data
                    .flatMap { data in
                        AppUpgradeState(
                            data: data,
                            appVersion: Bundle.applicationVersion ?? "0",
                            currentOSVersion: deviceInfo.systemVersion
                        )
                    }
            }
            .eraseToAnyPublisher()
    }
}
