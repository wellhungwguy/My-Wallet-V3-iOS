import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

private typealias LocalizedString = LocalizationConstants.UserDeletion.ResultScreen

public struct DeletionResultView: View {
    let store: Store<DeletionResultState, DeletionResultAction>
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewStore: ViewStore<DeletionResultState, DeletionResultAction>

    public init(store: Store<DeletionResultState, DeletionResultAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            contentView
                .padding()
        }
        .whiteNavigationBarStyle()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
    }

    private var contentView: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer()

            if viewStore.success {
                ImageAsset.Deletion.deletionSuceeded

                Text(LocalizedString.success.message)
                    .typography(.title2)
                    .foregroundColor(.textTitle)
                    .frame(maxWidth: 340)
                    .multilineTextAlignment(.center)
            } else {
                ImageAsset.Deletion.deletionFailed

                Text(LocalizedString.failure.message)
                    .typography(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textTitle)

                HStack {
                    Spacer()
                        .frame(width: 24)

                    Icon.information
                        .color(.semantic.warning)
                        .frame(width: 24, height: 24)

                    Text(LocalizedString.failure.reason)
                        .typography(.body2)
                        .foregroundColor(.textTitle)
                        .padding(16)

                    Spacer()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.dividerLineLight)
                )
            }

            Spacer()

            PrimaryButton(
                title: LocalizedString.mainCTA,
                action: {
                    guard viewStore.success else {
                        viewStore.send(.dismissFlow)
                        return
                    }
                    viewStore.send(.logoutAndForgetWallet)
                }
            )
        }
    }
}
