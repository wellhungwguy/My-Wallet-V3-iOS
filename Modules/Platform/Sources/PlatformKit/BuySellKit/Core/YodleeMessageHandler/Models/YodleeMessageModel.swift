// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MessageAction: String, Decodable {
    case exit
}

public enum MessageStatus: String, Decodable {
    case success = "SUCCESS"
    case abandoned = "ACTION_ABANDONED"
    case closed = "USER_CLOSE_ACTION"
    case failed = "FAILED"
}

public struct DataMessage: Decodable {
    public struct SiteData: Decodable {
        public let reason: String?
        public let status: MessageStatus?
        public let accountId: String?
        public let providerId: Int?
        public let providerAccountId: Int?
        public let providerName: String?
    }

    public let action: MessageAction?
    public let status: MessageStatus?
    public let sites: [SiteData]?
    public let providerId: Int?
    public let providerAccountId: Int?
    public let providerName: String?
    public let additionalStatus: String?
    public let reason: String?
}

public struct DataUrl: Decodable {
    public let url: String
}

public enum YodleeDataType: Decodable {
    case message(data: DataMessage)
    case externalLink(url: DataUrl)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: YodleeModel.Keys.self)
        let type = try container.decode(YodleeModel.MessageType.self, forKey: .type)
        switch type {
        case .post:
            let data = try container.decode(DataMessage.self, forKey: .data)
            self = .message(data: data)
        case .openUrl:
            let data = try container.decode(DataUrl.self, forKey: .data)
            self = .externalLink(url: data)
        }
    }
}

public struct YodleeModel: Decodable {
    public enum MessageType: String, Decodable {
        case post = "POST_MESSAGE"
        case openUrl = "OPEN_EXTERNAL_URL"
    }

    public let type: MessageType
    public let data: YodleeDataType

    enum Keys: String, CodingKey {
        case type
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.type = try container.decode(MessageType.self, forKey: .type)
        self.data = try YodleeDataType(from: decoder)
    }
}
