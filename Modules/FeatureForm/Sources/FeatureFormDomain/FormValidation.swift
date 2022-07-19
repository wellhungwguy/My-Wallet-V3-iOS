// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

extension FormQuestion {

    var isValid: Bool {
        let isValid: Bool
        switch type {
        case .singleSelection:
            let selections = children.filter { $0.checked == true }
            isValid = selections.count == 1 && selections.hasAllValidAnswers
        case .multipleSelection:
            let selections = children.filter { $0.checked == true }
            isValid = selections.count >= 1 && selections.hasAllValidAnswers
        case .openEnded:
            if let regex = regex {
                isValid = input.emptyIfNil ~= regex
            } else {
                isValid = input.isNilOrEmpty
            }
        }
        return isValid
    }
}

extension FormAnswer {

    var isValid: Bool {
        var isValid = checked == true || input.isNotNilOrEmpty
        if let children = children {
            isValid = isValid && children.hasAllValidAnswers
        }
        if let regex = regex {
            isValid = isValid && input.emptyIfNil ~= regex
        }
        return isValid
    }
}

extension Array where Element == FormAnswer {

    var hasAllValidAnswers: Bool {
        allSatisfy(\.isValid)
    }
}

extension Array where Element == FormQuestion {

    public var isValidForm: Bool {
        allSatisfy(\.isValid)
    }
}
