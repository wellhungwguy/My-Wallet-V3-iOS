// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxCocoa
import RxSwift

final class SecureChannelDetailsPresenter: DetailsScreenPresenterAPI {
    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let extendSafeAreaUnderNavigationBar: Bool = true

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .custom(
        leading: .none,
        trailing: .close,
        barStyle: .darkContent(background: .clear)
    )

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    var buttons: [ButtonViewModel] {
        contentReducer.buttons
    }

    private let contentReducer: ContentReducer
    private let didAcceptSecureChannel: (Bool) -> Void
    private let disposeBag = DisposeBag()

    init(candidate: SecureChannelConnectionCandidate, didAcceptSecureChannel: @escaping (Bool) -> Void) {
        self.didAcceptSecureChannel = didAcceptSecureChannel
        self.contentReducer = ContentReducer(candidate: candidate)

        contentReducer.approveTapped
            .bind(
                onNext: { [weak self] _ in
                    self?.didAcceptSecureChannel(true)
                }
            )
            .disposed(by: disposeBag)
        contentReducer.denyTapped
            .bind(
                onNext: { [weak self] _ in
                    self?.didAcceptSecureChannel(false)
                }
            )
            .disposed(by: disposeBag)
    }

    func header(for section: Int) -> HeaderBuilder? {
        contentReducer.headers[section]
    }
}
