// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

struct FormSingleSelectionDropdownAnswersView: View {

    @Binding var answers: [FormAnswer]
    @State private var selectionPanelOpened: Bool = false

    var body: some View {
        VStack {
            let selectedAnswer = answers.first(where: { $0.checked == true })
            HStack(spacing: Spacing.padding1) {
                Text(selectedAnswer?.text ?? "")
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)

                Spacer()

                Icon.chevronDown
                    .frame(width: 24, height: 24)
                    .accentColor(.semantic.muted)
            }
            .padding(.vertical, Spacing.padding2)
            .padding(.horizontal, Spacing.padding3)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.light)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectionPanelOpened.toggle()
            }

            if let selectedAnswer = selectedAnswer,
               selectedAnswer.children?.isEmpty == false
            {
                if let index = answers.firstIndex(of: selectedAnswer) {
                    FormRecursiveAnswerView(answer: $answers[index]) {
                        EmptyView()
                    }
                }
            }
        }
        .sheet(isPresented: $selectionPanelOpened) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.padding1) {
                    let selectedIndex = answers.firstIndex(
                        where: { $0.checked == true }
                    )
                    ForEach($answers) { answer in
                        FormDropdownAnswerSelectionView(answer: answer.wrappedValue) {
                            if let index = selectedIndex {
                                answers[index].checked = false
                            }
                            answer.wrappedValue.checked = true
                            selectionPanelOpened.toggle()
                        }
                    }
                }
                .padding(Spacing.padding2)
            }
            .background(Color.semantic.background)
        }
    }
}

private struct FormDropdownAnswerSelectionView: View {

    let answer: FormAnswer
    let onSelection: () -> Void

    var body: some View {
        let isSelected = answer.checked == true
        HStack(spacing: Spacing.padding1) {
            Text(answer.text)
                .typography(.paragraph2)
                .multilineTextAlignment(.leading)

            Spacer()

            if isSelected {
                Icon.checkCircle
                    .frame(width: 16, height: 16)
                    .accentColor(.semantic.primary)
            }
        }
        .padding(Spacing.padding2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(isSelected ? Color.semantic.blueBG : Color.semantic.background)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelection()
        }
    }
}

struct FormSingleSelectionDropdownAnswersView_Previews: PreviewProvider {

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
                    type: .selection,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                )
            ]
        )

        PreviewHelper(
            answers: [
                FormAnswer(
                    id: "a1",
                    type: .selection,
                    text: "Answer 1",
                    children: [
                        FormAnswer(
                            id: "a1-a1",
                            type: .openEnded,
                            text: "Nested Question",
                            children: nil,
                            input: nil,
                            hint: "Provide info",
                            regex: nil,
                            checked: nil
                        )
                    ],
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: true
                ),
                FormAnswer(
                    id: "a2",
                    type: .selection,
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
            FormSingleSelectionDropdownAnswersView(answers: $answers)
                .padding()
        }
    }
}
