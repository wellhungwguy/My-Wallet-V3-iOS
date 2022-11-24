// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class StellarActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] = []

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Accessors

    private var baseCells: [DetailsScreen.CellType] {
        [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(totalPresenter),
            .separator
        ]
    }

    private var sendCells: [DetailsScreen.CellType] {
        baseCells + [
            .lineItem(networkFeePresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(fromPresenter),
            .separator,
            .lineItem(memoPresenter)
        ]
    }

    private var receiveCells: [DetailsScreen.CellType] {
        baseCells + [
            .lineItem(toPresenter),
            .separator,
            .lineItem(fromPresenter)
        ]
    }

    // MARK: - Private Properties

    private let event: TransactionalActivityItemEvent
    private let router: ActivityRouterAPI
    private let interactor: StellarActivityDetailsInteractor
    private let alertViewPresenter: AlertViewPresenterAPI

    private let disposeBag = DisposeBag()

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<StellarActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: Private Properties (LineItemCellPresenting)

    private let orderIDPresenter: LineItemCellPresenting
    private let dateCreatedPresenter: LineItemCellPresenting
    private let totalPresenter: LineItemCellPresenting
    private let networkFeePresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let memoPresenter: LineItemCellPresenting

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    // MARK: - Init

    init(
        event: TransactionalActivityItemEvent,
        router: ActivityRouterAPI,
        interactor: StellarActivityDetailsInteractor = .init(),
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        precondition(
            event.currency == .stellar,
            "Using StellarActivityDetailsPresenter with \(event.currency) event."
        )
        self.event = event
        self.router = router
        self.interactor = interactor
        self.alertViewPresenter = alertViewPresenter

        self.cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )

        self.orderIDPresenter = TransactionalLineItem.orderId(event.transactionHash).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.dateCreatedPresenter = TransactionalLineItem.date().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.totalPresenter = TransactionalLineItem.total().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.networkFeePresenter = TransactionalLineItem.networkFee().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.memoPresenter = TransactionalLineItem.memo().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        self.explorerButton = .secondary(with: LocalizedString.Button.viewOnStellarChainIO)

        switch event.type {
        case .receive:
            self.buttons = []
        case .send:
            self.buttons = [explorerButton]
        }

        switch event.type {
        case .send:
            self.cells = sendCells
        case .receive:
            self.cells = receiveCells
        }

        bindAll(with: event)
    }

    // MARK: - Public Functions

    func viewDidLoad() {
        interactor
            .details(identifier: event.identifier, createdAt: event.creationDate)
            .subscribe(
                onNext: { [weak self] model in
                    self?.itemRelay.accept(model)
                },
                onError: { [weak self] _ in
                    self?.alertViewPresenter.error(in: nil, action: nil)
                }
            )
            .disposed(by: disposeBag)
    }

    func bindAll(with event: TransactionalActivityItemEvent) {
        let title: String
        switch event.type {
        case .send:
            title = LocalizedString.Title.send
        case .receive:
            title = LocalizedString.Title.receive
        }
        titleViewRelay.accept(.text(value: title))

        itemRelay
            .map { $0?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: cryptoAmountLabelPresenter.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.statusBadge }
            .distinctUntilChanged()
            .map(weak: self) { (self, _) in
                [self.statusBadge]
            }
            .bindAndCatch(to: badgesModel.badgesRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.statusBadge }
            .distinctUntilChanged()
            .map { .loaded(next: $0) }
            .bindAndCatch(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.dateCreated }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: dateCreatedPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.value }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: totalPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.fee }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: networkFeePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.to }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: toPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.from }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: fromPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.memo }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: memoPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .distinctUntilChanged()
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)

        explorerButton
            .tapRelay
            .bind { [weak self] _ in
                self?.router.showBlockchainExplorer(for: event)
            }
            .disposed(by: disposeBag)
    }
}
