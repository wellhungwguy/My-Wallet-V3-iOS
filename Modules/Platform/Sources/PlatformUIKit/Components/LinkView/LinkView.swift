// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

/// A view model for `LinkView` that can display a link embedded in text,
/// levaraging `InteractableTextView` to do so.
public final class LinkView: UIView {

    // MARK: - Properties

    public var viewModel: LinkViewModel! {
        didSet {
            disposeBag = DisposeBag()
            guard let viewModel else {
                return
            }
            textView.viewModel = viewModel.textViewModel
            viewModel.textDidChange
                .observe(on: MainScheduler.instance)
                .bindAndCatch(weak: textView) { _ in
                    self.textDidChange()
                }
                .disposed(by: disposeBag)
        }
    }

    private let textView = InteractableTextView()

    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(textView)
        textView.fillSuperview()
    }

    private func textDidChange() {
        textView.setupHeight()
    }
}
