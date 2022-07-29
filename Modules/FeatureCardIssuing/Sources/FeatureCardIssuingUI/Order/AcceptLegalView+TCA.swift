// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

enum AcceptLegalAction: Equatable, BindableAction {

    case accept
    case acceptResponse(Result<[LegalItem], NabuNetworkError>)
    case binding(BindingAction<AcceptLegalState>)
    case close
    case next
    case onAppear
}

struct AcceptLegalState: Equatable {

    var viewed: Set<String> = []
    var accepted: LoadingState<Bool> = .loaded(next: false)
    var items: [LegalItem]
    var current: LegalItem?
    var hasNext: Bool = false
    var error: NabuNetworkError?

    init(
        items: [LegalItem]
    ) {
        self.items = items
        current = items.first
        hasNext = items.count > 1
    }
}

struct AcceptLegalEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let legalService: LegalServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        legalService: LegalServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.legalService = legalService
    }
}

let acceptLegalReducer = Reducer<
    AcceptLegalState,
    AcceptLegalAction,
    AcceptLegalEnvironment
> { state, action, env in
    switch action {
    case .binding:
        return .none
    case .accept:
        state.accepted = .loading
        return env.legalService
            .setAccepted(legalItems: state.items)
            .receive(on: env.mainQueue)
            .catchToEffect(AcceptLegalAction.acceptResponse)
    case .acceptResponse(.success(let items)):
        state.accepted = .loaded(next: true)
        state.items = items
        return Effect(value: AcceptLegalAction.close)
    case .acceptResponse(.failure(let error)):
        state.accepted = .loaded(next: false)
        state.error = error
        return .none
    case .next:
        guard let current = state.current else {
            state.current = state.items.first
            return .none
        }
        state.viewed.insert(current.name)
        let availableItems = state.items.filter {
            !state.viewed.contains($0.name)
        }
        state.current = availableItems.first
        state.hasNext = availableItems.count > 1
        return .none
    case .close:
        return .none
    case .onAppear:
        state.viewed = []
        state.current = state.items.first
        state.hasNext = state.items.count > 1
        return .none
    }
}
.binding()
