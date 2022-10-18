// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct LinkTokenResponse: Decodable {
    let id: String
    let partner: String
    let attributes: Attributes

    public struct Attributes: Decodable {
        let linkToken: String
        let tokenExpiresAt: String

        enum CodingKeys: String, CodingKey {
            case linkToken = "link_token"
            case tokenExpiresAt
        }
    }
}
