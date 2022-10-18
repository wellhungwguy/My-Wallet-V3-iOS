// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

/// `LineItemView` shows a title and subtitle.
/// This is typically used as a subview in a `UITableViewCell`
/// for when the user needs to select
/// fee, etc.
public final class LineItemView: UIView {

    // MARK: - Injected

    public var viewModel: LineItemViewViewModel! {
        didSet {
            guard let viewModel else { return }
            titleLabel.content = viewModel.title
            subtitleLabel.content = viewModel.subtitle
        }
    }

    // MARK: - Private Properties

    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Setup

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    private func setup() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.fillSuperview()
        stackView.spacing = 4.0
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
    }
}

// MARK: - Rx

extension Reactive where Base: LineItemView {
    var rx_viewModel: Binder<LineItemViewViewModel> {
        Binder(base) { view, viewModel in
            view.viewModel = viewModel
        }
    }
}
