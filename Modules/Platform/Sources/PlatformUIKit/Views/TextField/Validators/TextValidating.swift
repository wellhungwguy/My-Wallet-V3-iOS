// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public enum TextValidationState {

    // The text is valid
    case valid

    // The text is valid but there is a disclaimer
    case conceivable(reason: String?)

    // The text is valid but there are external reasons why
    // this entry cannot work.
    case blocked(reason: String?)

    /// The text is invalid
    case invalid(reason: String?)

    var isValid: Bool {
        switch self {
        case .valid, .conceivable:
            return true
        case .invalid, .blocked:
            return false
        }
    }

    var isBlocked: Bool {
        switch self {
        case .blocked:
            return true
        default:
            return false
        }
    }

    var isConceivable: Bool {
        switch self {
        case .conceivable:
            return true
        default:
            return false
        }
    }
}

/// A source of text stream
public protocol TextSource: AnyObject {
    var valueRelay: BehaviorRelay<String> { get }
}

/// Text validation mechanism
public protocol TextValidating: TextSource {
    var validationState: Observable<TextValidationState> { get }
    var isValid: Observable<Bool> { get }
}

extension TextValidating {
    public var isValid: Observable<Bool> {
        validationState.map(\.isValid)
    }
}
