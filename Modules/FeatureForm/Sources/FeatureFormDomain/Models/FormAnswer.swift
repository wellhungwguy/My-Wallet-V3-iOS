// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct FormAnswer: Codable, Identifiable, Equatable {

    public struct AnswerType: NewTypeString {
        public let value: String
        public init(_ value: String) { self.value = value }
        public static let selection: Self = "SELECTION"
        public static let openEnded: Self = "OPEN_ENDED"
    }

    public let id: String
    public let type: AnswerType
    public let text: String
    public var children: [FormAnswer]?
    public var hint: String?
    public var input: String?
    public var instructions: String?
    public let regex: String?
    public var checked: Bool?

    public init(
        id: String,
        type: AnswerType,
        text: String,
        children: [FormAnswer]?,
        input: String?,
        hint: String?,
        regex: String?,
        instructions: String? = nil,
        checked: Bool?
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.hint = hint
        self.children = children
        self.input = input
        self.regex = regex
        self.instructions = instructions
        self.checked = checked
    }
}
