// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormQuestionView: View {

    @Binding var question: FormQuestion
    @Binding var showAnswersState: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(question.text)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }

            makeAnswersView()

            if let instructions = question.instructions {
                Text(instructions)
                    .typography(.caption1)
                    .foregroundColor(.semantic.body)
            }
        }
    }

    @ViewBuilder
    private func makeAnswersView() -> some View {
        switch question.type {

        case .multipleSelection where question.isDropdown == true:
            FormSelectionDropdownAnswersView(
                title: question.text,
                subtitle: question.instructions,
                selectionMode: .multi,
                answers: $question.children,
                showAnswerState: $showAnswersState
            )

        case .multipleSelection:
            FormMultipleSelectionAnswersView(
                title: question.text,
                answers: $question.children,
                showAnswersState: $showAnswersState
            )

        case .singleSelection where question.isDropdown == true:
            FormSelectionDropdownAnswersView(
                title: question.text,
                subtitle: question.instructions,
                selectionMode: .single,
                answers: $question.children,
                showAnswerState: $showAnswersState
            )

        case .singleSelection:
            FormSingleSelectionAnswersView(
                title: question.text,
                answers: $question.children,
                showAnswersState: $showAnswersState
            )

        case .openEnded where question.children.isNotEmpty:
            FormSingleSelectionAnswersView(
                title: question.text,
                answers: $question.children,
                showAnswersState: $showAnswersState
            )

        case .openEnded:
            FormSingleSelectionAnswersView(
                title: question.text,
                answers: $question.own.transform(get: { [$0] }, set: { $0[0] }),
                showAnswersState: $showAnswersState
            )
        }
    }
}

struct FormQuestionView_Previews: PreviewProvider {

    struct PreviewHelper: View {

        @State var question: FormQuestion
        @State var showAnswersState: Bool

        var body: some View {
            FormQuestionView(question: $question, showAnswersState: $showAnswersState)
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
            ),
            showAnswersState: false
        )
    }
}
