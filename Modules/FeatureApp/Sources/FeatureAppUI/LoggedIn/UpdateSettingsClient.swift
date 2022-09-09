import Combine
import FeatureAuthenticationDomain
import PlatformKit

class UpdateSettingsClient: UpdateSettingsClientAPI {

    let dependency: UpdateCurrencySettingsClientAPI
    init(_ dependency: UpdateCurrencySettingsClientAPI) { self.dependency = dependency }

    func updatePublisher(
        currency: String,
        context: String,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, Error> {
        dependency.updatePublisher(
            currency: currency,
            context: .init(rawValue: context) ?? .settings,
            guid: guid,
            sharedKey: sharedKey
        )
        .eraseError()
    }
}
