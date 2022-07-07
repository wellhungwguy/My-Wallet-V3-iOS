// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import SwiftUI

extension FiatCurrency {

    public var image: Image {
        logoResource
            .image ?? .init("icon-usd", bundle: .platformUIKit)
    }

    public var logoResource: ImageResource {
        switch self {
        case .GBP:
            return .local(name: "icon-gbp", bundle: .platformUIKit)
        case .EUR:
            return .local(name: "icon-eur", bundle: .platformUIKit)
        case .USD:
            return .local(name: "icon-usd", bundle: .platformUIKit)
        case .ARS, .BRL:
            return .local(name: "icon-usd", bundle: .platformUIKit)
        default:
            fatalError("Currency \(code) does not have a logo image")
        }
    }

    public var brandColor: UIColor { .fiat }
}
