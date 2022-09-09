// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import BigInt
import PlatformKit
import ToolKit

final class PricesInterpolator {

    private let prices: [OrderPriceTier]

    init(prices: [OrderPriceTier]) {
        self.prices = prices
    }

    func rate(amount: BigInt) -> BigInt {
        if let base = prices.first?.data, amount < base.volume {
            return base.price
        }
        let tier = prices
            .lazy
            .map(\.data)
            .adjacentPairs()
            .filter { tier, next in
                tier.volume < amount && amount <= next.volume
            }
            .map { tier, next in
                LinearInterpolator
                    .interpolate(
                        x: [tier.volume, next.volume],
                        y: [tier.price, next.price],
                        xi: amount
                    )
            }.first

        return tier
            ?? prices.last.flatMap(\.price.bigInt)
            ?? .zero
    }
}

extension OrderPriceTier {

    // swiftlint:disable:next large_tuple
    fileprivate var data: (volume: BigInt, price: BigInt, margin: (price: BigInt, ())) {
        (
            volume: volume.bigInt,
            price: price.bigInt,
            margin: (
                price: marginPrice.bigInt, ()
            )
        )
    }
}

extension String {

    fileprivate var bigInt: BigInt! {
        BigInt(self)
    }
}
