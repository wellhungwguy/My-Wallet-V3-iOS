import PlatformKit
import RxCocoa
import RxSwift

public final class RadioAccountCellInteractor: Equatable {

    // MARK: - Public

    public let isSelected: Driver<Bool>
    public let account: SingleAccount

    // MARK: - Private

    private let radioSelectionHandler: RadioSelectionHandling

    public init(account: SingleAccount, radioSelectionHandler: RadioSelectionHandling) {
        self.account = account
        self.radioSelectionHandler = radioSelectionHandler

        self.isSelected = radioSelectionHandler
            .selectionState
            .map { state in
                guard let isSelected = state[account.identifier] else {
                    return false
                }
                return isSelected
            }
            .startWith(false)
            .asDriverCatchError()
    }

    public static func == (lhs: RadioAccountCellInteractor, rhs: RadioAccountCellInteractor) -> Bool {
        lhs.account.identifier == rhs.account.identifier
    }
}
