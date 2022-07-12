// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureFormDomain
import PlatformKit

public protocol KYCAccountUsageServiceAPI {

    func fetchAccountUsageForm() -> AnyPublisher<[FormQuestion], NabuNetworkError>
    func submitAccountUsageForm(_ form: [FormQuestion]) -> AnyPublisher<Void, NabuNetworkError>
}

final class KYCAccountUsageService: KYCAccountUsageServiceAPI {

    private let apiClient: KYCClientAPI

    init(apiClient: KYCClientAPI) {
        self.apiClient = apiClient
    }

    func fetchAccountUsageForm() -> AnyPublisher<[FormQuestion], NabuNetworkError> {
        apiClient.fetchAccountUsageForm()
            .catch { error -> AnyPublisher<[FormQuestion], Nabu.Error> in
                if error.code.rawValue == 204 {
                    return Just([])
                        .setFailureType(to: Nabu.Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(outputType: [FormQuestion].self, failure: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func submitAccountUsageForm(_ form: [FormQuestion]) -> AnyPublisher<Void, NabuNetworkError> {
        apiClient.submitAccountUsageForm(form)
    }
}
