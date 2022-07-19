// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import Localization
import MoneyKit
import SwiftUI

// MARK: State

public struct PrefillButtonsState: Equatable {
    var baseValue: FiatValue?
    var maxLimit: FiatValue?

    var suggestedValues: [FiatValue] {
        [baseMultipliedBy(1), baseMultipliedBy(2), baseMultipliedBy(4)].compactMap { $0 }
    }

    private func baseMultipliedBy(_ by: BigInt) -> FiatValue? {
        guard let baseValue = baseValue, let maxLimit = maxLimit else {
            return nil
        }
        let value = FiatValue(
            amount: baseValue.amount * by,
            currency: baseValue.currency
        )
        return (try? value < maxLimit) == true
            ? value
            : nil
    }

    public init(
        baseValue: FiatValue? = nil,
        maxLimit: FiatValue? = nil
    ) {
        self.baseValue = baseValue
        self.maxLimit = maxLimit
    }
}

// MARK: - Actions

public enum PrefillButtonsAction: Equatable {
    case onAppear
    case updateBaseValue(FiatValue)
    case updateMaxLimit(FiatValue)
    case select(FiatValue)
}

// MARK: - Environment

public struct PrefillButtonsEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let lastPurchasePublisher: AnyPublisher<FiatValue, Never>
    let maxLimitPublisher: AnyPublisher<FiatValue, Never>
    let onValueSelected: (FiatValue) -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        lastPurchasePublisher: AnyPublisher<FiatValue, Never>,
        maxLimitPublisher: AnyPublisher<FiatValue, Never>,
        onValueSelected: @escaping (FiatValue) -> Void
    ) {
        self.mainQueue = mainQueue
        self.lastPurchasePublisher = lastPurchasePublisher
        self.maxLimitPublisher = maxLimitPublisher
        self.onValueSelected = onValueSelected
    }

    static var preview: Self {
        PrefillButtonsEnvironment(
            lastPurchasePublisher: .empty(),
            maxLimitPublisher: .empty(),
            onValueSelected: { _ in }
        )
    }
}

// MARK: - Reducer

public let prefillButtonsReducer = Reducer<
    PrefillButtonsState,
    PrefillButtonsAction,
    PrefillButtonsEnvironment
> { state, action, environment in
    switch action {
    case .onAppear:
        return .merge(
            environment.lastPurchasePublisher
                .map(\.rounded)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(PrefillButtonsAction.updateBaseValue),

            environment.maxLimitPublisher
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(PrefillButtonsAction.updateMaxLimit)
        )

    case .updateBaseValue(let baseValue):
        state.baseValue = baseValue
        return .none

    case .updateMaxLimit(let maxLimit):
        state.maxLimit = maxLimit
        return .none

    case .select(let moneyValue):
        return .fireAndForget {
            environment.onValueSelected(moneyValue)
        }
    }
}

extension FiatValue {
    var rounded: FiatValue {
        let multiplier = pow(10, Double(displayPrecision + 1))
        return FiatValue(
            amount: BigInt(multiplier) * BigInt(ceil(Double(amount) / multiplier)),
            currency: currency
        )
    }
}

// MARK: - View

public struct PrefillButtonsView: View {
    let store: Store<PrefillButtonsState, PrefillButtonsAction>

    public init(store: Store<PrefillButtonsState, PrefillButtonsAction>) {
        self.store = store
    }

    private enum Constants {
        static let gradientLength = 20.pt
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                ZStack(alignment: .trailing) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Spacer()
                                .frame(width: Spacing.outer)
                            ForEach(viewStore.suggestedValues, id: \.amount) { suggestedValue in
                                SmallMinimalButton(
                                    title: suggestedValue.toDisplayString(
                                        includeSymbol: true,
                                        format: .shortened,
                                        locale: .current
                                    )
                                ) {
                                    viewStore.send(.select(suggestedValue))
                                }
                            }
                            Spacer()
                                .frame(width: Constants.gradientLength)
                        }
                        .frame(minHeight: 34.pt)
                    }

                    LinearGradient(
                        colors: [.semantic.background.opacity(0.01), .semantic.background],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Rectangle()
                    )
                    .frame(width: Constants.gradientLength)
                }

                Spacer()

                if let maxLimit = viewStore.maxLimit {
                    SmallMinimalButton(title: LocalizationConstants.Transaction.max) {
                        viewStore.send(.select(maxLimit))
                    }
                }
            }
            .padding(.trailing, Spacing.outer)
            .padding(.bottom, Spacing.standard)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// MARK: - Preview

struct PrefillButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        PrefillButtonsView(
            store: Store<PrefillButtonsState, PrefillButtonsAction>(
                initialState: PrefillButtonsState(
                    baseValue: FiatValue(amount: 900, currency: .USD),
                    maxLimit: FiatValue(amount: 120000, currency: .USD)
                ),
                reducer: prefillButtonsReducer,
                environment: .preview
            )
        )
    }
}
