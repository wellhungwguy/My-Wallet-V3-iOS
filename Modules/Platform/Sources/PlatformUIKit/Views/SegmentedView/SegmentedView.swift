// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift
import UIKit

/// The standard wallet `UISegmentedControl`.
/// - see also: [SegmentedViewModel](x-source-tag://SegmentedViewModel).
public final class SegmentedView: UISegmentedControl {

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - Dependencies

    public var viewModel: SegmentedViewModel? {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel else { return }

            layer.cornerRadius = viewModel.cornerRadius

            // Set accessibility
            accessibility = viewModel.accessibility

            // Bind backgroundColor
            viewModel.backgroundColor
                .drive(rx.backgroundColor)
                .disposed(by: disposeBag)

            // Set the divider color
            viewModel.dividerColor
                .drive(rx.dividerColor)
                .disposed(by: disposeBag)

            // Set the text attributes
            Driver
                .zip(viewModel.contentColor, viewModel.normalFont)
                .map { tuple -> [NSAttributedString.Key: Any]? in
                    var attributes: [NSAttributedString.Key: Any] = [:]
                    attributes[.font] = tuple.1
                    if let color = tuple.0 {
                        attributes[.foregroundColor] = color
                    }
                    return attributes
                }
                .drive(rx.normalTextAttributes)
                .disposed(by: disposeBag)

            Driver
                .zip(viewModel.selectedFontColor, viewModel.selectedFont)
                .map { tuple -> [NSAttributedString.Key: Any]? in
                    var attributes: [NSAttributedString.Key: Any] = [:]
                    attributes[.font] = tuple.1
                    if let color = tuple.0 {
                        attributes[.foregroundColor] = color
                    }
                    return attributes
                }
                .drive(rx.selectedTextAttributes)
                .disposed(by: disposeBag)

            // Bind border color
            viewModel.borderColor
                .drive(layer.rx.borderColor)
                .disposed(by: disposeBag)

            // Bind view model enabled indication to button
            viewModel.isEnabled
                .drive(rx.isEnabled)
                .disposed(by: disposeBag)

            // Bind opacity
            viewModel.alpha
                .drive(rx.alpha)
                .disposed(by: disposeBag)

            rx.value
                .bindAndCatch(to: viewModel.tapRelay)
                .disposed(by: disposeBag)

            isMomentary = viewModel.isMomentary

            removeAllSegments()
            viewModel.items.enumerated().forEach {
                switch $1.content {
                case .imageName(let imageName):
                    insertSegment(with: UIImage(named: imageName), at: $0, animated: false)
                case .title(let title):
                    insertSegment(withTitle: title, at: $0, animated: false)
                }
            }

            for item in viewModel.items {
                switch item.content {
                case .title(let title):
                    setAccessibilityIdentifier(String(describing: item.id.or(default: title)), for: title)
                default:
                    break
                }
            }

            guard isMomentary == false else { return }
            selectedSegmentIndex = viewModel.defaultSelectedSegmentIndex
            sendActions(for: .valueChanged)
        }
    }

    // MARK: - Setup

    public convenience init() {
        self.init(frame: .zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.borderWidth = 1
        selectedSegmentTintColor = .white
    }

    func setAccessibilityIdentifier(_ accessibilityIdentifier: String, for segmentTitle: String) {
        guard let segment = subviews.first(
            where: { $0.subviews.filter(UILabel.self).contains(where: { $0.text == segmentTitle }) }
        ) else {
            return
        }
        segment.accessibilityIdentifier = accessibilityIdentifier
    }
}
