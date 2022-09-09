// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import Localization
import PlatformKit
import PlatformUIKit
import SafariServices
import ToolKit
import Veriff

private typealias Events = AnalyticsEvents.New.KYC

/// Account verification screen in KYC flow
final class KYCVerifyIdentityController: KYCBaseViewController, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.9
    @IBOutlet var progressView: UIProgressView!

    enum VerificationProviders {
        case veriff
    }

    // MARK: - Views

    @IBOutlet private var nextButton: PrimaryButtonContainer!

    // MARK: - UILabels

    @IBOutlet private var headline: UILabel!
    @IBOutlet private var subheadline: UILabel!
    @IBOutlet private var passport: UILabel!
    @IBOutlet private var nationalIDCard: UILabel!
    @IBOutlet private var residenceCard: UILabel!
    @IBOutlet private var driversLicense: UILabel!
    @IBOutlet private var enableCamera: UILabel!
    @IBOutlet private var enableCameraDescription: UILabel!
    @IBOutlet private var countrySupportedHeader: UILabel!
    @IBOutlet private var countrySupportedDescription: ActionableLabel!

    // MARK: UIStackView

    @IBOutlet private var documentTypeStackView: UIStackView!

    // MARK: - Public Properties

    weak var delegate: KYCVerifyIdentityDelegate?

    // MARK: - Private Properties

    private let veriffVersion: String = "/v1/"

    private let currentProvider = VerificationProviders.veriff

    private var countryCode: String?

    private var presenter: KYCVerifyIdentityPresenter!
    private let loadingViewPresenter: LoadingViewPresenting = resolve()
    let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    private let identityVerificationAnalyticsService: IdentityVerificationAnalyticsServiceAPI = resolve()

    private var countrySupportedTrigger: ActionableTrigger!

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCVerifyIdentityController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: - KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .verifyIdentity(let countryCode) = model else { return }
        self.countryCode = countryCode
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        addAccessibilityIds()
        dependenciesSetup()
        nextButton.actionBlock = { [unowned self] in
            self.analyticsRecorder.record(event: Events.preVerificationCTAClicked)
            self.analyticsRecorder.record(event: AnalyticsEvents.KYC.kycVerifyIdStartButtonClick)
            switch self.currentProvider {
            case .veriff:
                self.presenter.didTapNext()
            }
        }
        enableCamera.text = LocalizationConstants.KYC.enableCamera
        enableCameraDescription.text = LocalizationConstants.KYC.enableCameraDescription
        passport.text = LocalizationConstants.KYC.passport
        nationalIDCard.text = LocalizationConstants.KYC.nationalIdentityCard
        residenceCard.text = LocalizationConstants.KYC.residencePermit
        driversLicense.text = LocalizationConstants.KYC.driversLicense
        setupCountrySupportedText()
        setupProgressView()
    }

    private func setupCountrySupportedText() {
        countrySupportedHeader.text = LocalizationConstants.KYC.isCountrySupportedHeader

        countrySupportedDescription.delegate = self

        countrySupportedTrigger = ActionableTrigger(
            text: LocalizationConstants.KYC.isCountrySupportedDescription1,
            CTA: LocalizationConstants.KYC.isCountrySupportedDescription2,
            secondary: LocalizationConstants.KYC.isCountrySupportedDescription3
        ) { [unowned self] in
            guard let url = URL(string: "https://support.blockchain.com/hc/en-us/articles/360018751932") else {
                return
            }
            let viewController = SFSafariViewController(url: url)
            self.present(viewController, animated: true)
        }

        let description = NSMutableAttributedString(
            string: countrySupportedTrigger.primaryString,
            attributes: defaultAttributes()
        )
        description.append(
            NSAttributedString(
                string: " " + countrySupportedTrigger.callToAction,
                attributes: actionAttributes()
            )
        )
        if let secondaryString = countrySupportedTrigger.secondaryString {
            description.append(
                NSAttributedString(
                    string: " " + secondaryString,
                    attributes: defaultAttributes()
                )
            )
        }
        countrySupportedDescription.attributedText = description
    }

    private func addAccessibilityIds() {
        headline.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.headerText)
        subheadline.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.subheaderText)
        passport.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.passportText)
        nationalIDCard.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.nationalIDCardText)
        residenceCard.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.residenceCardText)
        driversLicense.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.driversLicenseText)
        enableCamera.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.enableCameraHeaderText)
        enableCameraDescription.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.enableCameraSubheaderText)
        countrySupportedHeader.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.countrySupportedHeaderText)
        countrySupportedDescription.accessibility = .id(Accessibility.Identifier.KYCVerifyIdentityScreen.countrySupportedSubheaderText)
    }

    private func actionAttributes() -> [NSAttributedString.Key: Any] { [
        .font: Font(.branded(.montserratRegular), size: .custom(18.0)).result,
        .foregroundColor: UIColor.brandSecondary
    ]
    }

    private func defaultAttributes() -> [NSAttributedString.Key: Any] { [
        .font: Font(.branded(.montserratRegular), size: .custom(18.0)).result,
        .foregroundColor: countrySupportedDescription.textColor as Any
    ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLeftBarButtonItem()

        guard let code = countryCode else { return }
        presenter.presentDocumentTypeOptions(code)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsRecorder.record(event: Events.preVerificationViewed)
        updateLeftBarButtonItem()
    }

    override func navControllerCTAType() -> NavigationCTA {
        .dismiss
    }

    override func navControllerRightBarButtonTapped(_ navController: KYCOnboardingNavigationController) {
        analyticsRecorder.record(event: Events.preVerificationDismissed)
        super.navControllerRightBarButtonTapped(navController)
    }

    private func updateLeftBarButtonItem() {
        navigationItem.hidesBackButton = true
    }

    private func dependenciesSetup() {
        let interactor = KYCVerifyIdentityInteractor()
        let identityPresenter = KYCVerifyIdentityPresenter(interactor: interactor, loadingView: self)
        identityPresenter.identityView = self
        identityPresenter.cameraPromptingDelegate = self
        identityPresenter.microphonePromptingDelegate = self
        presenter = identityPresenter
        delegate = presenter
    }

    /// Begins identity verification and presents the view
    ///
    /// - Parameters:
    ///   - document: enum of identity types mapped to an identity provider
    ///   - provider: the current provider of verification services
    fileprivate func startVerificationFlow(
        _ document: KYCDocumentType? = nil,
        provider: VerificationProviders = .veriff
    ) {
        switch provider {
        case .veriff:
            veriffCredentialsRequest()
        }
    }

    private func didSelect(_ document: KYCDocumentType) {
        startVerificationFlow(document, provider: currentProvider)
    }
}

