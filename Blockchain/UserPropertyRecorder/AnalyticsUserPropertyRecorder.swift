// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FirebaseAnalytics
import PlatformKit
import ToolKit

/// Records user properties using external analytics client
final class AnalyticsUserPropertyRecorder: UserPropertyRecording {

    // MARK: - Types

    struct UserPropertyErrorEvent: AnalyticsEvent {
        let name = "user_property_format_error"
        let params: [String: String]?
    }

    // MARK: - Properties

    private let logger: Logger
    private let validator: AnalyticsUserPropertyValidator
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Setup

    init(
        validator: AnalyticsUserPropertyValidator = AnalyticsUserPropertyValidator(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        logger: Logger = .shared
    ) {
        self.validator = validator
        self.analyticsRecorder = analyticsRecorder
        self.logger = logger
    }

    // MARK: - API

    func record(id: String) {
        Analytics.setUserID(id.sha256)
    }

    /// Records a standard user property
    func record(_ property: StandardUserProperty) {
        record(property: property)
    }

    /// Records a hashed user property
    func record(_ property: HashedUserProperty) {
        record(property: property)
    }

    // MARK: - Accessors

    private func record(property: UserProperty) {
        let name = property.key.rawValue
        let value: String
        if property.truncatesValueIfNeeded {
            value = validator.truncated(value: property.value)
        } else {
            value = property.value
        }
        do {
            try validator.validate(name: name)
            try validator.validate(value: value)
            Analytics.setUserProperty(value, forName: name)
        } catch { // Catch the error and record it using analytics event recorder
            defer {
                logger.error("could not send user property \(name)! \(value) received error: \(String(describing: error))")
            }
            guard let error = error as? AnalyticsUserPropertyValidator.UserPropertyError else {
                return
            }
            let errorName = validator.truncated(name: error.rawValue)
            let errorValue = validator.truncated(value: name)
            let event = UserPropertyErrorEvent(params: [errorName: errorValue])
            analyticsRecorder.record(event: event)
        }
    }
}
