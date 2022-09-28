// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import Foundation
import SwiftUI

struct FormRecursiveAnswerView<Content: View>: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    let content: () -> Content

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            content()

            if answer.checked == true, answer.children?.isEmpty == false {
                FormSingleSelectionAnswersView(
                    answers: $answer.children ?? [],
                    showAnswersState: $showAnswerState
                )
                .padding([.leading, .vertical], Spacing.padding2)
            }
        }
    }
}

struct FormDateAnswerView: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool

    private var minDate: Date {
        if let minValue = answer.validation?.metadata?[.minValue], let timeInterval = TimeInterval(minValue) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return Date.distantPast
    }

    private var maxDate: Date {
        if let maxValue = answer.validation?.metadata?[.maxValue], let timeInterval = TimeInterval(maxValue) {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return Date.distantFuture
    }

    var body: some View {
        ZStack {
            DatePicker(
                selection: Binding(
                    get: {
                        guard let input = answer.input, let timeInterval = TimeInterval(input) else {
                            return Date()
                        }
                        return Date(timeIntervalSince1970: timeInterval)
                    },
                    set: {
                        answer.input = String($0.timeIntervalSince1970)
                    }
                ),
                in: minDate...maxDate,
                displayedComponents: .date,
                label: EmptyView.init
            )
            .labelsHidden()
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.padding1)
        .padding(.vertical, Spacing.padding1)
        .frame(minHeight: 24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .fill(Color.semantic.background)

                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(
                        showAnswerState
                        ? answer.answerBackgroundStrokeColor
                        : .semantic.medium
                    )
            }
        )
    }
}

struct FormOpenEndedAnswerView: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool
    @State var isFirstResponder: Bool = false

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
                state: showAnswerState ? answer.inputState : .default
            )
            .accessibilityIdentifier(answer.id)
        }
    }
}

struct FormSingleSelectionAnswerView: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool

    var body: some View {
        FormRecursiveAnswerView(answer: $answer, showAnswerState: $showAnswerState) {
            HStack(spacing: Spacing.padding1) {
                if let text = answer.text {
                    Text(text)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.body)
                }

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
            .accessibilityIdentifier(answer.id)
            .accessibilityElement(children: .contain)
        }
    }
}

struct FormMultipleSelectionAnswerView: View {

    @Binding var answer: FormAnswer
    @Binding var showAnswerState: Bool

    var body: some View {
        FormRecursiveAnswerView(
            answer: $answer,
            showAnswerState: $showAnswerState
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
                FormOpenEndedAnswerView(answer: $answer, showAnswerState: $showAnswerState)
                FormSingleSelectionAnswerView(answer: $answer, showAnswerState: $showAnswerState)
                FormMultipleSelectionAnswerView(answer: $answer, showAnswerState: $showAnswerState)
            }
            .padding()
        }
    }
}

extension FormAnswer {
    fileprivate var answerBackgroundStrokeColor: Color {
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
