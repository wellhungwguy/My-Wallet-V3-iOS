// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import NetworkKit
import ToolKit
import UnifiedActivityDomain

final class UnifiedActivityRepository: UnifiedActivityRepositoryAPI {

    var activity: AnyPublisher<[ActivityEntry], Never> {
        activityEntityRequest
            .publisher(in: appDatabase)
            .map { items -> [ActivityEntry] in
                items.compactMap { item -> ActivityEntry? in
                    guard let data = item.json.data(using: .utf8) else {
                        return nil
                    }
                    let decoder = JSONDecoder()
                    return try? decoder.decode(ActivityEntry.self, from: data)
                }
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private let appDatabase: AppDatabaseAPI
    private let activityEntityRequest: ActivityEntityRequest

    init(appDatabase: AppDatabaseAPI, activityEntityRequest: ActivityEntityRequest) {
        self.appDatabase = appDatabase
        self.activityEntityRequest = activityEntityRequest
    }
}
