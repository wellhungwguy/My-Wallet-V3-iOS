// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormMultipleSelectionAnswersView: View {

    let title: String
    @Binding var answers: [FormAnswer]
    @Binding var showAnswersState: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            ForEach($answers) { answer in
                view(for: answer)
            }
        }
    }

    @ViewBuilder
    private func view(for answer: Binding<FormAnswer>) -> some View {
        switch answer.wrappedValue.type {
        case .date:
            FormDateDropdownAnswersView(
                title: title,
                answer: answer,
                showAnswerState: $showAnswersState
            )
        case .selection:
            FormMultipleSelectionAnswerView(
                title: title,
                answer: answer,
                showAnswerState: $showAnswersState
            )
        case .openEnded:
            FormOpenEndedAnswerView(answer: answer, showAnswerState: $showAnswersState)
        default:
            Text(answer.wrappedValue.type.value)
                .typography(.paragraph1)
                .foregroundColor(.semantic.error)
        }
    }
}

struct FormMultipleSelectionAnswersView_Previews: PreviewProvider {

    static var previews: some View {
        PreviewHelper(
            answers: [
                FormAnswer(
                    id: "a1",
                    type: .selection,
                    text: "Answer 1",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a2",
                    type: .openEnded,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a3",
                    type: .date,
                    text: "Answer 3",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                )
            ],
            showAnswersState: false
        )
    }

    struct PreviewHelper: View {

        @State var answers: [FormAnswer]
        @State var showAnswersState: Bool

        var body: some View {
            FormMultipleSelectionAnswersView(
                title: "Title",
                answers: $answers,
                showAnswersState: $showAnswersState
            )
        }
    }
}
