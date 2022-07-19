// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormQuestionView: View {

    @Binding var question: FormQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {
            if question.type != .openEnded {
                VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                    Text(question.text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)

                    if let instructions = question.instructions {
                        Text(instructions)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    }
                }
            }

            makeAnswersView()
        }
    }

    @ViewBuilder
    private func makeAnswersView() -> some View {
        switch question.type {
        case .multipleSelection:
            FormMultipleSelectionAnswersView(answers: $question.children)

        case .singleSelection where question.isDropdown == true:
            FormSingleSelectionDropdownAnswersView(answers: $question.children)

        case .singleSelection:
            FormSingleSelectionAnswersView(answers: $question.children)

        case .openEnded:
            FormSingleSelectionAnswersView(
                answers: $question.own.transform(get: { [$0] }, set: { $0[0] })
            )
        }
    }
}

struct FormQuestionView_Previews: PreviewProvider {

    struct PreviewHelper: View {

        @State var question: FormQuestion

        var body: some View {
            FormQuestionView(question: $question)
        }
    }

    static var previews: some View {
        PreviewHelper(
            question: FormQuestion(
                id: "q1",
                type: .singleSelection,
                isDropdown: false,
                text: "Question 1",
                instructions: "Select one answer",
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
            )
        )
    }
}
