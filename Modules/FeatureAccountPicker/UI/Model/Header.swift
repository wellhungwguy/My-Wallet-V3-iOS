// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI

public enum Header: Equatable {
    case none
    case simple(subtitle: String)
    case normal(title: String, subtitle: String, image: Image?, tableTitle: String?)
}
