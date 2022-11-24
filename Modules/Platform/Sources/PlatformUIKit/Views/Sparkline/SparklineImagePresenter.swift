// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public class SparklineImagePresenter {

    // MARK: - Public Properties

    public var state: Observable<State> {
        stateRelay.asObservable()
    }

    public var image: Driver<UIImage?> {
        imageRelay.asDriver()
    }

    // MARK: - Private Properties

    private let calculator: SparklineCalculator
    private let fillColor: UIColor
    private let scale: CGFloat
    private let imageRelay = BehaviorRelay<UIImage?>(value: nil)
    private let fillColorRelay = BehaviorRelay<UIColor>(value: .gray4)
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let disposeBag = DisposeBag()

    // MARK: - Injected

    let interactor: SparklineInteracting
    let accessibility: Accessibility

    public init(
        with interactor: SparklineInteracting,
        calculator: SparklineCalculator,
        fillColor: UIColor,
        scale: CGFloat
    ) {
        self.fillColor = fillColor
        self.scale = scale
        self.calculator = calculator
        self.interactor = interactor
        self.accessibility = .id(Accessibility.Identifier.SparklineView.prefix)

        self.interactor.calculationState.map(weak: self) { (self, calculationState) -> State in
            switch calculationState {
            case .calculating:
                return .loading
            case .invalid:
                return .invalid
            case .value(let points):
                let path = self.calculator.sparkline(with: points)
                guard let image = self.imageFromPath(path) else { return .invalid }
                return .valid(image: image)
            }
        }
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

        stateRelay.compactMap { [weak self] state -> UIImage? in
            guard self != nil else { return nil }
            guard case .valid(let image) = state else { return nil }
            return image
        }
        .bindAndCatch(to: imageRelay)
        .disposed(by: disposeBag)
    }

    private func imageFromPath(_ path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(calculator.size, false, scale)
        UIGraphicsBeginImageContext(calculator.size)
        fillColor.setStroke()
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension SparklineImagePresenter {

    public enum State {
        /// There is no data to display
        case empty

        /// The data is being fetched
        case loading

        /// Valid state - data has been received
        case valid(image: UIImage)

        /// Invalid state - An error was thrown
        case invalid

        /// Returns the text value if there is a valid value
        public var value: UIImage? {
            switch self {
            case .valid(let value):
                return value
            default:
                return nil
            }
        }
    }
}
