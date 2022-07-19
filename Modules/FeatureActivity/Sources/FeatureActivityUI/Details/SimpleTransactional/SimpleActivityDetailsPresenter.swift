// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class SimpleActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel] = []

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

    private let event: SimpleTransactionalActivityItemEvent
    private let interactor: SimpleActivityDetailsInteractor
    private let alertViewPresenter: AlertViewPresenterAPI

    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<SimpleActivityDetailsViewModel?> = .init(value: nil)

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

    // MARK: - Init

    init(
        event: SimpleTransactionalActivityItemEvent,
        interactor: SimpleActivityDetailsInteractor,
        alertViewPresenter: AlertViewPresenterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.event = event
        self.interactor = interactor
        self.alertViewPresenter = alertViewPresenter

        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )

        orderIDPresenter = TransactionalLineItem.orderId(event.transactionHash).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        dateCreatedPresenter = TransactionalLineItem.date().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        totalPresenter = TransactionalLineItem.total().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        networkFeePresenter = TransactionalLineItem.networkFee().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        memoPresenter = TransactionalLineItem.memo().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        switch event.type {
        case .send:
            cells = sendCells
        case .receive:
            cells = receiveCells
        }

        bindAll(with: event)
    }

    // MARK: - Public Functions

    func viewDidLoad() {
        interactor
            .details(event: event)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] value in
                    self?.itemRelay.accept(value)
                }
            )
            .store(in: &cancellables)
    }

    func bindAll(with event: SimpleTransactionalActivityItemEvent) {
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
    }
}
