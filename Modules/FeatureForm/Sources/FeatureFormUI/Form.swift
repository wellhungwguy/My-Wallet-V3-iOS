// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import SwiftUI

public struct PrimaryForm: View {

    @Binding private var form: FeatureFormDomain.Form
    private let submitActionTitle: String
    private let submitActionLoading: Bool
    private let submitAction: () -> Void

    public init(
        form: Binding<FeatureFormDomain.Form>,
        submitActionTitle: String,
        submitActionLoading: Bool,
        submitAction: @escaping () -> Void
    ) {
        _form = form
        self.submitActionTitle = submitActionTitle
        self.submitActionLoading = submitActionLoading
        self.submitAction = submitAction
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.padding4) {

                if let header = form.header {
                    VStack {
                        Icon.user
                            .frame(width: 32.pt, height: 32.pt)
                        Text(header.title)
                            .typography(.title2)
                        Text(header.description)
                            .typography(.paragraph1)
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(.semantic.title)
                }

                ForEach($form.nodes) { question in
                    FormQuestionView(question: question)
                }

                PrimaryButton(
                    title: submitActionTitle,
                    isLoading: submitActionLoading,
                    action: submitAction
                )
                .disabled(!form.nodes.isValidForm)
            }
            .padding(Spacing.padding3)
            .background(Color.semantic.background)
        }
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
                submitAction: {}
            )
        }
    }
}
