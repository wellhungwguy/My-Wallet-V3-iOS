import Foundation

struct AssetListRequest: Encodable {
    let network: String
    let address: String
}

extension AssetListRequest {
    static func ethereum(address: String) -> AssetListRequest {
        .init(network: "ETH", address: address)
    }
}
