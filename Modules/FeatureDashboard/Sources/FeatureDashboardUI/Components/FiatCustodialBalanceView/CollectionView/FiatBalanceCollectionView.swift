// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import UIKit

final class FiatBalanceCollectionView: UICollectionView {

    // MARK: - Injected

    var presenter: FiatBalanceCollectionViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            presenter.presenters
                .drive(
                    rx.items(
                        cellIdentifier: FiatCustodialBalanceCollectionViewCell.objectName,
                        cellType: FiatCustodialBalanceCollectionViewCell.self
                    ),
                    curriedArgument: { _, presenter, cell in
                        cell.presenter = presenter
                    }
                )
                .disposed(by: disposeBag)

            rx.modelSelected(FiatCustodialBalanceViewPresenter.self)
                .subscribe(onNext: {
                    presenter.selected(currencyType: $0.currencyType)
                })
                .disposed(by: disposeBag)

            presenter.presenters
                .map(\.count)
                .asObservable()
                .subscribe(onNext: { [weak self] count in self?.isScrollEnabled = count > 1 })
                .disposed(by: disposeBag)
        }
    }

    let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        flow.scrollDirection = .horizontal
        return flow
    }()

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: collectionViewFlowLayout)
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        contentInset = .init(top: 0, left: 12, bottom: 0, right: 12)
        register(FiatCustodialBalanceCollectionViewCell.self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
