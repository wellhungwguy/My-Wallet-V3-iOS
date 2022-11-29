// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import SwiftUI
import ToolKit

/// `SegmentedViewController` is a easy to used ViewController containing a `SegmentedView`
/// as `titleView` of it's `navigationItem`.
public final class SegmentedViewController: BaseScreenViewController {

    private lazy var segmentedView = SegmentedView()
    private let presenter: SegmentedViewScreenPresenting
    private let rootViewController: SegmentedTabViewController
    @Binding private var selectedSegmentBinding: Int
    private let disposeBag = DisposeBag()

    required init?(coder: NSCoder) { unimplemented() }
    public init(
        presenter: SegmentedViewScreenPresenting,
        selectedSegmentBinding: Binding<Int>
    ) {
        self.presenter = presenter
        _selectedSegmentBinding = selectedSegmentBinding
        self.rootViewController = SegmentedTabViewController(items: presenter.items)
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        segmentedView.viewModel = presenter.segmentedViewModel
        add(child: rootViewController)
        presenter.itemIndexSelected
            .bindAndCatch(to: rootViewController.itemIndexSelectedRelay)
            .disposed(by: disposeBag)

        presenter.itemIndexSelected
            .map(\.index)
            .distinctUntilChanged()
            .bind(to: segmentedView.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        presenter.itemIndexSelected
            .compactMap { $0 }
            .bindAndCatch(to: rootViewController.itemIndexSelectedRelay)
            .disposed(by: disposeBag)

        presenter.itemIndexSelected
            .subscribe(onNext: { [weak self] index, _ in
                self?.selectedSegmentBinding = index
            })
            .disposed(by: disposeBag)

        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        setupSegmentedView()
    }

    private func setupSegmentedView() {
        let rootView = rootViewController.view!
        switch presenter.segmentedViewLocation {
        case .navBar:
            segmentedView.layout(dimension: .width, to: 196)
            titleViewStyle = .view(value: segmentedView)
            rootView.layoutToSuperview(axis: .horizontal)
            rootView.layoutToSuperview(axis: .vertical)
        case .top(let titleViewStyle):
            self.titleViewStyle = titleViewStyle
            view.addSubview(segmentedView)
            rootView.layoutToSuperview(.leading, .bottom, .trailing)
            rootView.layoutToSuperview(.top, relation: .equal, usesSafeAreaLayoutGuide: false, offset: 64)
            segmentedView.layoutToSuperview(axis: .horizontal, offset: 24)
            segmentedView.layout(dimension: .height, to: 40)
            segmentedView.layoutToSuperview(.top, offset: 24)
        }
    }

    override public func navigationBarLeadingButtonPressed() {
        presenter.leadingButtonTapRelay.accept(())
    }

    override public func navigationBarTrailingButtonPressed() {
        presenter.trailingButtonTapRelay.accept(())
    }

    public func selectSegment(_ index: Int) {
        presenter.itemIndexSelectedRelay.accept((index: index, animated: false))
    }
}
