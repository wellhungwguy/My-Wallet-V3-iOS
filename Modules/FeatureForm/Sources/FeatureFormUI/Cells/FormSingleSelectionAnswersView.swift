// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormSingleSelectionAnswersView: View {

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
        case .selection:
            FormSingleSelectionAnswerView(answer: answer, showAnswerState: $showAnswersState)
                .onChange(of: answer.wrappedValue) { newValue in
                    guard newValue.checked == true else {
                        return
                    }
                    for index in answers.indices {
                        answers[index].checked = answers[index] == newValue
                    }
                }
        case .openEnded:
            FormOpenEndedAnswerView(answer: answer, showAnswerState: $showAnswersState)
        case .date:
            FormDateAnswerView(answer: answer, showAnswerState: $showAnswersState)
        default:
            Text(answer.wrappedValue.type.value)
                .typography(.paragraph1)
                .foregroundColor(.semantic.error)
        }
    }
}

struct FormSingleSelectionAnswersView_Previews: PreviewProvider {

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
                )
            ],
            showAnswersState: false
        )
    }

    struct PreviewHelper: View {

        @State var answers: [FormAnswer]
        @State var showAnswersState: Bool

        var body: some View {
            FormSingleSelectionAnswersView(answers: $answers, showAnswersState: $showAnswersState)
        }
    }
}
