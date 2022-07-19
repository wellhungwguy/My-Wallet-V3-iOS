// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormRecursiveAnswerView<Content: View>: View {

    @Binding var answer: FormAnswer
    let content: () -> Content

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            content()

            if answer.checked == true, answer.children?.isEmpty == false {
                FormSingleSelectionAnswersView(answers: $answer.children ?? [])
                    .padding([.leading, .vertical], Spacing.padding2)
            }
        }
    }
}

struct FormOpenEndedAnswerView: View {

    @Binding var answer: FormAnswer
    @State var isFirstResponder: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            Text(answer.text)
                .typography(.paragraph2)
                .foregroundColor(.semantic.body)

            Input(
                text: $answer.input ?? "",
                isFirstResponder: $isFirstResponder,
                placeholder: answer.hint
            )
        }
    }
}

struct FormSingleSelectionAnswerView: View {

    @Binding var answer: FormAnswer

    var body: some View {
        FormRecursiveAnswerView(answer: $answer) {
            HStack(spacing: Spacing.padding1) {
                Text(answer.text)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)

                Spacer()

                Radio(isOn: $answer.checked ?? false)
            }
            .padding(.vertical, Spacing.padding2)
            .padding(.horizontal, Spacing.padding3)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.light)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                answer.checked = true
            }
        }
    }
}

struct FormMultipleSelectionAnswerView: View {

    @Binding var answer: FormAnswer

    var body: some View {
        FormRecursiveAnswerView(answer: $answer) {
            HStack(spacing: Spacing.padding1) {
                Text(answer.text)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)

                Spacer()

                Checkbox(isOn: $answer.checked ?? false)
            }
            .padding(.vertical, Spacing.padding2)
            .padding(.horizontal, Spacing.padding3)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.light)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                answer.checked?.toggle()
            }
        }
    }
}

struct FormAnswerView_Previews: PreviewProvider {

    static var previews: some View {
        PreviewHelper(
            answer: FormAnswer(
                id: "a1",
                type: .openEnded,
                text: "Answer 1",
                children: nil,
                input: nil,
                hint: nil,
                regex: nil,
                checked: nil
            )
        )

        PreviewHelper(
            answer: FormAnswer(
                id: "q1-a1",
                type: .openEnded,
                text: "Answer 1",
                children: [
                    FormAnswer(
                        id: "q1-a1-a1",
                        type: .selection,
                        text: "Child Answer 1",
                        children: nil,
                        input: nil,
                        hint: nil,
                        regex: nil,
                        checked: nil
                    ),
                    FormAnswer(
                        id: "q1-a1-a2",
                        type: .selection,
                        text: "Child Answer 2",
                        children: nil,
                        input: nil,
                        hint: nil,
                        regex: nil,
                        checked: nil
                    )
                ],
                input: nil,
                hint: nil,
                regex: nil,
                checked: true
            )
        )
    }

    struct PreviewHelper: View {

        @State var answer: FormAnswer

        var body: some View {
            VStack(spacing: Spacing.padding1) {
                FormOpenEndedAnswerView(answer: $answer)
                FormSingleSelectionAnswerView(answer: $answer)
                FormMultipleSelectionAnswerView(answer: $answer)
            }
            .padding()
        }
    }
}
