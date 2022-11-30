// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol LocaleIdentifierServiceAPI {
    var timezoneIana: String { get }
    var acceptLanguage: String { get }
}

final class LocaleIdentifierService: LocaleIdentifierServiceAPI {
    var timezoneIana: String {
        TimeZone.current.identifier
    }

    var acceptLanguage: String {
        Bundle.main
            .preferredLocalizations
            .prefix(3)
            .joined(separator: ";")
    }
}
