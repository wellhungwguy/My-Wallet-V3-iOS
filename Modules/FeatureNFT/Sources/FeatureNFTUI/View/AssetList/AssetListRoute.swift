import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import SwiftUI
import ToolKit

public enum AssetListRoute: NavigationRoute {

    case details
    case viewNFTOnWeb(URL)

    @ViewBuilder
    public func destination(
        in store: Store<AssetListViewState, AssetListViewAction>
    ) -> some View {
        switch self {
        case .details:
            IfLetStore(
                store.scope(
                    state: \.assetDetailViewState,
                    action: AssetListViewAction.assetDetailsViewAction
                ),
                then: AssetDetailView.init(store:)
            )
        case .viewNFTOnWeb(let url):
            WebView(url: url)
        }
    }
}
