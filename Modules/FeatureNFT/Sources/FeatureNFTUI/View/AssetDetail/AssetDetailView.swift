// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureNFTData
import FeatureNFTDomain
import Localization
import SwiftUI
import UIComponentsKit

public struct AssetDetailView: View {

    private typealias LocalizationId = LocalizationConstants.NFT.Screen.Detail

    @State private var webViewPresented = false
    @Environment(\.presentationMode) private var presentationMode
    private let url: URL
    private let store: Store<AssetDetailViewState, AssetDetailViewAction>

    public init(store: Store<AssetDetailViewState, AssetDetailViewAction>) {
        self.store = store
        url = ViewStore(store).asset.url
    }

    public var body: some View {
        content
    }

    private var content: some View {
        WithViewStore(store) { viewStore in
            let asset = viewStore.asset
            VStack {
                ZStack {
                    GeometryReader { proxy in
                        ScrollView {
                            Capsule()
                                .fill(Color.semantic.dark)
                                .frame(width: 32.pt, height: 4.pt)
                                .foregroundColor(.semantic.muted)
                                .padding([.top], Spacing.padding1)
                            VStack(spacing: 8.0) {
                                VStack(spacing: 32) {
                                    AssetMotionView(url: asset.media.imageURL ?? asset.media.imagePreviewURL)
                                    AssetDescriptionView(asset: asset)
                                }

                                TraitGridView(asset: asset)
                                    .padding()
                            }
                            .padding(.bottom, 96.pt)
                        }
                        .frame(minHeight: proxy.size.height)
                    }
                    VStack {
                        Spacer()
                        DefaultButton(title: LocalizationId.viewOnWeb) {
                            webViewPresented.toggle()
                        }
                        .padding(.top, 24.pt)
                        .padding(.bottom, 40.pt)
                        .padding([.leading, .trailing], 16.pt)
                        .background(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        .white,
                                        .white,
                                        .white.opacity(0.2),
                                        .white.opacity(0.01)
                                    ]
                                ),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $webViewPresented, content: {
            webView
        })
    }

    @ViewBuilder var webView: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                WebView(url: url)
                    .primaryNavigation(
                        title: viewStore.asset.name,
                        trailing: {
                            IconButton(icon: .closev2.circle()) {
                                webViewPresented = false
                            }
                            .frame(width: 24.pt, height: 24.pt)
                        }
                    )
            }
        }
    }

    @ViewBuilder func dismiss() -> some View {
        IconButton(icon: .closev2.circle()) {
            presentationMode.wrappedValue.dismiss()
        }
        .frame(width: 24.pt, height: 24.pt)
    }

    private struct AssetMotionView: View {
        let url: String

        var body: some View {
            ZStack {
                AsyncMedia(
                    url: URL(string: url)
                )
                .cornerRadius(64)
                .blur(radius: 30)
                .opacity(0.9)
                AssetViewRepresentable(
                    imageURL: URL(
                        string: url
                    ),
                    size: 300
                )
            }
            .frame(width: 300, height: 300)
            .padding(.top, 40.pt)
        }
    }

    private struct TraitGridView: View {

        let columns = [
            GridItem(.flexible(minimum: 100.0, maximum: 300)),
            GridItem(.flexible(minimum: 100.0, maximum: 300))
        ]

        private let asset: Asset

        init(asset: Asset) {
            self.asset = asset
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(LocalizationId.properties)
                    .typography(.body2)
                    .foregroundColor(asset.traits.isEmpty ? .clear : .semantic.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyVGrid(columns: columns, spacing: 16.0) {
                    ForEach(asset.traits) {
                        TraitView(trait: $0)
                    }
                }
            }
        }
    }

    private struct AssetDescriptionView: View {

        @State private var isExpanded: Bool = false

        let asset: Asset

        var body: some View {
            VStack(alignment: .leading, spacing: 12.0) {

                Text(asset.name)
                    .typography(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8.0) {
                    if let value = asset.collection.collectionImageUrl {
                        ZStack(alignment: .topTrailing) {
                            AsyncMedia(url: URL(string: value))
                                .frame(width: 45, height: 45)
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                                .shadow(
                                    color: .black.opacity(0.2),
                                    radius: 2.0,
                                    x: 0.0,
                                    y: 1.0
                                )
                            if asset.collection.isVerified {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20.0, height: 20.0)
                                    .overlay(
                                        Icon.verified
                                            .frame(width: 16.0, height: 16.0)
                                            .foregroundColor(Color.semantic.primary)
                                    )
                                    .offset(x: 8.0, y: -8.0)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(asset.creatorDisplayValue)
                            .typography(.body2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(LocalizationId.creator)
                            .typography(.caption1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 45.0, alignment: .top)
                }

                if let collectionDescription = asset.collection.collectionDescription {
                    if collectionDescription != asset.nftDescription {
                        ExpandableRichTextBlock(
                            title: "\(LocalizationId.about) \(asset.collection.name)",
                            text: collectionDescription
                        )
                    }
                }
                if !asset.nftDescription.isEmpty {
                    ExpandableRichTextBlock(
                        title: LocalizationId.descripton,
                        text: asset.nftDescription
                    )
                }
            }
            .padding([.leading, .trailing], 16.0)
            .frame(maxWidth: .infinity)
        }
    }

    private struct ExpandableRichTextBlock: View {

        @State private var isExpanded: Bool = false

        private let title: String
        private let text: String

        init(
            title: String,
            text: String
        ) {
            self.title = title
            self.text = text
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 4.0) {
                Text(title)
                    .typography(.body2)
                    .foregroundColor(.semantic.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(rich: text)
                    .lineLimit(isExpanded ? nil : 3)
                    .typography(.paragraph1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.semantic.title)
                if !isExpanded, text.count > 160 {
                    Button(
                        action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        },
                        label: {
                            Text(LocalizationId.readMore)
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.primary)
                        }
                    )
                }
            }
            .padding(16.0)
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .stroke(Color.semantic.light, lineWidth: 1)
            )
        }
    }

    private struct TraitView: View {

        let trait: Asset.Trait

        var body: some View {
            VStack(alignment: .leading, spacing: 4.pt) {
                Text(trait.type)
                    .typography(.micro)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.semantic.primaryMuted)
                    .padding(.trailing)
                Text(trait.description)
                    .typography(.paragraph2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.semantic.primary)
            }
            .padding([.leading, .top, .bottom], 8.0)
            .background(Color.semantic.light)
            .overlay(
                RoundedRectangle(
                    cornerRadius: 8.0
                )
                .stroke(Color.semantic.medium, lineWidth: 1.0)
            )
        }
    }
}
