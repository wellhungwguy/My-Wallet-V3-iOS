// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public final class TransactionDescriptorView: UIView {

    // MARK: - Injected

    public var viewModel: TransactionDescriptorViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else {
                return
            }

            viewModel
                .fromAccountBadgeImageViewModel
                .drive(fromAccountBadgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            viewModel
                .toAccountBadgeImageViewModel
                .drive(toAccountBadgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            viewModel
                .transactionTypeBadgeImageViewModel
                .drive(transactionTypeBadgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            viewModel
                .toAccountBadgeIsHidden
                .drive(weak: self, onNext: { (self, value) in
                    self.toAccountBadgeImageView.isHidden = value
                })
                .disposed(by: disposeBag)
        }
    }

    fileprivate let fromAccountBadgeImageView = BadgeImageView()
    fileprivate let transactionTypeBadgeImageView = BadgeImageView()
    fileprivate let toAccountBadgeImageView = BadgeImageView()

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {

        backgroundColor = .clear
        clipsToBounds = true

        let stackView = UIStackView(arrangedSubviews: [
            fromAccountBadgeImageView,
            transactionTypeBadgeImageView,
            toAccountBadgeImageView
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.setCustomSpacing(-4, after: fromAccountBadgeImageView)
        stackView.setCustomSpacing(-4, after: transactionTypeBadgeImageView)

        addSubview(stackView)
        stackView.bringSubviewToFront(transactionTypeBadgeImageView)

        stackView.layoutToSuperview(.top, .leading, .trailing, .bottom)
        fromAccountBadgeImageView.layout(size: .edge(32))
        toAccountBadgeImageView.layout(size: .edge(32))
        transactionTypeBadgeImageView.layout(size: .edge(24))
    }
}

// MARK: - Rx

extension Reactive where Base: TransactionDescriptorView {
    public var viewModel: Binder<TransactionDescriptorViewModel> {
        Binder(base) { view, viewModel in
            view.viewModel = viewModel
        }
    }
}
