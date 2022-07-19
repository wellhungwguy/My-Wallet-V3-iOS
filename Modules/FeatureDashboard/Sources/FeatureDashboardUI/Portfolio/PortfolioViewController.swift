// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureWithdrawalLocksUI
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import SwiftUI
import ToolKit
import UIComponentsKit

/// A view controller that displays the dashboard
final class PortfolioViewController<OnboardingChecklist: View>: BaseScreenViewController {

    // MARK: - Private Types

    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<PortfolioViewModel>

    // MARK: - Private Properties

    private let app: AppProtocol
    private let disposeBag = DisposeBag()
    private let presenter: PortfolioScreenPresenter
    private let tableView = UITableView()
    private let onboardingChecklistViewBuilder: () -> OnboardingChecklist

    private let floatingViewContainer = UIView()
    private var onboardingChecklistViewController: UIViewController? {
        willSet {
            onboardingChecklistViewController?.view.removeFromSuperview()
            onboardingChecklistViewController?.removeFromParent()
        }
        didSet {
            guard onboardingChecklistViewController != oldValue else {
                return
            }
            if let onboardingChecklistViewController = onboardingChecklistViewController {
                add(child: onboardingChecklistViewController)
                onboardingChecklistViewController.view.backgroundColor = .clear
                floatingViewContainer.addSubview(onboardingChecklistViewController.view)
                onboardingChecklistViewController.view.constraint(edgesTo: floatingViewContainer)
                showFloatingViewContent()
            } else {
                hideFloatingViewContent()
            }
        }
    }

    private var userHasCompletedOnboarding: AnyPublisher<Bool, Never>

    // MARK: - Setup

    init(
        app: AppProtocol = DIKit.resolve(),
        userHasCompletedOnboarding: AnyPublisher<Bool, Never>,
        @ViewBuilder onboardingChecklistViewBuilder: @escaping () -> OnboardingChecklist,
        presenter: PortfolioScreenPresenter
    ) {
        self.app = app
        self.userHasCompletedOnboarding = userHasCompletedOnboarding
        self.onboardingChecklistViewBuilder = onboardingChecklistViewBuilder
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        unimplemented()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
        setUpFloatingView()
        presenter.setup()
        tableView.reloadData()
        presenter.refreshRelay.accept(())

        NotificationCenter.when(.transaction) { [weak self] _ in
            self?.presenter.refreshRelay.accept(())
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        let model = presenter.screenNavigationModel
        set(
            barStyle: model.barStyle,
            leadingButtonStyle: model.leadingButton,
            trailingButtonStyle: model.trailingButton
        )
        titleViewStyle = model.titleViewStyle
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(axis: .horizontal, usesSafeAreaLayoutGuide: true)
        tableView.layoutToSuperview(axis: .vertical, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AnnouncementTableViewCell.self)
        tableView.register(FiatCustodialBalancesTableViewCell.self)
        tableView.registerNibCell(TotalBalanceTableViewCell.self, in: .module)
        tableView.registerNibCell(HistoricalBalanceTableViewCell.self, in: .module)
        tableView.register(HostingTableViewCell<WithdrawalLocksView>.self)
        tableView.separatorColor = .clear

        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: presenter.refreshRelay)
            .disposed(by: disposeBag)
        refreshControl.rx
            .controlEvent(.valueChanged)
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)

