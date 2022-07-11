import Combine
import Errors
import Foundation
import ToolKit

@MainActor
public class BINDWithdrawService: ObservableObject {

    @Published public private(set) var result: Result<BIND, UX.Error>?
    @Published public private(set) var isLoading: Bool = false

    private let repository: BINDWithdrawRepositoryProtocol

    public init(
        initialResult result: Result<BIND, UX.Error>? = nil,
        repository: BINDWithdrawRepositoryProtocol
    ) {
        self.result = result
        self.repository = repository
    }

    public func search(_ text: String) {
        guard text.isNotEmpty else {
            return (result = nil)
        }
        isLoading = true
        repository.search(text)
            .mapError(UX.Error.init(nabu:))
            .result()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in self?.isLoading = false })
            .assign(to: &$result)
    }

    public func link(_ bind: BIND) async throws {
        isLoading = true
        try await repository.link(bind.label).values.first
        isLoading = false
    }
}
