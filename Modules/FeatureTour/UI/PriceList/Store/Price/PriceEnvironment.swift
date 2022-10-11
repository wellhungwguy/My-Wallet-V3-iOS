// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers
import DIKit
import Foundation
import PlatformKit

struct PriceEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let priceRepository: PriceRepositoryAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        priceRepository: PriceRepositoryAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.priceRepository = priceRepository
    }
}
