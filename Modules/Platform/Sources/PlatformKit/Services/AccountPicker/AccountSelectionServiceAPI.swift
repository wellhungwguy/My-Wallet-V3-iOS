// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

/// A interface for a service used to select a `BlockchainAccount`.
public protocol AccountSelectionServiceAPI: AnyObject {
    var selectedData: Observable<BlockchainAccount> { get }

    func record(selection: BlockchainAccount)
}

/// `AccountPickerSelectionService` is a `AccountSelectionServiceAPI` that contains
/// a pre-selected value and stream `selectedData` only if it is distinct from the previous value.
public final class AccountPickerSelectionService: AccountSelectionServiceAPI {
    private let selectedDataRelay: BehaviorRelay<BlockchainAccount>

    public var selectedData: Observable<BlockchainAccount> {
        selectedDataRelay
            .distinctUntilChanged(\.identifier)
    }

    public init(defaultSelection: BlockchainAccount) {
        self.selectedDataRelay = BehaviorRelay(value: defaultSelection)
    }

    public func record(selection: BlockchainAccount) {
        selectedDataRelay.accept(selection)
    }
}

/// `AccountSelectionService` is a `AccountSelectionServiceAPI` backed
/// by a `PublishRelay`, meaning it doesn't have a pre-defined value nor it 'replays' the last known value
/// on subscription.
public class AccountSelectionService: AccountSelectionServiceAPI {

    public var selectedData: Observable<BlockchainAccount> {
        selectedDataRelay.asObservable()
    }

    private let selectedDataRelay = PublishRelay<BlockchainAccount>()

    public func record(selection: BlockchainAccount) {
        selectedDataRelay.accept(selection)
    }

    public init() {}
}
