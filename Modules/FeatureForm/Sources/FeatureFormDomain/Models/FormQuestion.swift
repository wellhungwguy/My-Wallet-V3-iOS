// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Form: Codable, Equatable {

    public struct Header: Codable, Equatable {

        public let title: String
        public let description: String

        public init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    public let header: Header?
    public let context: String?
    public var nodes: [FormQuestion]
    public let blocking: Bool

    public var isEmpty: Bool { nodes.isEmpty }
    public var isNotEmpty: Bool { !isEmpty }

    public init(header: Form.Header? = nil, context: String? = nil, nodes: [FormQuestion], blocking: Bool = true) {
        self.header = header
        self.context = context
        self.nodes = nodes
        self.blocking = blocking
    }
}

public struct FormQuestion: Codable, Identifiable, Equatable {

    public enum QuestionType: String, Codable {
        case singleSelection = "SINGLE_SELECTION"
        case multipleSelection = "MULTIPLE_SELECTION"
        case openEnded = "OPEN_ENDED"

        var answer: FormAnswer.AnswerType {
            FormAnswer.AnswerType(rawValue)
        }
    }

    public let id: String
    public let type: QuestionType
    public let isDropdown: Bool?
    public let text: String
    public let instructions: String?
    @Default<Empty> public var children: [FormAnswer]
    public var input: String?
    public let hint: String?
    public let regex: String?

    public init(
        id: String,
        type: QuestionType,
        isDropdown: Bool?,
        text: String,
        instructions: String?,
        regex: String? = nil,
        input: String? = nil,
        hint: String? = nil,
        children: [FormAnswer]
    ) {
        self.id = id
        self.type = type
        self.isDropdown = isDropdown
        self.text = text
        self.instructions = instructions
        self.regex = regex
        self.input = input
        self.hint = hint
        self.children = children
    }

    public var own: FormAnswer {
        get {
            FormAnswer(
                id: id,
                type: type.answer,
                text: text,
                children: children,
                input: input,
                hint: hint,
                regex: regex,
                instructions: instructions,
                checked: nil
            )
        }
        set {
            input = newValue.input
        }
    }
}
