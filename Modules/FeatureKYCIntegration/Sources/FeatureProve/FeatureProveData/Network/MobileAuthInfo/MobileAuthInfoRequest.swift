// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain

public struct MobileAuthInfoRequest: Encodable {
    public struct Attributes: Encodable {
        let supportedPartners = ["PROVE"]
    }

  let attributes = Attributes()
}
