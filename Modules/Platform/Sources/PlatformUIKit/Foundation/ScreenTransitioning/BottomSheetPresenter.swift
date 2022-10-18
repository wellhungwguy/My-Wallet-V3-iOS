// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxRelay
import RxSwift

public class BottomSheetPresenter: UIPresentationController {

    // MARK: Private Lazy Properties

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onDismissal(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }()

    private lazy var roundingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.01, green: 0.07, blue: 0.18, alpha: 1).withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    // MARK: Init

    public init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        ignoresBackgroundTouches: Bool = false
    ) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGesture.isEnabled = !ignoresBackgroundTouches
        dimmingView.addGestureRecognizer(tapGesture)
    }

    // MARK: Overrides

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        installPresentedViewInCustomViews()
    }

    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        roundingView.applyRadius(16.0, to: [.topLeft, .topRight])
    }

    override public var presentedView: UIView? {
        roundingView
    }

    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        installCustomViews()
        installPresentedViewInCustomViews()
        animateDimmingViewIn()
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard completed == false else { return }
        removeCustomViews()
    }

    override public func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        animateDimmingViewOut()
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        guard completed == false else { return }
        removeCustomViews()
    }

    // MARK: Private Functions

    @objc private func onDismissal(_ sender: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    private func installCustomViews() {
        guard let containerView else { return }

        containerView.addSubview(dimmingView)
        containerView.addSubview(roundingView)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: dimmingView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: dimmingView.trailingAnchor),

            roundingView.topAnchor.constraint(greaterThanOrEqualTo: containerView.readableContentGuide.topAnchor),
            roundingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: roundingView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: roundingView.trailingAnchor), {

                /// Fit to the content size of the `UIViewController` that you are presenting.
                let minimizingHeight = roundingView.heightAnchor.constraint(equalToConstant: containerView.frame.height)
                minimizingHeight.priority = .fittingSizeLevel
                return minimizingHeight
            }()
        ]
        )
    }

    private func installPresentedViewInCustomViews() {
        guard roundingView.subviews.contains(presentedViewController.view) == false else { return }

        presentedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        roundingView.addSubview(presentedViewController.view)

        NSLayoutConstraint.activate([
            presentedViewController.view.topAnchor.constraint(equalTo: roundingView.topAnchor),
            presentedViewController.view.leadingAnchor.constraint(equalTo: roundingView.leadingAnchor),
            roundingView.bottomAnchor.constraint(equalTo: presentedViewController.view.bottomAnchor),
            roundingView.trailingAnchor.constraint(equalTo: presentedViewController.view.trailingAnchor)
        ])
    }

    private func animateDimmingViewIn() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    private func animateDimmingViewOut() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    private func removeCustomViews() {
        roundingView.removeFromSuperview()
        dimmingView.removeFromSuperview()
    }
}

public class BottomSheetPresenting: NSObject, UIViewControllerTransitioningDelegate {

    private var ignoresBackgroundTouches = false

    @objc override public init() {
        super.init()
    }

    public init(ignoresBackgroundTouches: Bool) {
        self.ignoresBackgroundTouches = ignoresBackgroundTouches
        super.init()
    }

    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        BottomSheetPresenter(
            presentedViewController: presented,
            presenting: presenting,
            ignoresBackgroundTouches: ignoresBackgroundTouches
        )
    }
}
