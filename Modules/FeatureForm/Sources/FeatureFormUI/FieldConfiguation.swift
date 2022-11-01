// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

public struct FieldConfiguation {
    let textAutocorrectionType: TextAutocorrectionType

    public init(
        textAutocorrectionType: TextAutocorrectionType = .default
    ) {
        self.textAutocorrectionType = textAutocorrectionType
    }
}

public enum TextAutocorrectionType {
    case `default`
    case no
    case yes
}

extension UITextAutocorrectionType {
    init(type: TextAutocorrectionType) {
        switch type {
        case .default:
            self = .default
        case .no:
            self = .no
        case .yes:
            self = .yes
        }
    }
}
