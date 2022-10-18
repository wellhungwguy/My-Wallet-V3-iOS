// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeaturePlaidDomain

public struct LinkTokenRequest: Encodable {
    public struct Attributes: Encodable {
        let supportedPartners = ["PLAID"]
        let redirect_uri = PlaidURLFactory.linkTokenRedirectURI
    }

  let currency = "USD"
  let attributes = Attributes()
}
