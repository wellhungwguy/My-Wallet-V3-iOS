// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

// swiftlint:disable all

// MARK: Groups

extension LocalizationConstants {
    public enum NFT {
        public enum Screen {
            public enum List {}
            public enum Empty {}
            public enum Detail {}
        }
    }
}

// MARK: - AssetListView

extension LocalizationConstants.NFT.Screen.List {
    public static let fetchingYourNFTs = NSLocalizedString(
        "Fetching Your NFTs",
        comment: ""
    )
}

extension LocalizationConstants.NFT.Screen.Empty {
    public static let headline = NSLocalizedString(
        "To get started, transfer your NFTs",
        comment: ""
    )
    public static let subheadline = NSLocalizedString(
        "Send from any wallet, or buy from a marketplace!",
        comment: ""
    )
    public static let copyEthAddress = NSLocalizedString(
        "Copy Ethereum Address",
        comment: ""
    )
    public static let copied = NSLocalizedString(
        "Copied!",
        comment: ""
    )
}

// MARK: - AssetDetailView

extension LocalizationConstants.NFT.Screen.Detail {

    public static let viewOnWeb = NSLocalizedString(
        "View on Web",
        comment: ""
    )

    public static let properties = NSLocalizedString(
        "Properties",
        comment: ""
    )

    public static let creator = NSLocalizedString("Creator", comment: "")

    public static let about = NSLocalizedString("About", comment: "")

    public static let descripton = NSLocalizedString("Description", comment: "")

    public static let readMore = NSLocalizedString("Read More", comment: "")
}
