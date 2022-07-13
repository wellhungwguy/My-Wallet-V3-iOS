import Combine
import Errors

public protocol BINDWithdrawRepositoryProtocol {
    func currency(_ currency: String) -> Self
    func search(address: String) -> AnyPublisher<BINDBeneficiary, Nabu.Error>
    func link(beneficiary beneficiaryId: String) -> AnyPublisher<Void, Nabu.Error>
}
