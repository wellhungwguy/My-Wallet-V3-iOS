// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import PlatformKit
import RxRelay
import RxSwift
import RxToolKit

public protocol WalletPickerSelectionServiceAPI: AnyObject {
    var selectedData: Observable<BlockchainAccount> { get }
    func refresh()
    func record(selection: BlockchainAccount)
}

final class WalletPickerSelectionService: WalletPickerSelectionServiceAPI {

    var selectedData: Observable<BlockchainAccount> {
        sharedStream
    }

    private var sharedStream: Observable<BlockchainAccount>!
    private let defaultValue: Observable<AccountGroup>
    private let selectedDataRelay: BehaviorRelay<BlockchainAccount?>
    private let coincore: CoincoreAPI

    init(coincore: CoincoreAPI, app: AppProtocol) {
        self.coincore = coincore
        defaultValue = app
            .modePublisher()
            .asObservable()
            .flatMapLatest { appMode in
                coincore.allAccounts(filter: appMode.filter).asObservable().share(replay: 1)
            }

        selectedDataRelay = BehaviorRelay(value: nil)
        sharedStream = selectedDataRelay
            .flatMapLatest(weak: self) { (self, account) -> Observable<BlockchainAccount> in
                guard let account else {
                    return self.defaultValue.map { $0 as BlockchainAccount }
                }
                return .just(account)
            }
            .share(replay: 1)
    }

    func record(selection: BlockchainAccount) {
        selectedDataRelay.accept(selection)
    }

    func refresh() {
        selectedDataRelay.accept(nil)
    }
}