extension KYCVerifyIdentityController: ActionableLabelDelegate {
    func targetRange(_ label: ActionableLabel) -> NSRange? {
        countrySupportedTrigger.actionRange()
    }

    func actionRequestingExecution(label: ActionableLabel) {
        countrySupportedTrigger.execute()
    }
}

extension KYCVerifyIdentityController: KYCVerifyIdentityView {
    func showDocumentTypes(_ types: [KYCDocumentType]) {
        documentTypeStackView.isHidden = false
        types.forEach { [weak self] type in
            guard let this = self else { return }
            switch type {
            case .driversLicense:
                this.driversLicense.isHidden = false
            case .nationalIdentityCard:
                this.nationalIDCard.isHidden = false
            case .passport:
                this.passport.isHidden = false
            case .residencePermit:
                this.residenceCard.isHidden = false
            }
        }
    }
}

extension KYCVerifyIdentityController: PlatformUIKit.LoadingView {
    func showLoadingIndicator() {
        nextButton.isLoading = true
    }

    func hideLoadingIndicator() {
        nextButton.isLoading = false
    }

    func showErrorMessage(_ message: String) {
        AlertViewPresenter.shared.standardError(message: message)
    }
}

extension KYCVerifyIdentityController: VeriffController {

    func sessionDidEndWithResult(_ result: VeriffSdk.Result) {
        switch result.status {
        case .error(let error):
            trackInternalVeriffError(.init(veriffError: error))
            onVeriffError(message: error.localizedErrorMessage)
        case .done:
            onVeriffSubmissionCompleted()
        case .canceled:
            onVeriffCancelled()
        @unknown default:
            onVeriffCancelled()
        }
    }

    func onVeriffSubmissionCompleted() {
        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycVeriffInfoSubmitted)
        loadingViewPresenter.show(with: LocalizationConstants.KYC.submittingInformation)
        delegate?.submitVerification(
            onCompleted: { [unowned self] in
                self.dismiss(animated: true, completion: {
                    self.router.handle(event: .nextPageFromPageType(self.pageType, nil))
                })
            },
            onError: { error in
                self.dismiss(animated: true, completion: {
                    AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
                })
                Logger.shared.error("Failed to submit verification \(String(describing: error))")
            }
        )
    }

    func onVeriffError(message: String) {
        showErrorMessage(message)
    }

    func trackInternalVeriffError(_ error: InternalVeriffError) {
        switch error {
        case .localError:
            identityVerificationAnalyticsService.recordLocalError()
        case .serverError:
            identityVerificationAnalyticsService.recordServerError()
        case .networkError:
            identityVerificationAnalyticsService.recordNetworkError()
        case .uploadError:
            identityVerificationAnalyticsService.recordUploadError()
        case .videoFailed:
            identityVerificationAnalyticsService.recordVideoFailure()
        case .unknown:
            identityVerificationAnalyticsService.recordUnknownError()
        case .cameraUnavailable,
             .microphoneUnavailable,
             .deprecatedSDKVersion:
            break
        }
    }

    @objc
    func onVeriffCancelled() {
        loadingViewPresenter.hide()
        dismiss(animated: true, completion: { [weak self] in
            guard let this = self else { return }
            this.router.handle(event: .nextPageFromPageType(this.pageType, nil))
        })
    }

    func veriffCredentialsRequest() {
        delegate?.createCredentials(onSuccess: { [weak self] credentials in
            self?.launchVeriffController(credentials: credentials)
        }, onError: { [weak self] error in
            Logger.shared.error("Failed to get Veriff credentials. Error: \(String(describing: error))")
            self?.onVeriffError(message: String(describing: error))
        })
    }
}

extension KYCVerifyIdentityController: CameraPromptingDelegate {}

extension KYCVerifyIdentityController: MicrophonePromptingDelegate {
    func onMicrophonePromptingComplete() {
        startVerificationFlow()
    }
}
