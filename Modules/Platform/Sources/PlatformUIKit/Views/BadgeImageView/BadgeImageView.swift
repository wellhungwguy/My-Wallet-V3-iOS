// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import SwiftUI
import UIKit

public final class BadgeImageView: UIView {

    // MARK: - Private IBOutlets

    private var imageView: UIImageView!
    private var containerView: UIView!

    private var leadingOffsetConstraint: NSLayoutConstraint!
    private var trailingOffsetConstraint: NSLayoutConstraint!

    private var topOffsetConstraint: NSLayoutConstraint!
    private var bottomOffsetConstraint: NSLayoutConstraint!

    private var sizeConstraints: LayoutForm.Constraints!

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - Public Properties

    public var viewModel: BadgeImageViewModel? {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else {
                imageView.set(nil)
                containerView.backgroundColor = nil
                return
            }

            // Bind corner radius
            viewModel.cornerRadius
                .drive(onNext: { [weak self] _ in
                    self?.setNeedsLayout()
                })
                .disposed(by: disposeBag)

            // Bind background color
            viewModel.backgroundColor
                .drive(containerView.rx.backgroundColor)
                .disposed(by: disposeBag)

            // Bind image
            viewModel.imageContent
                .drive(imageView.rx.content)
                .disposed(by: disposeBag)

            // Bind size if necessary
            viewModel.sizingType
                .drive(
                    onNext: { [weak self] type in
                        guard let self else { return }
                        switch type {
                        case .configuredByOwner:
                            self.sizeConstraints.set(priority: .penultimateLow)
                        case .constant(let size):
                            self.sizeConstraints.setConstant(
                                horizontal: size.width,
                                vertical: size.height
                            )
                            self.sizeConstraints.set(priority: .penultimateHigh)
                        }
                    }
                )
                .disposed(by: disposeBag)

            viewModel.marginOffset
                .drive(onNext: { [weak self] offset in
                    guard let self else { return }
                    self.leadingOffsetConstraint.constant = offset
                    self.trailingOffsetConstraint.constant = offset
                    self.topOffsetConstraint.constant = offset
                    self.bottomOffsetConstraint.constant = offset
                    self.layoutIfNeeded()
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        containerView = UIView()
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.layoutToSuperview(.leading, .trailing, .top, .bottom)
        topOffsetConstraint = imageView.layout(
            edge: .top,
            to: .top,
            of: containerView,
            offset: 4
        )
        bottomOffsetConstraint = containerView.layout(
            edge: .bottom,
            to: .bottom,
            of: imageView,
            offset: 4
        )
        leadingOffsetConstraint = imageView.layout(
            edge: .leading,
            to: .leading,
            of: containerView,
            offset: 4
        )
        trailingOffsetConstraint = containerView.layout(
            edge: .trailing,
            to: .trailing,
            of: imageView,
            offset: 4
        )
        imageView.clipsToBounds = true
        clipsToBounds = true
        sizeConstraints = layout(size: .edge(32), priority: .penultimateLow)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel else { return }
        switch viewModel.cornerRadiusRelay.value {
        case .none:
            layer.cornerRadius = 0
        case .roundedLow:
            layer.cornerRadius = 4
        case .roundedHigh:
            layer.cornerRadius = 8
        case .round:
            layer.cornerRadius = bounds.width * 0.5
        }
    }
}

// MARK: - Rx

extension Reactive where Base: BadgeImageView {
    public var viewModel: Binder<BadgeImageViewModel> {
        Binder(base) { view, viewModel in
            view.viewModel = viewModel
        }
    }
}

// MARK: - SwiftUI

public struct BadgeImageViewRepresentable: View, UIViewRepresentable {
    let viewModel: BadgeImageViewModel
    let size: CGFloat

    public init(viewModel: BadgeImageViewModel, size: CGFloat) {
        self.viewModel = viewModel
        self.size = size
    }

    public func makeUIView(context: Context) -> BadgeImageView {
        let view = BadgeImageView()
        view.viewModel = viewModel
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layout(size: .edge(size))
        return view
    }

    public func updateUIView(_ uiView: BadgeImageView, context: Context) {
        // Do nothing
    }
}
