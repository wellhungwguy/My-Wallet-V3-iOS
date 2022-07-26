// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct AssetPageResponse {
    public let next: String?
    public let assets: [Asset]

    public init(
        next: String?,
        assets: [Asset]
    ) {
        self.next = next
        self.assets = assets
    }
}

public struct Asset: Equatable, Identifiable {
    public var id: String {
        identifier
    }

    public var url: URL {
        let network = network.openseaDescription
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opensea.io"
        components.path = "/assets/\(network)/\(contractId)/\(tokenID)"
        return components.url ?? "https://www.opensea.io"
    }

    public var creatorDisplayValue: String {
        if creator.contains("0x") {
            // Abridge the address to match OpenSea's UX
            return creator
                .dropFirst(2)
                .prefix(6)
                .uppercased()
        } else {
            return creator
        }
    }

    public let name: String
    public let creator: String
    public let tokenID: String
    public let nftDescription: String
    public let identifier: String
    public let contractId: String
    public let collection: Collection
    public let media: Media
    public let network: Network
    public let traits: [Trait]

    public enum Network {
        case ethereum
        case polygon

        var openseaDescription: String {
            switch self {
            case .ethereum:
                return "ethereum"
            case .polygon:
                return "matic"
            }
        }
    }

    public struct Trait: Equatable, Identifiable {

        public var id: String {
            "\(type).\(description)"
        }

        public let type: String
        public let description: String

        public init(type: String, description: String) {
            self.type = type
            self.description = description
        }
    }

    public struct Collection: Equatable {
        public let name: String
        public let isVerified: Bool
        public let bannerImageURL: String?
        public let collectionImageUrl: String?
        public let collectionDescription: String?

        public init(
            name: String,
            isVerified: Bool,
            bannerImageURL: String? = nil,
            collectionImageURL: String? = nil,
            collectionDescription: String? = nil
        ) {
            self.name = name
            self.isVerified = isVerified
            self.bannerImageURL = bannerImageURL
            collectionImageUrl = collectionImageURL
            self.collectionDescription = collectionDescription
        }
    }

    public struct Media: Equatable {

        public let backgroundColor: String?
        public let bannerImageURL: String?
        public let animationURL: String?
        public let collectionImageUrl: String?
        public let imageOriginalURL: String?
        public let imagePreviewURL: String
        public let imageThumbnailURL: String
        public let imageURL: String?

        public init(
            backgroundColor: String?,
            animationURL: String?,
            bannerImageURL: String?,
            collectionImageUrl: String?,
            imageOriginalURL: String?,
            imagePreviewURL: String,
            imageThumbnailURL: String,
            imageURL: String?
        ) {
            self.backgroundColor = backgroundColor
            self.animationURL = animationURL
            self.collectionImageUrl = collectionImageUrl
            self.bannerImageURL = bannerImageURL
            self.imageOriginalURL = imageOriginalURL
            self.imagePreviewURL = imagePreviewURL
            self.imageThumbnailURL = imageThumbnailURL
            self.imageURL = imageURL
        }
    }

    public init(
        name: String,
        creator: String,
        tokenID: String,
        nftDescription: String,
        identifier: String,
        contractId: String,
        collection: Collection,
        network: Network,
        media: Media,
        traits: [Trait]
    ) {
        self.name = name
        self.collection = collection
        self.creator = creator
        self.tokenID = tokenID
        self.network = network
        self.contractId = contractId
        self.nftDescription = nftDescription
        self.identifier = identifier
        self.media = media
        self.traits = traits
    }
}
