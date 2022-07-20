// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol AccountPickerRouting: ViewableRouting {
    // Declare methods the interactor can invoke to manage sub-tree via the router.
}

public final class AccountPickerInteractor: PresentableInteractor<AccountPickerPresentable>, AccountPickerInteractable {

    // MARK: - Properties

    weak var router: AccountPickerRouting?

    // MARK: - Private Properties

    private let searchRelay: PublishRelay<String?> = .init()
    private let accountProvider: AccountPickerAccountProviding
    private let didSelect: AccountPickerDidSelect?
    private let disposeBag = DisposeBag()
    private weak var listener: AccountPickerListener?

    private let app: AppProtocol
    private let priceRepository: PriceRepositoryAPI

    // MARK: - Init

    init(
        presenter: AccountPickerPresentable,
        accountProvider: AccountPickerAccountProviding,
        listener: AccountPickerListenerBridge,
        app: AppProtocol = resolve(),
        priceRepository: PriceRepositoryAPI = resolve(tag: DIKitPriceContext.volume)
    ) {
        self.app = app
        self.priceRepository = priceRepository
        self.accountProvider = accountProvider
        switch listener {
        case .simple(let didSelect):
            self.didSelect = didSelect
            self.listener = nil
        case .listener(let listener):
            didSelect = nil
            self.listener = listener
        }
        super.init(presenter: presenter)
    }

    // MARK: - Methods

    override public func didBecomeActive() {
        super.didBecomeActive()

        let button = presenter.button
        if let button = button {
            button.tapRelay
                .bind { [weak self] in
                    guard let self = self else { return }
                    self.handle(effects: .button)
                }
                .disposeOnDeactivate(interactor: self)
        }

        let searchObservable = searchRelay.asObservable()
            .startWith(nil)
            .distinctUntilChanged()
            .debounce(.milliseconds(350), scheduler: MainScheduler.asyncInstance)

        let interactorState: Driver<State> = Observable
            .combineLatest(
                accountProvider.accounts.flatMap { [app, priceRepository] accounts in
                    accounts.snapshot(app: app, priceRepository: priceRepository).asObservable()
                },
                searchObservable
            )
            .map { [button] accounts, searchString -> State in
                let isFiltering = searchString
                    .flatMap { !$0.isEmpty } ?? false

                var interactors = accounts
                    .filter { snapshot in
                        snapshot.account.currencyType.matchSearch(searchString)
                    }
                    .sorted(by: >)
                    .map(\.account)
                    .map(\.accountPickerCellItemInteractor)

                if interactors.isEmpty {
                    interactors.append(.emptyState)
                }
                if let button = button {
                    interactors.append(.button(button))
                }

                return State(
                    isFiltering: isFiltering,
                    interactors: interactors
                )
            }
            .asDriver(onErrorJustReturn: .empty)

        presenter
            .connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
            didSelect?(account)
            listener?.didSelect(blockchainAccount: account)
        case .back:
            listener?.didTapBack()
        case .closed:
            listener?.didTapClose()
        case .filter(let string):
            searchRelay.accept(string)
        case .button:
            listener?.didSelectActionButton()
        case .none:
            break
        }
    }
}

extension AccountPickerInteractor {
    public struct State {
        static let empty = State(isFiltering: false, interactors: [])
        let isFiltering: Bool
        let interactors: [AccountPickerCellItem.Interactor]
    }

    public enum Effects {
        case select(BlockchainAccount)
        case back
        case closed
        case filter(String?)
        case button
        case none
    }
}

extension BlockchainAccount {

    fileprivate var accountPickerCellItemInteractor: AccountPickerCellItem.Interactor {
        switch self {
        case is PaymentMethodAccount:
            return .paymentMethodAccount(self as! PaymentMethodAccount)

        case is LinkedBankAccount:
            let account = self as! LinkedBankAccount
            return .linkedBankAccount(account)

        case is SingleAccount:
            let singleAccount = self as! SingleAccount
            return .singleAccount(singleAccount, AccountAssetBalanceViewInteractor(account: singleAccount))

        case is AccountGroup:
            let accountGroup = self as! AccountGroup
            return .accountGroup(
                accountGroup,
                AccountGroupBalanceCellInteractor(
                    balanceViewInteractor: WalletBalanceViewInteractor(account: accountGroup)
                )
            )

        default:
            impossible()
        }
    }
}

struct BlockchainAccountSnapshot: Comparable {

    let account: BlockchainAccount
    let balance: FiatValue
    let count: Int
    let volume24h: Double

    static func == (lhs: BlockchainAccountSnapshot, rhs: BlockchainAccountSnapshot) -> Bool {
        lhs.account.identifier == rhs.account.identifier
            && lhs.balance == rhs.balance
            && lhs.count == rhs.count
            && lhs.volume24h == rhs.volume24h
    }

    static func < (lhs: BlockchainAccountSnapshot, rhs: BlockchainAccountSnapshot) -> Bool {
        (
            lhs.count,
            lhs.balance.amount,
            lhs.volume24h
        ) < (
            rhs.count,
            rhs.balance.amount,
            rhs.volume24h
        )
    }
}

extension BlockchainAccount {

    var empty: (snapshot: BlockchainAccountSnapshot, Void) {
        (
            snapshot: BlockchainAccountSnapshot(
                account: self,
                balance: .zero(currency: .USD),
                count: 0,
                volume24h: 0
            ), ()
        )
    }
}

private enum BlockchainAccountSnapshotError: Error {
    case isNotEnabled
    case noTradingCurrency
}

extension Collection where Element == BlockchainAccount {

    func snapshot(
        app: AppProtocol,
        priceRepository: PriceRepositoryAPI
    ) -> AnyPublisher<[BlockchainAccountSnapshot], Never> {
        Task<[BlockchainAccountSnapshot], Error>.ThrowingPublisher {
            guard try await app.get(blockchain.ux.transaction.smart.sort.order.is.enabled) else {
                throw BlockchainAccountSnapshotError.isNotEnabled
            }
            guard let currency: FiatCurrency = try await app.get(
                blockchain.user.currency.preferred.fiat.display.currency
            ) else {
                throw BlockchainAccountSnapshotError.noTradingCurrency
            }
            let prices = try await priceRepository.prices(
                of: map(\.currencyType),
                in: FiatCurrency.USD,
                at: .oneDay
            )
            .stream()
            .first
            var accounts = [BlockchainAccountSnapshot]()
            for account in self {
                let count: Int? = try? await app.get(
                    blockchain.ux.transaction.source.target[account.currencyType.code].count.of.completed
                )
                let balance = try? await account.fiatBalance(fiatCurrency: currency)
                    .stream()
                    .first
                accounts.append(
                    BlockchainAccountSnapshot(
                        account: account,
                        balance: balance?.fiatValue ?? .zero(currency: currency),
                        count: count ?? 0,
                        volume24h: prices?["\(account.currencyType.code)-USD"]?.volume24h ?? 0
                    )
                )
            }
            return accounts
        }
        .replaceError(with: map(\.empty.snapshot))
        .eraseToAnyPublisher()
    }
}
