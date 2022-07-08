import Combine
import Errors
import MoneyKit
import PlatformKit
import ToolKit

final class MockNabuUserService: NabuUserServiceAPI {

    struct StubbedResults {
        var user: AnyPublisher<NabuUser, NabuUserServiceError> = .empty()
        var fetchUser: AnyPublisher<NabuUser, NabuUserServiceError> = .empty()
        var setInitialResidentialInfo: AnyPublisher<Void, NabuUserServiceError> = .empty()
        var setTradingCurrency: AnyPublisher<Void, Nabu.Error> = .empty()
    }

    var stubbedResults = StubbedResults()

    var user: AnyPublisher<NabuUser, NabuUserServiceError> {
        stubbedResults.user
    }

    func fetchUser() -> AnyPublisher<NabuUser, NabuUserServiceError> {
        stubbedResults.fetchUser
    }

    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NabuUserServiceError> {
        stubbedResults.setInitialResidentialInfo
    }

    func setTradingCurrency(
        _ currency: FiatCurrency
    ) -> AnyPublisher<Void, Nabu.Error> {
        stubbedResults.setTradingCurrency
    }
}
