// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class DoubleTextFieldTableViewCell: UITableViewCell {

    // MARK: - Types

    // MARK: - Properties

    public var bottomInset: CGFloat = 0 {
        didSet {
            bottomInsetConstraint.constant = -bottomInset
        }
    }

    public struct ViewModel {
        let leading: TextFieldViewModel
        let trailing: TextFieldViewModel

        public init(leading: TextFieldViewModel, trailing: TextFieldViewModel) {
            self.leading = leading
            self.trailing = trailing
        }
    }

    // MARK: - UI Properties

    private let stackView = UIStackView()
    private let leadingTextFieldView = TextFieldView()
    private let trailingTextFieldView = TextFieldView()

    private var bottomInsetConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(stackView)

        stackView.layoutToSuperview(axis: .horizontal, offset: 24)
        let verticalConstraints = stackView.layoutToSuperview(axis: .vertical)
        self.bottomInsetConstraint = verticalConstraints?.trailing

        stackView.addArrangedSubview(leadingTextFieldView)
        stackView.addArrangedSubview(trailingTextFieldView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 32

        leadingTextFieldView.layout(dimension: .height, to: 80, priority: .defaultLow)
        trailingTextFieldView.layout(dimension: .height, to: 80, priority: .defaultLow)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setup(
        viewModel: ViewModel,
        keyboardInteractionController: KeyboardInteractionController,
        scrollView: UIScrollView
    ) {
        leadingTextFieldView.setup(
            viewModel: viewModel.leading,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: scrollView
        )
        trailingTextFieldView.setup(
            viewModel: viewModel.trailing,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: scrollView
        )
    }
}
