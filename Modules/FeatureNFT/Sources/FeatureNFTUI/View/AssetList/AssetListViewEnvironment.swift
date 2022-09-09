import Combine
import ComposableArchitecture
import FeatureNFTDomain
import Foundation
import UIKit

public struct AssetListViewEnvironment {

    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let assetProviderService: AssetProviderService
    public let pasteboard: UIPasteboard

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        pasteboard: UIPasteboard = .general,
        assetProviderService: AssetProviderService
    ) {
        self.mainQueue = mainQueue
        self.pasteboard = pasteboard
        self.assetProviderService = assetProviderService
    }
}
