// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import Localization
import PlatformUIKit
import RxCocoa
import RxSwift

public final class VerifyDeviceDetailsScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Type

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.AuthorizeDevice

    // MARK: - Properties

    public var extendSafeAreaUnderNavigationBar: Bool = true
    public var titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)
    public var navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .custom(
        leading: .none,
        trailing: .close,
        barStyle: .darkContent(background: .clear)
    )
    public var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default
    public var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default
    public var reloadRelay: PublishRelay<Void> = .init()

    private var headers: [Int: HeaderBuilder] {
        let image = ImageViewContent(
            imageResource: .local(name: "icon-laptop", bundle: .platformUIKit),
            accessibility: .none,
            renderingMode: .normal
        )
        let model = AccountPickerHeaderModel(
            imageContent: image,
            switchable: true,
            subtitle: LocalizedString.subtitle,
            tableTitle: nil,
            title: LocalizedString.title
        )
        return [
            0: AccountPickerHeaderBuilder(headerType: .default(model))
        ]
    }

    public var cells: [DetailsScreen.CellType] {
        let locationPresenter = DefaultLineItemCellPresenter(
            interactor: DefaultLineItemCellInteractor(
                title: DefaultLabelContentInteractor(knownValue: LocalizedString.Details.location),
                description: DefaultLabelContentInteractor(knownValue: details.originLocation)
            ),
            accessibilityIdPrefix: ""
        )
        let ipPresenter = DefaultLineItemCellPresenter(
            interactor: DefaultLineItemCellInteractor(
                title: DefaultLabelContentInteractor(knownValue: LocalizedString.Details.ip),
                description: DefaultLabelContentInteractor(knownValue: details.originIP)
            ),
            accessibilityIdPrefix: ""
        )
        let browserPresenter = DefaultLineItemCellPresenter(
            interactor: DefaultLineItemCellInteractor(
                title: DefaultLabelContentInteractor(knownValue: LocalizedString.Details.browser),
                description: DefaultLabelContentInteractor(knownValue: details.originBrowser)
            ),
            accessibilityIdPrefix: ""
        )
        let datePresenter = DefaultLineItemCellPresenter(
            interactor: DefaultLineItemCellInteractor(
                title: DefaultLabelContentInteractor(knownValue: LocalizedString.Details.date),
                description: DefaultLabelContentInteractor(
                    knownValue: DateFormatter.elegantDateFormatter.string(from: requestTime)
                )
            ),
            accessibilityIdPrefix: ""
        )
        let labelPresenter = DefaultLabelContentPresenter(
            knownValue: LocalizedString.description,
            descriptors: .body(accessibilityId: "")
        )
        return [
            .separator,
            .lineItem(locationPresenter),
            .separator,
            .lineItem(ipPresenter),
            .separator,
            .lineItem(browserPresenter),
            .separator,
            .lineItem(datePresenter),
            .separator,
            .label(labelPresenter)
        ]
    }

    public var buttons: [ButtonViewModel] {
        [approveButton, denyButton]
    }

    private let approveButton = ButtonViewModel.primary(with: LocalizedString.Buttons.approve)
    private let denyButton = ButtonViewModel.cancel(with: LocalizedString.Buttons.deny)

    private let details: DeviceVerificationDetails
    private let requestTime: Date
    private let didAuthorizeDevice: (Bool) -> Void
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        details: DeviceVerificationDetails,
        requestTime: Date,
        didAuthorizeDevice: @escaping (Bool) -> Void
    ) {
        self.details = details
        self.requestTime = requestTime
        self.didAuthorizeDevice = didAuthorizeDevice
        setup()
    }

    // MARK: - Methods

    public func header(for section: Int) -> HeaderBuilder? {
        headers[section]
    }

    private func setup() {
        approveButton
            .tapRelay
            .bind(onNext: { [weak self] _ in
                self?.didAuthorizeDevice(true)
            })
            .disposed(by: disposeBag)

        denyButton
            .tapRelay
            .bind(onNext: { [weak self] _ in
                self?.didAuthorizeDevice(false)
            })
            .disposed(by: disposeBag)
    }
}
