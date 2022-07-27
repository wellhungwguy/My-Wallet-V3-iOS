import AnyCoding
import Foundation
import ToolKit

extension UX {

    public struct Action: Equatable, Hashable, Codable {

        public let title: String
        public let url: URL?

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
