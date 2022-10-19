// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import Foundation
import SwiftUI

struct FormRecursiveAnswerView<Content: View>: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration
    let content: () -> Content

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            content()

            if answer.checked == true, answer.children?.isEmpty == false {
                FormSingleSelectionAnswersView(
                    title: title,
                    answers: $answer.children ?? [],
                    showAnswersState: $showAnswerState,
                    fieldConfiguration: fieldConfiguration
                )
                .padding([.leading, .vertical], Spacing.padding2)
            }
        }
    }
}

struct FormOpenEndedAnswerView: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    @State var isFirstResponder: Bool = false
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            if let text = answer.text {
                Text(text)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)
            }

            Input(
                text: $answer.input ?? "",
                isFirstResponder: $isFirstResponder,
                placeholder: answer.hint,
                state: showAnswerState ? answer.inputState : .default,
                configuration: { textField in
                    let config = fieldConfiguration(answer)
                    textField.autocorrectionType = .init(type: config.textAutocorrectionType)
                }
            )
            .accessibilityIdentifier(answer.id)
        }
    }
}

struct FormSingleSelectionAnswerView: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
        FormRecursiveAnswerView(
            title: title,
            answer: $answer,
            showAnswerState: $showAnswerState,
            fieldConfiguration: fieldConfiguration
        ) {
            HStack(spacing: Spacing.padding1) {
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.body)
                }

                Spacer()

                Radio(isOn: $answer.checked ?? false)
            }
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.light)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                answer.checked = true
            }
            .accessibilityIdentifier(answer.id)
            .accessibilityElement(children: .contain)
        }
    }
}

struct FormMultipleSelectionAnswerView: View {

    let title: String
    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
        FormRecursiveAnswerView(
            title: title,
            answer: $answer,
            showAnswerState: $showAnswerState,
            fieldConfiguration: fieldConfiguration
        ) {
            HStack(spacing: Spacing.padding1) {
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.body)
                }

                Spacer()

                Checkbox(isOn: $answer.checked ?? false)
            }
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.light)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                answer.checked?.toggle()
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(answer.id)
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
            ),
            showAnswerState: false
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
            ),
            showAnswerState: false
        )
    }

    struct PreviewHelper: View {

        @State var answer: FormAnswer
        @State var showAnswerState: Bool

        var body: some View {
            VStack(spacing: Spacing.padding1) {
                FormOpenEndedAnswerView(
                    answer: $answer,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
                FormSingleSelectionAnswerView(
                    title: "Title",
                    answer: $answer,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
                FormMultipleSelectionAnswerView(
                    title: "Title",
                    answer: $answer,
                    showAnswerState: $showAnswerState,
                    fieldConfiguration: defaultFieldConfiguration
                )
            }
            .padding()
        }
    }
}

extension FormAnswer {
    var answerBackgroundStrokeColor: Color {
        switch isValid {
        case true:
            return .semantic.medium
        case false:
            return .semantic.error
        }
    }

    fileprivate var inputState: InputState {
        switch isValid {
        case true:
            return .default
        case false:
            return .error
        }
    }
}
