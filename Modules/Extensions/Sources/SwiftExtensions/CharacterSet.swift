// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension CharacterSet {
    public func contains(_ character: Character) -> Bool {
        !character.unicodeScalars.contains(where: { !contains($0) })
    }
}
