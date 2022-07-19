// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import PlatformUIKit
import RxDataSources

enum PortfolioCellType: Hashable {
    case announcement(AnnouncementCardViewModel)
    case withdrawalLock
    case fiatCustodialBalances(FiatBalanceCollectionViewPresenter)
    case totalBalance(TotalBalanceViewPresenter)
    case crypto(HistoricalBalanceCellPresenter)
    case cryptoSkeleton(Int)
    case emptyState

    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }

    static func == (_ lhs: PortfolioCellType, _ rhs: PortfolioCellType) -> Bool {
        lhs.identity == rhs.identity
    }
}

extension PortfolioCellType: IdentifiableType {
    var identity: AnyHashable {
        switch self {
        case .announcement(let model):
            let type = model.type
                .flatMap { "\($0)" } ?? ""
            return "announcement-\(type)"
        case .withdrawalLock:
            return "withdrawalLock"
        case .cryptoSkeleton(let id):
            return "cryptoSkeleton-\(id)"
        case .crypto(let presenter):
            return "crypto-\(presenter.cryptoCurrency.code)"
        case .fiatCustodialBalances:
            return "fiatCustodialBalances"
        case .totalBalance:
            return "totalBalance"
        case .emptyState:
            return "emptyState"
        }
    }
}
