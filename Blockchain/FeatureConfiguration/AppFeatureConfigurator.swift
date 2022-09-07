// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import RxSwift
import RxToolKit
import ToolKit

enum RemoteConfigConstants {
    static let notificationKey: String = "CONFIG_STATE"
    static let notificationValue: String = "STALE"
}

final class AppFeatureConfigurator {

    // MARK: Private Properties

    private let app: AppProtocol

    // MARK: Init

    init(app: AppProtocol) {
        self.app = app
    }
}

// MARK: - FeatureFetching

extension AppFeatureConfigurator: FeatureFetching {

    /// Returns an expected `Decodable` construct for the provided `AppFeature` key.
    ///
    /// - Parameter feature: the feature key
    /// - Returns: A `Combine.Publisher` that emits a single `Decodable` `AppFeature` object
    /// - Throws: A `FeatureFlagError.missingKeyRawValue` in case the key raw value is missing
    /// or a `FeatureFlagError.decodingError` error if decoding fails.
    func fetch<Feature: Decodable>(
        for key: AppFeature,
        as type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError> {
        app.remoteConfiguration
            .publisher(for: key.remoteEnabledKey)
            .receive(on: DispatchQueue.main)
            .prefix(1)
            .tryMap { data -> Feature in
                try data.decode(Feature.self)
            }
            .mapError(FeatureFlagError.decodingError)
            .timeout(
                .seconds(10),
                scheduler: DispatchQueue.main,
                customError: { FeatureFlagError.timeout }
            )
            .eraseToAnyPublisher()
    }
}
