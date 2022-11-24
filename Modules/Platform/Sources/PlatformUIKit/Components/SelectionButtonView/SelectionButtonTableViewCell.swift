// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class SelectionButtonTableViewCell: UITableViewCell {

    // MARK: - Injected

    public var viewModel: SelectionButtonViewModel! {
        didSet {
            selectionButtonView.viewModel = viewModel
        }
    }

    public var bottomSpace: CGFloat = 0 {
        didSet {
            verticalConstraints.trailing.constant = -bottomSpace
        }
    }

    // MARK: - UI Properties

    private let selectionButtonView = SelectionButtonView()
    private var horizontalConstraints: Axis.Constraints!
    private var verticalConstraints: Axis.Constraints!

    // MARK: - Setup

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(selectionButtonView)
        selectionButtonView.layoutToSuperview(axis: .horizontal)
        self.verticalConstraints = selectionButtonView.layoutToSuperview(axis: .vertical, priority: .penultimateHigh)
        verticalConstraints.trailing.constant = -bottomSpace
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
