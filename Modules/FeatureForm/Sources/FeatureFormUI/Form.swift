// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

public enum PrimaryFormSubmitButtonMode {
    case onlyEnabledWhenAllAnswersValid
    case submitButtonAlwaysEnabled // open ended answers are validated and shown in red if not valid
}

public typealias PrimaryFormFieldConfiguration = (FormAnswer) -> FieldConfiguation
public let defaultFieldConfiguration: PrimaryFormFieldConfiguration = { _ in .init() }

public struct PrimaryForm<Header: View>: View {

    @Binding private var form: FeatureFormDomain.Form
    @State private var showAnswersState: Bool = false
    private let submitActionTitle: String
    private let submitActionLoading: Bool
    private let submitAction: () -> Void
    private let submitButtonMode: PrimaryFormSubmitButtonMode
    private let headerIcon: () -> Header
    private let fieldConfiguration: PrimaryFormFieldConfiguration

    public init(
        form: Binding<FeatureFormDomain.Form>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void,
        submitButtonMode: PrimaryFormSubmitButtonMode = .onlyEnabledWhenAllAnswersValid,
        fieldConfiguration: @escaping PrimaryFormFieldConfiguration = defaultFieldConfiguration,
        @ViewBuilder headerIcon: @escaping () -> Header
    ) {
        _form = form
        self.submitActionTitle = submitActionTitle
        self.submitActionLoading = submitActionLoading
        self.submitAction = submitAction
        self.submitButtonMode = submitButtonMode
        self.fieldConfiguration = fieldConfiguration
        self.headerIcon = headerIcon
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.padding4) {

                if let header = form.header {
                    VStack(spacing: Spacing.padding3) {
                        headerIcon()
                        if let title = header.title, title.isNotEmpty {
                            Text(title)
                                .typography(.title2)
                        }
                        if let description = header.description, description.isNotEmpty {
                            Text(description)
                                .typography(.paragraph1)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(.semantic.title)
                }

                ForEach($form.nodes) { question in
                    FormQuestionView(
                        question: question,
                        showAnswersState: $showAnswersState,
                        fieldConfiguration: fieldConfiguration
                    )
                }

                let isSubmitButtonDisabled: Bool = {
                    switch submitButtonMode {
                    case .onlyEnabledWhenAllAnswersValid:
                        return !form.nodes.isValidForm
                    case .submitButtonAlwaysEnabled:
                        return false
                    }
                }()
                PrimaryButton(
                    title: submitActionTitle,
                    isLoading: submitActionLoading,
                    action: {
                        switch submitButtonMode {
                        case .onlyEnabledWhenAllAnswersValid:
                            submitAction()
                        case .submitButtonAlwaysEnabled:
                            showAnswersState = true
                            if form.nodes.isValidForm {
                                submitAction()
                            }
                        }
                    }
                )
                .disabled(isSubmitButtonDisabled)
            }
            .padding(Spacing.padding3)
            .background(Color.semantic.background)
            .contentShape(Rectangle())
            .onTapGesture {
                stopEditing()
            }
        }
    }
}

#if canImport(UIKit)
extension View {

    func stopEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#else
extension View {

    func stopEditing() {
        // out of luck
    }
}
#endif

extension PrimaryForm where Header == EmptyView {

    public init(
        form: Binding<FeatureFormDomain.Form>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void
    ) {
        self.init(
            form: form,
            submitActionTitle: submitActionTitle,
            submitActionLoading: submitActionLoading,
            submitAction: submitAction,
            headerIcon: EmptyView.init
        )
    }
}

struct PrimaryForm_Previews: PreviewProvider {

    static var previews: some View {
        let jsonData = formPreviewJSON.data(using: .utf8)!
        // swiftlint:disable:next force_try
        let formRawData = try! JSONDecoder().decode(FeatureFormDomain.Form.self, from: jsonData)
        PreviewHelper(form: formRawData)
    }

    struct PreviewHelper: View {

        @State var form: FeatureFormDomain.Form

        var body: some View {
            PrimaryForm(
                form: $form,
                submitActionTitle: "Next",
                submitActionLoading: false,
                submitAction: {},
                headerIcon: {}
            )
        }
    }
}
