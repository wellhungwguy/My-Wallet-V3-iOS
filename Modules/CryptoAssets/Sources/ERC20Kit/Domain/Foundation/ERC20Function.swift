// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum ERC20Function: Equatable {
    private enum Identifier: String {
        case transfer = "a9059cbb"
    }

    case transfer(to: String, amount: String)

    init?(data: String?) {
        guard let tuple = ERC20Function.extractFunction(from: data)
        else { return nil }
        self.init(identifier: tuple.id, data: tuple.data)
    }

    private init?(identifier: String, data: String) {
        switch Identifier(rawValue: identifier) {
        case .transfer:
            self = ERC20Function.buildTransfer(data: data)
        case nil:
            return nil
        }
    }

    private static func extractFunction(from data: String?) -> (id: String, data: String)? {
        guard let data else { return nil }
        if data.hasPrefix("0x") {
            let start = data.range(of: "0x")!.upperBound
            let newValue = data[start..<data.endIndex]
            return extractFunction(from: String(newValue))
        }
        guard data.count >= 8 else { return nil }
        let functionEnd = data.index(data.startIndex, offsetBy: 8)
        return (String(data[data.startIndex..<functionEnd]), String(data[functionEnd..<data.endIndex]))
    }

    private static func buildTransfer(data: String) -> ERC20Function {
        func extractData() -> (to: String, amount: String) {
            guard data.count >= 128 else { return ("", "") }
            let addressStart = data.index(data.startIndex, offsetBy: 24)
            let addressEnd = data.index(data.startIndex, offsetBy: 64)
            let amountEnd = data.index(data.startIndex, offsetBy: 128)
            return (
                to: String(data[addressStart..<addressEnd]),
                amount: String(data[addressEnd..<amountEnd])
            )
        }
        let result = extractData()
        return .transfer(to: result.to, amount: result.amount)
    }
}
