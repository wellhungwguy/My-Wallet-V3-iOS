// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import UIKit

public final class LinkedBankAccountTableViewCell: UITableViewCell {

    public var presenter: LinkedBankAccountCellPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else {
                titleLabel.content = .empty
                descriptionLabel.content = .empty
                badgeImageView.viewModel = nil
                multiBadgeView.model = nil
                return
            }

            presenter.multiBadgeViewModel
                .drive(multiBadgeView.rx.viewModel)
                .disposed(by: disposeBag)

            presenter.badgeImageViewModel
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            presenter.title
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter.description
                .drive(descriptionLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    private let badgeImageView = BadgeImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let multiBadgeView = MultiBadgeView()
    private let separatorView = UIView()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    func setup() {
        addSubview(badgeImageView)
        addSubview(multiBadgeView)
        addSubview(stackView)
        addSubview(separatorView)

        stackView.axis = .vertical
        stackView.spacing = 4.0

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        separatorView.layout(dimension: .height, to: 1)
        separatorView.layoutToSuperview(.leading, .trailing, .bottom)

        badgeImageView.layout(size: .edge(32))
        badgeImageView.layoutToSuperview(.leading, offset: 24)
        badgeImageView.layout(to: .centerY, of: stackView)

        stackView.layoutToSuperview(.top, offset: 16)
        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: 16)
        stackView.layout(edge: .bottom, to: .top, of: multiBadgeView, offset: -4)

        multiBadgeView.layoutToSuperview(.leading, .trailing)
        multiBadgeView.layout(edge: .bottom, to: .top, of: separatorView, offset: -16)

        separatorView.backgroundColor = .lightBorder
    }
}
