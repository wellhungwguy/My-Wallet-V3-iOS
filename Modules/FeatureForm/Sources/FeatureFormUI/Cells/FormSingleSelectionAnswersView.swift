// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormSingleSelectionAnswersView: View {

    @Binding var answers: [FormAnswer]

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
            FormSingleSelectionAnswerView(answer: answer)
                .onChange(of: answer.wrappedValue) { newValue in
                    guard newValue.checked == true else {
                        return
                    }
                    for index in answers.indices {
                        answers[index].checked = answers[index] == newValue
                    }
                }
        case .openEnded:
            FormOpenEndedAnswerView(answer: answer)

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
            ]
        )
    }

    struct PreviewHelper: View {

        @State var answers: [FormAnswer]

        var body: some View {
            FormSingleSelectionAnswersView(answers: $answers)
        }
    }
}
