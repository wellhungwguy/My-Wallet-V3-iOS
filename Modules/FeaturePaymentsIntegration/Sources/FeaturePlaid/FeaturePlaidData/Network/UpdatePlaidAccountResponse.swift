// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct UpdatePlaidAccountResponse: Decodable {
   public let id: String
   public let currency: String
   public let partner: String
   public let state: String
   public let details: String?
   public let error: String?
   public let addedAt: String
}
