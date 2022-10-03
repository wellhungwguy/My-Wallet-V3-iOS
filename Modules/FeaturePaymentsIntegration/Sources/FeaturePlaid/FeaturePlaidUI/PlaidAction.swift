// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Errors
import FeaturePlaidDomain

public enum PlaidAction: Equatable {
    case onAppear
    case startLinkingNewBank
    case getLinkTokenForExistingAccount(String)
    case getLinkTokenResponse(LinkAccountInfo)
    case waitingForAccountLinkResult
    case waitForActivation(String)
    case update(PlaidAccountAttributes)
    case updateSourceSelection
    case finished(success: Bool)
    case finishedWithError(NabuError?)
}
