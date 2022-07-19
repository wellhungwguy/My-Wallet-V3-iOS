// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureFormDomain
import PlatformKit

public protocol KYCAccountUsageServiceAPI {

    func fetchExtraKYCQuestions(context: String) -> AnyPublisher<Form, Nabu.Error>
    func submitExtraKYCQuestions(_ form: Form) -> AnyPublisher<Void, Nabu.Error>
}

final class KYCAccountUsageService: KYCAccountUsageServiceAPI {

    private let apiClient: KYCClientAPI

    init(apiClient: KYCClientAPI) {
        self.apiClient = apiClient
    }

    func fetchExtraKYCQuestions(context: String) -> AnyPublisher<Form, Nabu.Error> {
        apiClient.fetchExtraKYCQuestions(context: context)
            .catch { error -> AnyPublisher<Form, Nabu.Error> in
                if error.code.rawValue == 204 {
                    return Just(Form(header: nil, context: context, nodes: [], blocking: false))
                        .setFailureType(to: Nabu.Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(outputType: Form.self, failure: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func submitExtraKYCQuestions(_ form: Form) -> AnyPublisher<Void, Nabu.Error> {
        apiClient.submitExtraKYCQuestions(form)
    }
}
