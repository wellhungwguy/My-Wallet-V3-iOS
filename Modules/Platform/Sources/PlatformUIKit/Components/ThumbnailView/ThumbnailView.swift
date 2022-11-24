// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class ThumbnailView: UIView {

    // MARK: - Injected

    public var viewModel: ThumbnailViewModel! {
        didSet {
            guard let viewModel else { return }
            imageView.set(viewModel.imageViewContent)
            backgroundColor = viewModel.backgroundColor
        }
    }

    // MARK: - UI Properties

    private let imageView: UIImageView!

    // MARK: - Setup

    public init(edge: CGFloat) {
        self.imageView = UIImageView()
        let size = CGSize(edge: edge)
        super.init(frame: .init(origin: .zero, size: size))
        clipsToBounds = true
        layer.cornerRadius = edge / 2
        imageView.addSubview(imageView)
        imageView.layoutToSuperview(.centerX, .centerY)
        imageView.layoutToSuperview(.width, .height, ratio: 0.86)
        layout(size: size)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
