// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

final class AccountPickerSimpleHeaderView: UIView, AccountPickerHeaderViewAPI {

    // MARK: Properties

    var model: AccountPickerSimpleHeaderModel! {
        didSet {
            subtitleLabel.content = model?.subtitleLabel ?? .empty
            uiSearchBar.isHidden = !model.searchable
        }
    }

    // MARK: - Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let heightSearchBarFocus: CGFloat = 64
    }

    // MARK: Properties - AccountPickerHeaderViewAPI

    var searchBar: UISearchBar? {
        uiSearchBar
    }

    // MARK: Private Properties

    private var heightConstraint: NSLayoutConstraint?
    private let disposeBag = DisposeBag()
    private let subtitleLabel = UILabel()
    private let separator = UIView()
    private let uiSearchBar = UISearchBar()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Private Methods

    private func setup() {
        addSubview(subtitleLabel)
        addSubview(uiSearchBar)
        addSubview(separator)

        // MARK: Subtitle Label

        subtitleLabel.layoutToSuperview(.top, offset: 16.0)
        subtitleLabel.layoutToSuperview(axis: .horizontal, offset: 24)

        // MARK: Separator

        separator.backgroundColor = .lightBorder
        separator.layout(dimension: .height, to: 1)
        separator.layoutToSuperview(.leading, .trailing, .bottom)

        // MARK: Search Bar

        uiSearchBar.autocapitalizationType = .none
        uiSearchBar.autocorrectionType = .no
        uiSearchBar.searchBarStyle = .minimal
        uiSearchBar.backgroundColor = .white
        uiSearchBar.isTranslucent = false
        uiSearchBar.layoutToSuperview(axis: .horizontal, offset: 14)
        uiSearchBar.layoutToSuperview(.bottom, offset: -4)

        // MARK: Setup

        clipsToBounds = true
        subtitleLabel.numberOfLines = 0

        uiSearchBar.rx.cancelButtonClicked
            .map { nil }
            .bind(to: uiSearchBar.rx.text)
            .disposed(by: disposeBag)

        Observable<Void>
            .merge(
                uiSearchBar.rx.cancelButtonClicked.asObservable(),
                uiSearchBar.rx.searchButtonClicked.asObservable()
            )
            .bind(onNext: { [weak self] _ in
                self?.searchBar?.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        uiSearchBar.rx.textDidBeginEditing
            .bind(onNext: { [weak self] _ in
                self?.enableSearch()
            })
            .disposed(by: disposeBag)

        uiSearchBar.rx.textDidEndEditing
            .bind(onNext: { [weak self] _ in
                self?.disableSearch()
            })
            .disposed(by: disposeBag)
    }

    // MARK: Search

    private func enableSearch() {
        if heightConstraint == nil {
            heightConstraint = layout(dimension: .height, to: Constants.heightSearchBarFocus)
        }
        UIView.animate(
            withDuration: Constants.animationDuration,
            animations: { [weak self] in
                self?.enableSearchAnimation()
            },
            completion: { [weak self] _ in
                self?.enableSearchCompletion()
            }
        )
    }

    private func disableSearch() {
        heightConstraint?.isActive = false
        heightConstraint = nil
        UIView.animate(
            withDuration: Constants.animationDuration,
            animations: { [weak self] in
                self?.disableSearchAnimation()
            }
        )
    }

    /// Calls layoutIfNeeded in superview, or in self if superview is nil.
    private func layoutForAnimations() {
        (superview ?? self)
            .layoutIfNeeded()
    }

    /// Enable search animation block
    private func enableSearchAnimation() {
        uiSearchBar.showsCancelButton = true
        subtitleLabel.alpha = 0
        layoutForAnimations()
    }

    /// Enable search completion block
    private func enableSearchCompletion() {
        subtitleLabel.isHidden = true
    }

    /// Disable search animation block
    private func disableSearchAnimation() {
        uiSearchBar.showsCancelButton = false
        subtitleLabel.isHidden = false
        subtitleLabel.alpha = 1
        layoutForAnimations()
    }
}
