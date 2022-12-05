// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureFormDomain
import FeatureProveDomain
import Localization
import ToolKit

private typealias LocalizedFormString = LocalizationConstants.EnterFullInformation.Body.Form

extension FormQuestion {

    static func enterFullInformation(phone: String? = nil, dateOfBirth: Date?) -> [FormQuestion] {
        [
            FormQuestion(
                id: EnterFullInformation.InputField.phone.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedFormString.phoneInputTitle,
                instructions: LocalizedFormString.phoneInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: EnterFullInformation.InputField.phone.rawValue,
                        type: .openEnded,
                        input: phone,
                        prefixInputText: LocalizedFormString.phoneInputPrefix,
                        hint: LocalizedFormString.phoneInputPlaceholder,
                        regex: TextRegex.notEmpty.rawValue,
                        instructions: LocalizedFormString.phoneInputHint
                    )
                ]
            ),
            FormQuestion(
                id: EnterFullInformation.InputField.dateOfBirth.rawValue,
                type: .openEnded,
                isDropdown: false,
                text: LocalizedFormString.dateOfBirthInputTitle,
                instructions: LocalizedFormString.dateOfBirthInputHint,
                regex: TextRegex.notEmpty.rawValue,
                children: [
                    FormAnswer(
                        id: EnterFullInformation.InputField.dateOfBirth.rawValue,
                        type: .date,
                        validation: FormAnswer.Validation(
                            rule: .withinRange,
                            metadata: [
                                .maxValue: String(
                                    (Calendar.current.eighteenYearsAgo ?? Date()).timeIntervalSince1970
                                )
                            ]
                        ),
                        text: nil,
                        input: dateOfBirth?.timeIntervalSince1970.description
                    )
                ]
            )
        ]
    }
}
