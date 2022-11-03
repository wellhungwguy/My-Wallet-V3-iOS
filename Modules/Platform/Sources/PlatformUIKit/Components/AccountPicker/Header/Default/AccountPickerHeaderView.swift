// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIComponentsKit
import UIKit

final class AccountPickerHeaderView: UIView, AccountPickerHeaderViewAPI {

    // MARK: - Types

    private enum Constants {
        static let animationDuration: TimeInterval = 0.25
        static let heightSearchBarFocus: CGFloat = 64
    }

    // MARK: - Properties

    var model: AccountPickerHeaderModel! {
        didSet {
            guard let model else {
                assetImageView.image = nil
                titleLabel.content = .empty
                subtitleLabel.content = .empty
                return
            }
            assetImageView.set(model.imageContent)
            titleLabel.content = model.titleLabel
            subtitleLabel.content = model.subtitleLabel
            separator.isHidden = model.tableTitleLabel == nil || model.searchable
            uiSearchBar.isHidden = !model.searchable
        }
    }

    // MARK: AccountPickerHeaderViewAPI

    var searchBar: UISearchBar? {
        uiSearchBar
    }

    // MARK: - Private Properties

    private var heightConstraint: NSLayoutConstraint?
    private let disposeBag = DisposeBag()
    private let patternImageView = UIImageView()
    private let assetImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let separator = UIView()
    private let fadeMask = CAGradientLayer()
    private let uiSearchBar = UISearchBar()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        fadeMask.frame = patternImageView.bounds
    }

    // MARK: - Private Methods

    // MARK: Setup

    private func setup() {
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        addSubview(uiSearchBar)
        addSubview(patternImageView)
        addSubview(assetImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(separator)

        // MARK: Background Image View

        patternImageView.layoutToSuperview(.leading, .trailing, .top, .bottom)
        patternImageView.set(ImageViewContent(imageResource: ImageAsset.linkPattern.imageResource))
        patternImageView.contentMode = .scaleAspectFill

        // MARK: Asset Image View

        assetImageView.layout(size: .edge(32))
        assetImageView.layoutToSuperview(.top, .leading, offset: 24)
        assetImageView.contentMode = .scaleAspectFit

        // MARK: Title Label

        titleLabel.layoutToSuperview(.top, offset: 74)
        titleLabel.layoutToSuperview(axis: .horizontal, offset: 24)

        // MARK: Subtitle Label

        subtitleLabel.layout(edge: .top, to: .bottom, of: titleLabel, offset: 8)
        subtitleLabel.layoutToSuperview(axis: .horizontal, offset: 24)
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0

        // MARK: Separator

        separator.backgroundColor = .lightBorder
        separator.layout(edge: .top, to: .bottom, of: subtitleLabel, offset: 8)
        separator.layout(dimension: .height, to: 1)
        separator.layoutToSuperview(axis: .horizontal)
        separator.layoutToSuperview(.bottom)

        // MARK: Search Bar

        uiSearchBar.autocapitalizationType = .none
        uiSearchBar.autocorrectionType = .no
        uiSearchBar.searchBarStyle = .minimal
        uiSearchBar.backgroundColor = .white
        uiSearchBar.isTranslucent = false
        uiSearchBar.layoutToSuperview(axis: .horizontal, offset: 14)
        uiSearchBar.layoutToSuperview(.bottom, offset: -4)

        // MARK: Fading Mask

        fadeMask.colors = [
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        fadeMask.locations = [0, 0.6, 0.9, 1]
        fadeMask.frame = bounds
        patternImageView.layer.mask = fadeMask

        // MARK: Setup

        backgroundColor = .white
        clipsToBounds = true
        model = nil

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
        patternImageView.alpha = 0
        assetImageView.alpha = 0
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        layoutForAnimations()
    }

    /// Enable search completion block
    private func enableSearchCompletion() {
        assetImageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
    }

    /// Disable search animation block
    private func disableSearchAnimation() {
        uiSearchBar.showsCancelButton = false
        assetImageView.isHidden = false
        titleLabel.isHidden = false
        subtitleLabel.isHidden = false
        patternImageView.alpha = 1
        assetImageView.alpha = 1
        titleLabel.alpha = 1
        subtitleLabel.alpha = 1
        layoutForAnimations()
    }
}
