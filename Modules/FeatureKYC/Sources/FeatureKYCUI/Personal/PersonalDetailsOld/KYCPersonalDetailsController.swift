// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import PlatformKit
import PlatformUIKit
import ToolKit
import UIKit

/// Personal details entry screen in KYC flow
final class KYCPersonalDetailsController: KYCBaseViewController, ValidationFormView, ProgressableView {

    // MARK: - ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.5

    @IBOutlet var progressView: UIProgressView!

    // MARK: - IBOutlets

    @IBOutlet fileprivate var firstNameField: ValidationTextField!
    @IBOutlet fileprivate var lastNameField: ValidationTextField!
    @IBOutlet fileprivate var birthdayField: ValidationDateField!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!

    // MARK: ValidationFormView

    @IBOutlet var scrollView: UIScrollView!

    var validationFields: [ValidationTextField] {
        [firstNameField, lastNameField, birthdayField]
    }

    // MARK: Public Properties

    weak var delegate: PersonalDetailsDelegate?

    // MARK: Private Properties

    fileprivate var detailsCoordinator: PersonalDetailsCoordinator!
    private let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()

    // MARK: Overrides

    override class func make(with coordinator: KYCRouter) -> KYCPersonalDetailsController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .profile
        return controller
    }

    override func apply(model: KYCPageModel) {
        guard case .personalDetails(let user) = model else { return }

        firstNameField.contentType = .givenName
        lastNameField.contentType = .familyName

        if firstNameField.text == nil || firstNameField.text?.isEmpty == true {
            firstNameField.text = user.personalDetails.firstName
        }
        if lastNameField.text == nil || lastNameField.text?.isEmpty == true {
            lastNameField.text = user.personalDetails.lastName
        }

        firstNameField.accessibilityIdentifier = "kyc.info.first_name_field"
        lastNameField.accessibilityIdentifier = "kyc.info.last_name_field"
        birthdayField.accessibilityIdentifier = "kyc.info.dob_field"

        birthdayField.maximumDate = NabuUser.minimumAge
        if let birthday = user.personalDetails.birthday {
            birthdayField.selectedDate = birthday
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsCoordinator = PersonalDetailsCoordinator(interface: self)
        setupTextFields()
        handleKeyboardOffset()
        setupNotifications()
        setupProgressView()

        primaryButtonContainer.actionBlock = { [weak self] in
            guard let this = self else { return }
            this.primaryButtonTapped()
        }

        validationFields.enumerated().forEach { index, field in
            field.returnTappedBlock = { [weak self] in
                guard let this = self else { return }
                this.updateProgress(this.progression())
                guard this.validationFields.count > index + 1 else {
                    field.resignFocus()
                    return
                }
                let next = this.validationFields[index + 1]
                next.becomeFocused()
            }
        }

        setupProgressView()
        setupKeyboard()
    }

    private func setupKeyboard() {
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [flexibleSpace, doneButton]
        bar.sizeToFit()

        validationFields.forEach { $0.accessoryView = bar }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstNameField.becomeFocused()
    }

    // MARK: - Private Methods

    fileprivate func setupTextFields() {
        firstNameField.returnKeyType = .next
        firstNameField.contentType = .name

        lastNameField.returnKeyType = .next
        lastNameField.contentType = .familyName

        birthdayField.validationBlock = { value in
            guard let birthday = value else { return .invalid(nil) }
            guard let date = DateFormatter.medium.date(from: birthday) else { return .invalid(nil) }
            if date <= NabuUser.minimumAge {
                return .valid
            } else {
                return .invalid(.minimumDateRequirement)
            }
        }
    }

    fileprivate func setupNotifications() {
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) { [weak self] _ in
            self?.scrollView.setContentOffset(.zero, animated: true)
        }
    }

    fileprivate func progression() -> Float {
        let newProgression: Float = validationFields.map {
            $0.validate() == .valid ? 0.14 : 0.0
        }
        .reduce(startingValue, +)
        return max(newProgression, startingValue)
    }

    fileprivate func primaryButtonTapped() {
        guard checkFieldsValidity() else { return }
        validationFields.forEach { $0.resignFocus() }

        let details = KYCUpdatePersonalDetailsRequest(
            firstName: firstNameField.text,
            lastName: lastNameField.text,
            birthday: birthdayField.selectedDate
        )

        analyticsRecorder.record(
            event: AnalyticsEvents.KYC.kycPersonalDetailSet(fieldName: "")
        )

        delegate?.onSubmission(details, completion: { [weak self] in
            guard let this = self else { return }
            this.router.handle(event: .nextPageFromPageType(this.pageType, nil))
        })
    }
}

extension KYCPersonalDetailsController: PersonalDetailsInterface {
    func primaryButtonActivityIndicator(_ visibility: Visibility) {
        primaryButtonContainer.isLoading = visibility == .visible
    }

    func primaryButtonEnabled(_ enabled: Bool) {
        primaryButtonContainer.isEnabled = enabled
    }

    func populatePersonalDetailFields(_ details: PersonalDetails) {
        firstNameField.text = details.firstName
        lastNameField.text = details.lastName
        if let birthday = details.birthday {
            let birthdayText = DateFormatter.birthday.string(from: birthday)
            birthdayField.text = birthdayText
        }
    }
}

extension KYCPersonalDetailsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

extension NabuUser {
    static let minimumAge: Date = Calendar.current.date(
        byAdding: .year,
        value: -18,
        to: Date()
    ) ?? Date()
}
