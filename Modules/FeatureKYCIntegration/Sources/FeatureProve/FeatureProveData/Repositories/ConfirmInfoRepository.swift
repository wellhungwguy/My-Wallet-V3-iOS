// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation

public struct ConfirmInfoRepository: ConfirmInfoRepositoryAPI {
    private let client: ConfirmInfoClientAPI

    public init(client: ConfirmInfoClientAPI) {
        self.client = client
    }

    public func confirmInfo(
        confirmInfo: ConfirmInfo
    ) -> AnyPublisher<ConfirmInfo, NabuError> {
        client
            .confirmInfo(
                firstName: confirmInfo.firstName,
                lastName: confirmInfo.lastName,
                address: confirmInfo.address,
                dateOfBirth: confirmInfo.dateOfBirth,
                phone: confirmInfo.phone
            )
            .map { response in
                ConfirmInfo(
                    firstName: response.firstName,
                    lastName: response.lastName,
                    address: response.address,
                    dateOfBirth: response.dateOfBirth ?? confirmInfo.dateOfBirth,
                    phone: response.phone
                )
            }
            .eraseToAnyPublisher()
    }
}
