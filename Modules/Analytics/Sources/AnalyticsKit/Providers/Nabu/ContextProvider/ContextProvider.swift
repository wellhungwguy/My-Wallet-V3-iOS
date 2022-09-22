// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class ContextProvider: ContextProviderAPI {

    private let guidProvider: GuidRepositoryAPI
    private let traitRepository: TraitRepositoryAPI
    private let timeZone: TimeZone
    private let locale: Locale

    init(
        guidProvider: GuidRepositoryAPI,
        traitRepository: TraitRepositoryAPI,
        timeZone: TimeZone = .current,
        locale: Locale = .current
    ) {
        self.guidProvider = guidProvider
        self.traitRepository = traitRepository
        self.timeZone = timeZone
        self.locale = locale
    }

    let defaultTraits: [String: String] = [
        "device": "APP-iOS"
    ]

    var context: Context {
        let localeString = [locale.languageCode, locale.regionCode]
            .compactMap { $0 }
            .joined(separator: "-")
        let timeZoneString = timeZone.localizedName(for: .shortStandard, locale: locale)
        return Context(
            app: App(),
            device: Device(),
            os: OperatingSystem(),
            locale: localeString,
            screen: Screen(),
            traits: defaultTraits.merging(traitRepository.traits, uniquingKeysWith: { $1 }),
            timezone: timeZoneString
        )
    }

    var anonymousId: String? {
        guidProvider.guid
    }
}