        let dataSource = RxDataSource(
            animationConfiguration: .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade),
            configureCell: { [weak self] _, _, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                let cell: UITableViewCell

                switch item {
                case .announcement(let model):
                    cell = self.announcementCell(for: indexPath, model: model)
                case .withdrawalLock:
                    cell = self.withdrawalLockCell(for: indexPath)
                case .fiatCustodialBalances(let presenter):
                    cell = self.fiatCustodialBalancesCell(indexPath: indexPath, presenter: presenter)
                case .totalBalance(let presenter):
                    cell = self.balanceCell(for: indexPath, presenter: presenter)
                case .crypto(let presenter):
                    cell = self.assetCell(for: indexPath, presenter: presenter)
                case .cryptoSkeleton:
                    cell = self.assetCell(for: indexPath, presenter: nil)
                case .emptyState:
                    cell = self.emptyStateCell(for: indexPath)
                }
                cell.selectionStyle = .none
                return cell
            }
        )

        tableView.rx.modelSelected(PortfolioCellType.self)
            .subscribe(onNext: { [app] model in
                switch model {
                case .announcement,
                     .totalBalance,
                     .withdrawalLock,
                     .cryptoSkeleton,
                     .fiatCustodialBalances,
                     .emptyState:
                    break
                case .crypto(let cryptoPresenter):
                    let currency = cryptoPresenter.cryptoCurrency
                    app.post(
                        event: blockchain.ux.asset[currency.code].select,
                        context: [blockchain.ux.asset.select.origin: "HOME"]
                    )
                }
            })
            .disposed(by: disposeBag)

        presenter.sections
            .observe(on: MainScheduler.asyncInstance)
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        userHasCompletedOnboarding
            .asObservable()
            .map { userHasCompletedOnboarding -> Bool in
                // if the user has completed onboarding, nothing to show
                !userHasCompletedOnboarding
            }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] shouldShowOnboardingChecklistOverview in
                if shouldShowOnboardingChecklistOverview {
                    if self?.onboardingChecklistViewController == nil {
                        self?.presentOnboardingChecklistView()
                    }
                } else {
                    // hide, don't remove, otherwise the close button on the modal won't work as only the checklist overview has a NavigationView
                    self?.hideFloatingViewContent()
                }
            }
            .disposed(by: disposeBag)
    }

    private func setUpFloatingView() {
        view.addSubview(floatingViewContainer)
        floatingViewContainer.layout(dimension: .height, to: BuyButtonView.height)
        floatingViewContainer.layoutToSuperview(.trailing, offset: -Spacing.padding3)
        floatingViewContainer.layoutToSuperview(.leading, offset: Spacing.padding3)
        floatingViewContainer.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true, offset: -Spacing.padding3)
    }

    private func showFloatingViewContent() {
        floatingViewContainer.isHidden = false
        // pad the table view in order to let the last cell scroll past the floating view with some padding
        tableView.contentInset.bottom = Spacing.padding3 + BuyButtonView.height + Spacing.padding1
    }

    private func hideFloatingViewContent() {
        floatingViewContainer.isHidden = true
        // reset the table view inset
        tableView.contentInset.bottom = 0
    }

    private func presentOnboardingChecklistView() {
        let viewController = UIHostingController(rootView: onboardingChecklistViewBuilder())
        onboardingChecklistViewController = viewController
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }

    // MARK: - Cells

    private func withdrawalLockCell(
        for indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeue(HostingTableViewCell<WithdrawalLocksView>.self, for: indexPath)
        let store = Store<WithdrawalLocksState, WithdrawalLocksAction>(
            initialState: .init(),
            reducer: withdrawalLocksReducer,
            environment: WithdrawalLocksEnvironment { [tableView] isVisible in
                if cell.updateRootView(height: isVisible ? 44 : 1) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        )
        cell.host(WithdrawalLocksView(store: store), parent: self, height: 1)
        return cell
    }

    func fiatCustodialBalancesCell(
        indexPath: IndexPath,
        presenter: FiatBalanceCollectionViewPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(FiatCustodialBalancesTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func announcementCell(for indexPath: IndexPath, model: AnnouncementCardViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        cell.viewModel = model
        return cell
    }

    private func balanceCell(for indexPath: IndexPath, presenter: TotalBalanceViewPresenter) -> UITableViewCell {
        let cell = tableView.dequeue(TotalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func assetCell(for indexPath: IndexPath, presenter: HistoricalBalanceCellPresenter?) -> UITableViewCell {
        let cell = tableView.dequeue(HistoricalBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func emptyStateCell(for indexPath: IndexPath) -> UITableViewCell {
        PortfolioEmptyStateTableViewCell()
    }
}

extension PortfolioViewController: SegmentedViewScreenViewController {
    func adjustInsetForBottomButton(withHeight height: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
    }
}
