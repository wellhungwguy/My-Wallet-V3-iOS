// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol FromEncodingError: LocalizedError {

    static func from(_ encodingError: EncodingError) -> Self
}
