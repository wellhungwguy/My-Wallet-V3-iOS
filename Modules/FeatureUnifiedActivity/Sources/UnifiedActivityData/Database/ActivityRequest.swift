// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import GRDB
import GRDBQuery

struct ActivityEntityRequest: Queryable {

    // MARK: - Queryable Implementation

    static var defaultValue: [ActivityEntity] { [] }

    func publisher(in appDatabase: AppDatabaseAPI) -> AnyPublisher<[ActivityEntity], Error> {
        // Build the publisher from the general-purpose read-only access granted by `appDatabase.databaseReader`.
        // Some apps will prefer to call a dedicated method of `appDatabase`.
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(
                in: appDatabase.databaseReader,
                // The `.immediate` scheduling feeds the view right on
                // subscription, and avoids an undesired animation when the
                // application starts.
                scheduling: .immediate
            )
            .eraseToAnyPublisher()
    }

    // This method is not required by Queryable, but it makes it easier
    // to test PlayerRequest.
    func fetchValue(_ db: Database) throws -> [ActivityEntity] {
        try ActivityEntity.all().fetchAll(db)
    }
}
