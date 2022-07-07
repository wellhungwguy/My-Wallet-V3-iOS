import Combine
import Errors

public protocol BINDWithdrawRepositoryProtocol {
    func search(_ address: String) -> AnyPublisher<BIND, Nabu.Error>
    func link(_ address: String) -> AnyPublisher<Void, Nabu.Error>
}
