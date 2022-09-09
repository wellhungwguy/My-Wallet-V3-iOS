// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AssetCollection: Equatable {

    let name: String
    let collectionDescription: String
    let payoutAddress: String
    let shortDescription: String
    let slug: String
    let createdDate: String
    let externalURL: URL
    let featured: Bool
    let hidden: Bool
    let stats: [String: Int]

    public struct Social {
        let twitterUsername: String
        let instagramUsername: String
        let discordURL: URL
        let chatURL: URL

        public init(
            twitterUsername: String,
            instagramUsername: String,
            discordURL: URL,
            chatURL: URL
        ) {
            self.twitterUsername = twitterUsername
            self.instagramUsername = instagramUsername
            self.discordURL = discordURL
            self.chatURL = chatURL
        }
    }

    public struct Media {
        let imageURL: URL
        let bannerImageURL: URL
        let featuredImageURL: URL

        public init(
            imageURL: URL,
            bannerImageURL: URL,
            featuredImageURL: URL
        ) {
            self.imageURL = imageURL
            self.bannerImageURL = bannerImageURL
            self.featuredImageURL = featuredImageURL
        }
    }

    public init(
        name: String,
        collectionDescription: String,
        payoutAddress: String,
        shortDescription: String,
        slug: String,
        createdDate: String,
        externalURL: URL,
        featured: Bool,
        hidden: Bool,
        stats: [String: Int]
    ) {
        self.name = name
        self.collectionDescription = collectionDescription
        self.payoutAddress = payoutAddress
        self.shortDescription = shortDescription
        self.slug = slug
        self.createdDate = createdDate
        self.externalURL = externalURL
        self.featured = featured
        self.hidden = hidden
        self.stats = stats
    }
}
