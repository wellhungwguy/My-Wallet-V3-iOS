// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import FeatureDashboardDomain
import SwiftUI

struct DashboardAssetRowView: View {
    let store: StoreOf<DashboardAssetRow>

    init(store: StoreOf<DashboardAssetRow>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
                SimpleBalanceRow(
                    leadingTitle: viewStore.asset.currency.name,
                    trailingTitle: viewStore.asset.fiatBalance?.quote.toDisplayString(includeSymbol: true),
                    trailingDescription: viewStore.trailingDescriptionString,
                    trailingDescriptionColor: viewStore.trailingDescriptionColor,
                    action: {
                        viewStore.send(.onAssetTapped)
                    },
                    leading: {
                        AsyncMedia(
                            url: viewStore.asset.currency.cryptoCurrency?.assetModel.logoPngUrl
                        )
                        .resizingMode(.aspectFit)
                        .frame(width: 24.pt, height: 24.pt)
                    }
                )

                if viewStore.isLastRow == false {
                    Divider()
                        .foregroundColor(.WalletSemantic.light)
                }
            }
        }
    }
}

struct DashboardAssetRowView_Previews: PreviewProvider {
    static var previews: some View {
        let assetBalanceInfo = AssetBalanceInfo(
            cryptoBalance: .one(currency: .USD),
            fiatBalance: nil,
            currency: .crypto(.bitcoin),
            delta: nil
        )
        DashboardAssetRowView(store: .init(initialState: .init(
            type: .custodial,
            isLastRow: false,
            asset: assetBalanceInfo
        ), reducer: DashboardAssetRow(app: resolve())))
    }
}
