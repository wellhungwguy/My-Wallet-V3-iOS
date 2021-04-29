//
//  KYCResubmitIdentityController.swift
//  Blockchain
//
//  Created by kevinwu on 1/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import DIKit
import KYCKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit
import Veriff

/// Account verification screen in KYC flow
final class KYCResubmitIdentityController: KYCBaseViewController, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.9
    @IBOutlet var progressView: UIProgressView!

    enum VerificationProviders {
        case veriff
    }

    // MARK: Factory

    override class func make(with coordinator: KYCCoordinator) -> KYCResubmitIdentityController {
        let controller = makeFromStoryboard()
        controller.coordinator = coordinator
        controller.pageType = .verifyIdentity
        return controller
    }

    // MARK: - Views

    @IBOutlet private var resubmitButton: PrimaryButtonContainer!
    @IBOutlet var summary: UILabel!
    @IBOutlet var reasonsTitle: UILabel!
    @IBOutlet var reasonsDescription: UILabel!
    @IBOutlet var imageTopConstraint: NSLayoutConstraint!

    // MARK: - Public Properties

    weak var delegate: KYCVerifyIdentityDelegate?

    // MARK: - Private Properties

    private let currentProvider = VerificationProviders.veriff

    private var countryCode: String?

    private var presenter: KYCVerifyIdentityPresenter!
    private let loadingViewPresenter: LoadingViewPresenting = resolve()
    let analyticsRecorder: AnalyticsEventRecording = resolve()

    // MARK: - KYCCoordinatorDelegate

    override func apply(model: KYCPageModel) {
        guard case let .verifyIdentity(countryCode) = model else { return }
        self.countryCode = countryCode
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dependenciesSetup()
        resubmitButton.actionBlock = { [unowned self] in
            switch self.currentProvider {
            case .veriff:
                self.startVerificationFlow()
            }
        }
        summary.text = LocalizationConstants.KYC.documentsNeededSummary
        reasonsTitle.text = LocalizationConstants.KYC.reasonsTitle
        reasonsDescription.text = LocalizationConstants.KYC.reasonsDescription

        if !Constants.Booleans.IsUsingScreenSizeLargerThan5s {
            imageTopConstraint.constant = 24
        }
        setupProgressView()
    }

    private func dependenciesSetup() {
        let interactor = KYCVerifyIdentityInteractor()
        let identityPresenter = KYCVerifyIdentityPresenter(interactor: interactor, loadingView: self)
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
    fileprivate func startVerificationFlow(_ document: KYCDocumentType? = nil, provider: VerificationProviders = .veriff) {
        switch provider {
        case .veriff:
            veriffCredentialsRequest()
        }
    }

    private func didSelect(_ document: KYCDocumentType) {
        startVerificationFlow(document, provider: currentProvider)
    }
}

extension KYCResubmitIdentityController: LoadingView {

    func showLoadingIndicator() {
        resubmitButton.isLoading = true
    }

    func hideLoadingIndicator() {
        resubmitButton.isLoading = false
    }

    func showErrorMessage(_ message: String) {
        AlertViewPresenter.shared.standardError(message: message)
    }
}

extension KYCResubmitIdentityController: VeriffController {
    func onVeriffSubmissionCompleted() {
        loadingViewPresenter.show(with: LocalizationConstants.KYC.submittingInformation)
        delegate?.submitVerification(onCompleted: { [unowned self] in
            self.dismiss(animated: true, completion: {
                self.coordinator.handle(event: .nextPageFromPageType(self.pageType, nil))
            })},
        onError: { error in
            self.dismiss(animated: true, completion: {
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
            })
            Logger.shared.error("Failed to submit verification \(error.localizedDescription)")
        })
    }

    func onVeriffError(message: String) {
        showErrorMessage(message)
    }

    func onVeriffCancelled() {
        loadingViewPresenter.hide()
        dismiss(animated: true, completion: { [weak self] in
            guard let this = self else { return }
            this.coordinator.handle(event: .nextPageFromPageType(this.pageType, nil))
        })
    }

    func veriffCredentialsRequest() {
        delegate?.createCredentials(onSuccess: { [weak self] credentials in
            guard let this = self else { return }
            this.launchVeriffController(credentials: credentials)
        }, onError: { error in
            Logger.shared.error("Failed to get Veriff credentials. Error: \(error.localizedDescription)")
        })
    }
}

extension KYCResubmitIdentityController: CameraPromptingDelegate { }

extension KYCResubmitIdentityController: MicrophonePromptingDelegate {
    func onMicrophonePromptingComplete() {
        startVerificationFlow()
    }
}
