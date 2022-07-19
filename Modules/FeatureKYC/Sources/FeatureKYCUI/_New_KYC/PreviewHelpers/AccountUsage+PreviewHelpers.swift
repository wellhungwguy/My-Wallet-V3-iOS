// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureFormDomain

extension AccountUsage {

    static let previewQuestions: [FormQuestion] = [
        FormQuestion(
            id: "q1",
            type: .singleSelection,
            isDropdown: false,
            text: "Question 1",
            instructions: "Select one",
            children: [
                FormAnswer(
                    id: "q1-a1",
                    type: .selection,
                    text: "Answer 1",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: true
                ),
                FormAnswer(
                    id: "q1-a2",
                    type: .selection,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: false
                )
            ]
        ),
        FormQuestion(
            id: "q2",
            type: .multipleSelection,
            isDropdown: false,
            text: "Question 2",
            instructions: "Select all that apply",
            children: [
                FormAnswer(
                    id: "q2-a1",
                    type: .selection,
                    text: "Answer 1",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: true
                ),
                FormAnswer(
                    id: "q2-a2",
                    type: .selection,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: false
                ),
                FormAnswer(
                    id: "q2-a3",
                    type: .selection,
                    text: "Answer 3",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: true
                )
            ]
        )
    ]
}
