// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

/// Has two labels, one which is a `title` and the other a `description`.
public final class LineItemTableViewCell: UITableViewCell {

    private static let imageViewWidth: CGFloat = 22

    // MARK: - Exposed Properites

    public var presenter: LineItemCellPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter else { return }
            presenter.titleLabelContentPresenter.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.titleContent)
                .disposed(by: disposeBag)

            presenter.descriptionLabelContentPresenter.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.descriptionContent)
                .disposed(by: disposeBag)

            presenter.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)

            presenter.imageWidth
                .withLatestFrom(presenter.image) { ($0, $1) }
                .map { requestWidth, image -> CGFloat in
                    guard image != nil else {
                        return 0
                    }
                    return requestWidth
                }
                .drive(imageWidthConstraint.rx.constant)
                .disposed(by: disposeBag)

            presenter.image
                .drive(accessoryImageView.rx.image)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Private IBOutlets

    @IBOutlet private var accessoryImageView: UIImageView!
    @IBOutlet private var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    fileprivate var descriptionShimmeringView: ShimmeringView!

    override public func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        descriptionShimmeringView = ShimmeringView(
            in: contentView,
            anchorView: descriptionLabel,
            size: .init(width: 150, height: 24)
        )
        descriptionLabel.numberOfLines = 0
    }
}

// MARK: - Rx

extension Reactive where Base: LineItemTableViewCell {

    fileprivate var titleContent: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.titleLabel.content = value.labelContent
            }
        }
    }

    fileprivate var descriptionContent: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                UIView.animate(
                    withDuration: 0.5,
                    animations: { view.descriptionShimmeringView.start() }
                )
            case .loaded(next: let value):
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: .transitionCrossDissolve,
                    animations: {
                        view.descriptionLabel.content = value.labelContent
                        view.descriptionShimmeringView.stop()
                    }
                )
            }
        }
    }
}
