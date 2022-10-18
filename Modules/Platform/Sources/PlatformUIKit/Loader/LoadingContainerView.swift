// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class LoadingContainerView: UIView {

    // MARK: - Properties

    private let max: CGRect = .init(origin: .zero, size: .init(width: 85.0, height: 85.0))

    private lazy var loadingBackgroundView: LoadingCircleView = {
        let circle = LoadingCircleView(
            diameter: self.frame.min(max).width,
            strokeColor: .init(white: 0.24, alpha: 1.0),
            strokeBackgroundColor: .clear,
            fillColor: .clear
        )
        return circle
    }()

    private lazy var loadingView: LoadingAnimatingView = {
        let loading = LoadingAnimatingView(
            diameter: self.frame.min(max).width,
            strokeColor: .white,
            strokeBackgroundColor: .clear,
            fillColor: .clear
        )
        return loading
    }()

    private var statusLabel: UILabel!

    // MARK: - Setup

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .greyFadeBackground
        isUserInteractionEnabled = true

        for view in [loadingBackgroundView, loadingView] {
            addSubview(view)
            view.layoutToSuperviewCenter()
            view.layout(size: CGSize(width: frame.min(max).width, height: frame.min(max).height))
        }

        alpha = Visibility.hidden.defaultAlpha
        let scale = CGAffineTransform(scaleX: 0, y: 0)
        loadingBackgroundView.transform = scale
        loadingView.transform = scale
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStatusLabelIfNeeded() {
        guard statusLabel == nil else {
            return
        }
        statusLabel = UILabel()
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.font = Font(.branded(.montserratRegular), size: .custom(15)).result
        statusLabel.accessibility = Accessibility(
            id: Accessibility.Identifier.LoadingView.statusLabel,
            traits: .updatesFrequently
        )
        addSubview(statusLabel)
        statusLabel.layoutToSuperview(axis: .horizontal, offset: 50)
        statusLabel.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 32).isActive = true
    }
}

// MARK: - LoadingViewProtocol

extension LoadingContainerView: LoadingViewProtocol {
    func animate(from oldState: LoadingViewPresenter.State, text: String?) {
        if text != nil {
            setupStatusLabelIfNeeded()
        }

        // Animate status label text transition if needed
        if let statusLabel {
            UIView.transition(
                with: statusLabel,
                duration: 0.25,
                options: [.beginFromCurrentState, .curveEaseOut, .transitionCrossDissolve],
                animations: {
                    self.statusLabel.text = text
                },
                completion: nil
            )
        }

        if !oldState.isAnimating {
            layoutIfNeeded()
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
            animator.addAnimations {
                self.alpha = Visibility.visible.defaultAlpha
            }
            animator.addAnimations({
                self.loadingBackgroundView.transform = .identity
                self.loadingView.transform = .identity
                self.loadingView.animate()
            }, delayFactor: 0.1)
            animator.startAnimation()
        }
    }

    func fadeOut() {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn)
        animator.addAnimations {
            let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.loadingBackgroundView.transform = scale
            self.loadingView.transform = scale
        }
        animator.addAnimations({
            self.alpha = Visibility.hidden.defaultAlpha
        }, delayFactor: 0.1)
        animator.addCompletion { _ in
            self.removeFromSuperview()
        }
        animator.startAnimation()
    }
}
