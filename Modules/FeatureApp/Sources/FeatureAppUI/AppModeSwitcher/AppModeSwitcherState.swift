import BlockchainNamespace
import Combine
import MoneyKit
import ToolKit

public struct AppModeSwitcherState: Equatable {
    public var totalAccountBalance: String?
    public var defiAccountBalance: String?
    public var brokerageAccountBalance: String?
    let currentAppMode: AppMode?

    public init(
        totalAccountBalance: String?,
        defiAccountBalance: String?,
        brokerageAccountBalance: String?,
        currentAppMode: AppMode?
    ) {
        self.totalAccountBalance = totalAccountBalance
        self.defiAccountBalance = defiAccountBalance
        self.brokerageAccountBalance = brokerageAccountBalance
        self.currentAppMode = currentAppMode
    }
}
