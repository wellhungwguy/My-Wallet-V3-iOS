// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Address: Hashable {

    public enum Constants {
        static let usIsoCode = "US"
        public static let usPrefix = "US-"
    }

    public let line1: String?

    public let line2: String?

    public let city: String?

    public let postCode: String?

    public let state: String?

    /// Country code in ISO-2
    public let country: String?

    public init(
        line1: String?,
        line2: String?,
        city: String?,
        postCode: String?,
        state: String?,
        country: String?
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.postCode = postCode
        self.country = country

        if let state = state,
           country == Constants.usIsoCode,
           !state.hasPrefix(Constants.usPrefix)
        {
            self.state = Constants.usPrefix + state
        } else {
            self.state = state
        }
    }
}
