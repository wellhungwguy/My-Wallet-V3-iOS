// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AddressResult: Equatable {
    case abandoned
    case saved(Address)
}
