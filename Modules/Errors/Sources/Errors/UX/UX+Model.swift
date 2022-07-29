import AnyCoding
import Foundation
import ToolKit

extension UX {

    public struct Dialog: Equatable, Hashable, Codable {
        public var id: String?
        public var title: String
        public var message: String
        public var icon: Errors.UX.Icon?
        public var actions: [Errors.UX.Action]?
        public var categories: [String]?

        public init(
            id: String? = nil,
            title: String,
            message: String,
            icon: UX.Icon? = nil,
            actions: [UX.Action]? = nil,
            categories: [String]? = nil
        ) {
            self.id = id
            self.title = title
            self.message = message
            self.icon = icon
            self.actions = actions
            self.categories = categories
        }
    }

    public struct Action: Equatable, Hashable, Codable {

        public let title: String
        @Optional.Codable public var url: URL?

        public init(title: String, url: URL? = nil) {
            self.title = title
            self.url = url
        }
    }

    public struct Icon: Equatable, Hashable, Codable {

        public struct Status: Equatable, Hashable, Codable {
            public var url: URL?

            public init(url: URL?) {
                self.url = url
            }
        }

        public var url: URL
        public var accessibility: Accessibility?
        @Optional.Codable public var status: Status?

        public init(url: URL, accessibility: UX.Accessibility? = nil, status: Status? = nil) {
            self.url = url
            self.accessibility = accessibility
            self.status = status
        }

        public init(url: URL) {
            self.init(url: url, accessibility: nil, status: nil)
        }
    }

    public struct Accessibility: Equatable, Hashable, Codable {

        public var description: String

        public init(description: String) {
            self.description = description
        }
    }
}
