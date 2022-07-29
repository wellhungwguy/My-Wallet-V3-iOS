// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct LegalItem: Codable, Equatable, Identifiable {

    public enum LegalType: String {

        case shortFormDisclosure = "short-form-disclosure"
        case termsAndConditions = "terms-and-conditions"
        case unknown
    }

    public let url: URL
    public let version: Int
    public let name: String
    public let displayName: String
    public let acceptedVersion: Int?

    public init(
        url: URL,
        version: Int,
        name: String,
        displayName: String,
        acceptedVersion: Int? = nil
    ) {
        self.name = name
        self.displayName = displayName
        self.url = url
        self.version = version
        self.acceptedVersion = acceptedVersion
    }

    public var id: String {
        name
    }

    public var legalType: LegalType {
        LegalType(rawValue: name) ?? .unknown
    }
}
