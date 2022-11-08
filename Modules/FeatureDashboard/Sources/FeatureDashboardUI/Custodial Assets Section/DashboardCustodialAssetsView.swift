// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct DashboardCustodialAssetsView: View {
    @ObservedObject var viewStore: ViewStoreOf<DashboardCustodialAssetsSection>
    let store: StoreOf<DashboardCustodialAssetsSection>

    public init(store: StoreOf<DashboardCustodialAssetsSection>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader
                    .padding(.vertical, Spacing.padding1)
                custodialAssetsSection
                fiatAssetSection
            }
            .task {
                await viewStore.send(.onAppear).finish()
            }
            .padding(.horizontal, Spacing.padding2)
        })
    }

    var fiatAssetSection: some View {
        SingleBalanceRow(
            leadingTitle: viewStore.fiatAssetInfo?.currency.name ?? "",
            trailingTitle: viewStore.fiatAssetInfo?.cryptoBalance.toDisplayString(includeSymbol: true),
            leading: {
                viewStore.fiatAssetInfo?.currency.fiatCurrency?
                    .image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .background(Color.WalletSemantic.fiatGreen)
                    .cornerRadius(6, corners: .allCorners)
            }
        )
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, Spacing.padding2)
    }

    var custodialAssetsSection: some View {
        VStack(spacing: 0) {
            if let assets = viewStore.custodialAssetsInfo {
                ForEach(assets) { info in
                    SimpleBalanceRow(
                        leadingTitle: info.currency.name,
                        trailingTitle: info.fiatBalance?.quote.toDisplayString(includeSymbol: true),
                        trailingDescription: info.priceChangeString,
                        trailingDescriptionColor: info.priceChangeColor,
                        action: {
                            viewStore.send(.onAssetTapped(info))
                        },
                        leading: {
                            AsyncMedia(
                                url: info.currency.cryptoCurrency?.assetModel.logoPngUrl
                            )
                            .resizingMode(.aspectFit)
                            .frame(width: 24.pt, height: 24.pt)
                        }
                    )

                    if info.id != viewStore.custodialAssetsInfo?.last?.id {
                        Divider()
                            .foregroundColor(.WalletSemantic.light)
                    }
                }
            } else {
                loadingSection
            }
        }
        .cornerRadius(16, corners: .allCorners)
    }

    private var loadingSection: some View {
        Group {
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
        }
    }

    var sectionHeader: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            HStack {
                Text(LocalizationConstants.MultiApp.Dashboard.allAssetsLabel)
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                Spacer()
                Button {
                    viewStore.send(.onAllAssetsTapped)
                } label: {
                    Text(LocalizationConstants.MultiApp.Dashboard.seeAllLabel)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.primary)
                }
            }
        })
    }
}
