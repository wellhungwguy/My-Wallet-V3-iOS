// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

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

    public init(
        header: Form.Header? = nil,
        context: String? = nil,
        nodes: [FormQuestion],
        blocking: Bool = true
    ) {
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
                text: nil,
                children: children,
                input: input,
                hint: hint,
                regex: regex,
                checked: nil,
                instructions: instructions
            )
        }
        set {
            input = newValue.input
        }
    }
}

extension Array where Element == FormQuestion {

    enum FormError: Error {
        case answerNotFound(FormAnswer.ID)
        case unsupportedType(String)
        case unableToDecodeValue
    }

    public func answer<T>(id: FormAnswer.ID) throws -> T? {
        let candidates = compactMap { question -> FormAnswer? in
            question.children.first(where: { $0.id == id })
        }
        guard candidates.count == 1, let answer = candidates.first else {
            throw FormError.answerNotFound(id)
        }

        let value: T?
        switch T.self {
        case is String.Type:
            value = answer.input as? T
        case is Date.Type:
            guard let input = answer.input, let timeInterval = TimeInterval(input) else {
                return nil
            }
            value = Date(timeIntervalSince1970: timeInterval) as? T
        case is Bool.Type:
            value = answer.checked as? T
        default:
            throw FormError.unsupportedType(String(describing: T.self))
        }
        return value
    }
}
