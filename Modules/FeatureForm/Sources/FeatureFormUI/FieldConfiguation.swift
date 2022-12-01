// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

public struct FieldConfiguation {
    public struct BottomButton {
        let leadingPrefixText: String?
        let title: String
        let action: () -> Void

        public init(
            leadingPrefixText: String?,
            title: String,
            action: @escaping () -> Void
        ) {
            self.leadingPrefixText = leadingPrefixText
            self.title = title
            self.action = action
        }
    }
    let textAutocorrectionType: TextAutocorrectionType
    let onFieldTapped: (() -> Void)?
    let bottomButton: BottomButton?

    /// TextField Input Component
    /// - Parameters:
    ///   - textAutocorrectionType: default Autocorrection
    ///   - onFieldTapped: if this handler passed, the field will be disabled
    ///   - bottomButton: bottom button
    public init(
        textAutocorrectionType: TextAutocorrectionType = .default,
        onFieldTapped: (() -> Void)? = nil,
        bottomButton: BottomButton? = nil
    ) {
        self.textAutocorrectionType = textAutocorrectionType
        self.onFieldTapped = onFieldTapped
        self.bottomButton = bottomButton
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
