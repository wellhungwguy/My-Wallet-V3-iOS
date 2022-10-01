// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import Localization
import MoneyKit
import OrderedCollections
import PlatformKit
import SwiftUI

// MARK: State

public struct PrefillButtonsState: Equatable {
    var previousTxAmount: FiatValue?
    var action: AssetAction?
    var maxLimit: FiatValue?
    var configurations: [QuickfillConfiguration]?

    var suggestedValues: [QuickfillSuggestion] {
        guard let configurations = configurations else { return [] }
        guard let previousTxAmount = previousTxAmount, let maxLimit = maxLimit, let action = action else { return [] }

        // `Buy` uses the users previous tx amount.
        if action == .buy {
            return configurations
                .compactMap(\.baseValueConfiguration)
                .suggestedFiatAmountsWithBaseValue(previousTxAmount, maxLimit: maxLimit)
                .sorted(by: <)
        }

        // Actions other than buy use
        // the user's max spendable amount which is the same as `maxLimit`.
        // Swap and sell do not use `previousTxAmount`
        let majorValues = configurations
            .map { $0.suggestedFiatAmountWithBaseValue(maxLimit, maxLimit: maxLimit) }
            .compactMap { $0 }
        // Remove duplicates.
        // In some cases you may have duplicate prefill amounts like when the maxLimit is a very small number.
        return OrderedSet(majorValues)
            .array
    }

    private func baseMultipliedBy(_ by: BigInt) -> FiatValue? {
        guard let baseValue = previousTxAmount, let maxLimit = maxLimit else {
            return nil
        }
        let multiplier = FiatValue.create(
            majorBigInt: by,
            currency: baseValue.currency
        )
        guard let result = try? baseValue * multiplier else {
            return nil
        }
        guard let isLessThanMaxLimit = try? result < maxLimit else {
            return nil
        }
        return isLessThanMaxLimit ? result : nil
    }

    public init(
        previousTxAmount: FiatValue? = nil,
        action: AssetAction? = nil,
        maxLimit: FiatValue? = nil,
        configurations: [QuickfillConfiguration]? = nil
    ) {
        self.previousTxAmount = previousTxAmount
        self.action = action
        self.maxLimit = maxLimit
        self.configurations = configurations
    }
}

// MARK: - Actions

public enum PrefillButtonsAction: Equatable {
    case onAppear
    case updatePreviousTxAmount(FiatValue)
    case updateAssetAction(AssetAction)
    case updateMaxLimit(FiatValue)
    case updateQuickfillConfiguration([QuickfillConfiguration])
    case select(FiatValue, QuickfillConfiguration.Size)
}

// MARK: - Environment

public struct PrefillButtonsEnvironment {
    let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let lastPurchasePublisher: AnyPublisher<FiatValue, Never>
    let maxLimitPublisher: AnyPublisher<FiatValue, Never>
    let onValueSelected: (FiatValue, QuickfillConfiguration.Size) -> Void

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        lastPurchasePublisher: AnyPublisher<FiatValue, Never>,
        maxLimitPublisher: AnyPublisher<FiatValue, Never>,
        onValueSelected: @escaping (FiatValue, QuickfillConfiguration.Size) -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.lastPurchasePublisher = lastPurchasePublisher
        self.maxLimitPublisher = maxLimitPublisher
        self.onValueSelected = onValueSelected
    }

    static var preview: Self {
        PrefillButtonsEnvironment(
            app: App.preview,
            lastPurchasePublisher: .empty(),
            maxLimitPublisher: .empty(),
            onValueSelected: { _, _  in }
        )
    }
}

// MARK: - QuickfillConfiguration

public enum QuickfillConfiguration: Decodable, Equatable {

    public enum Size: String, Decodable, Comparable {
        case small
        case medium
        case large
        case max

        private var comparisonValue: String {
            switch self {
            case .small:
                return "a"
            case .medium:
                return "b"
            case .large:
                return "c"
            case .max:
                return "d"
            }
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.comparisonValue < rhs.comparisonValue
        }

        public var uppercased: String {
            rawValue.uppercased()
        }
    }

    var size: Size {
        switch self {
        case .balance(let config):
            return config.size
        case .baseValue(let config):
            return config.size
        }
    }

    case baseValue(BaseValueQuickfillConfiguration)
    case balance(BalanceQuickfillConfiguration)

    var baseValueConfiguration: BaseValueQuickfillConfiguration? {
        switch self {
        case .baseValue(let value):
            return value
        case .balance:
            return nil
        }
    }

    func suggestedFiatAmountWithBaseValue(
        _ baseValue: FiatValue,
        maxLimit: FiatValue
    ) -> QuickfillSuggestion? {
        switch self {
        case .baseValue(let config):
            return config.suggestedFiatAmountWithBaseValue(
                baseValue,
                maxLimit: maxLimit
            )
        case .balance(let config):
            return config.suggestedMajorValueWithBaseFiatValue(
                baseValue,
                maxLimit: maxLimit
            )
        }
    }
}

extension QuickfillConfiguration {
    public static func == (
        lhs: QuickfillConfiguration,
        rhs: QuickfillConfiguration
    ) -> Bool {
        switch (lhs, rhs) {
        case (.baseValue(let left), .baseValue(let right)):
            return left == right
        case (.balance(let left), .balance(let right)):
            return left == right
        default:
            return false
        }
    }
}

/// `BaseValueQuickfillConfiguration` is used for `Buy` transactions.
/// This uses the users `maxLimit` as the `baseValue` and is not dependent
/// on any sort of account balance.
public struct BaseValueQuickfillConfiguration: Decodable, Equatable {
    let multiplier: Double
    let rounding: Int
    let size: QuickfillConfiguration.Size

    func suggestedFiatAmountWithBaseValue(
        _ baseValue: FiatValue,
        maxLimit: FiatValue
    ) -> QuickfillSuggestion? {
        let amount = baseValue.displayMajorValue.doubleValue * multiplier
        let rounding = Double(rounding)
        let result = (amount / rounding).rounded(.up) / (1.0 / rounding)
        guard let value = FiatValue.create(major: "\(result)", currency: baseValue.currency) else { return nil }
        return (try? value < maxLimit) == true
        ? .init(majorValue: result, size: size, currency: baseValue.currency)
        : nil
    }
}

/// `BalanceQuickfillConfiguration` is used for `Swap` and `Sell` transactions and uses
/// the users balance as a `baseValue`.
public struct BalanceQuickfillConfiguration: Decodable, Equatable {
    let multiplier: Double
    let rounding: [Int]
    let size: QuickfillConfiguration.Size

    var min: Int {
        rounding.min()!
    }

    var max: Int {
        rounding.max()!
    }

    func suggestedMajorValueWithBaseFiatValue(
        _ baseValue: FiatValue,
        maxLimit: FiatValue
    ) -> QuickfillSuggestion? {
        // The amount should be greater than zero.
        guard baseValue.isPositive else { return nil }
        let amount = baseValue.displayMajorValue.doubleValue
        let wholeNumberValue = "\(Int(amount))".map(\.wholeNumberValue).count
        guard wholeNumberValue > 0 else { return nil }
        var roundingValue = 0
        // Get the rounding value that matches the `wholeNumberValue` of the `baseValue`.
        if rounding.indices.contains(wholeNumberValue - 1) {
            roundingValue = rounding[wholeNumberValue - 1]
        } else {
            // If there is no roundingValue that matches the `wholeNumberValue`
            // use the `min` or `max` of `rounding` (whichever is closest).
            roundingValue = wholeNumberValue - max > wholeNumberValue - min ? min : max
        }
        let result = ((amount * multiplier) / Double(roundingValue)).rounded(.up) / (1 / Double(roundingValue))
        guard let value = FiatValue.create(major: "\(result)", currency: baseValue.currency) else { return nil }
        // If the result is less than the max spendable amount, then it can be a suggested value.
        // If the result is more than the max spendable amount, we do not want to show it.
        return (try? value < maxLimit) == true
        ? .init(majorValue: result, size: size, currency: baseValue.currency)
            : nil
    }
}

extension BalanceQuickfillConfiguration {
    static let `default`: [BalanceQuickfillConfiguration] = [
        .init(multiplier: 0.25, rounding: [1], size: .small)
    ]
}

// MARK: - QuickfillSuggestions

public struct QuickfillSuggestion: Comparable, Hashable, Identifiable {

    var fiatValue: FiatValue? {
        .create(major: "\(majorValue)", currency: currency)
    }

    let majorValue: Double
    let size: QuickfillConfiguration.Size
    let currency: FiatCurrency

    public var id: Double {
        majorValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(majorValue)
        hasher.combine(size)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.majorValue < rhs.majorValue &&
        lhs.size < rhs.size
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
        let assetActionPublisher = environment.app
            .publisher(for: blockchain.ux.transaction.id, as: String.self)
            .compactMap(\.value)
            .compactMap { AssetAction(rawValue: $0) }

        return .merge(
            environment.lastPurchasePublisher
                .map(\.rounded)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(PrefillButtonsAction.updatePreviousTxAmount),

            environment.maxLimitPublisher
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(PrefillButtonsAction.updateMaxLimit),

            assetActionPublisher
                .flatMap { action -> AnyPublisher<[QuickfillConfiguration], Never> in
                    if action == .buy {
                        return environment.app
                            .publisher(for: blockchain.app.configuration.transaction.quickfill.configuration, as: [BaseValueQuickfillConfiguration].self)
                            .compactMap(\.value)
                            .map { $0.map(QuickfillConfiguration.baseValue) }
                            .eraseToAnyPublisher()
                    } else {
                        return environment.app
                            .publisher(for: blockchain.app.configuration.transaction.quickfill.configuration, as: [BalanceQuickfillConfiguration].self)
                            .compactMap(\.value)
                            .map { $0.map(QuickfillConfiguration.balance) }
                            .eraseToAnyPublisher()
                    }
                }
                .replaceError(with: [])
                .eraseToEffect()
                .map(PrefillButtonsAction.updateQuickfillConfiguration),

            assetActionPublisher
                .eraseToEffect()
                .map(PrefillButtonsAction.updateAssetAction)
        )

    case .updateQuickfillConfiguration(let configuration):
        state.configurations = configuration
        return .none

    case .updatePreviousTxAmount(let baseValue):
        state.previousTxAmount = baseValue
        return .none

    case .updateAssetAction(let action):
        state.action = action
        return .none

    case .updateMaxLimit(let maxLimit):
        state.maxLimit = maxLimit
        return .none

    case .select(let moneyValue, let size):
        return .fireAndForget {
            environment.onValueSelected(moneyValue, size)
        }
    }
}

extension FiatValue {

    /// Round fiat values up in 10 major increments.
    fileprivate var rounded: FiatValue {
        let multiplier = pow(10, Double(displayPrecision + 1))
        let minorDouble = multiplier * ceil(Double(minorAmount) / multiplier)
        return FiatValue.create(minorDouble: minorDouble, currency: currency)
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
                            ForEach(viewStore.suggestedValues) { suggestedValue in
                                if let fiatValue = suggestedValue.fiatValue {
                                    SmallMinimalButton(
                                        title: fiatValue.toDisplayString(
                                            includeSymbol: true,
                                            format: .shortened,
                                            locale: .current
                                        ),
                                        action: {
                                            viewStore.send(.select(fiatValue, suggestedValue.size))
                                        }
                                    )
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
                        viewStore.send(.select(maxLimit, .max))
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
                    previousTxAmount: FiatValue.create(majorBigInt: 9, currency: .USD),
                    maxLimit: FiatValue.create(majorBigInt: 1200, currency: .USD)
                ),
                reducer: prefillButtonsReducer,
                environment: .preview
            )
        )
    }
}

extension Array where Element == BaseValueQuickfillConfiguration {
    func suggestedFiatAmountsWithBaseValue(_ fiatValue: FiatValue, maxLimit: FiatValue) -> [QuickfillSuggestion] {
        var result: [QuickfillSuggestion] = []
        let currency = fiatValue.currency
        for element in self {
            if let previous = result.last,
               let base = FiatValue.create(major: "\(previous.majorValue)", currency: currency),
               let suggestion = element.suggestedFiatAmountWithBaseValue(base, maxLimit: maxLimit)
            {
                result.append(suggestion)
            } else if let suggestion = element.suggestedFiatAmountWithBaseValue(fiatValue, maxLimit: maxLimit) {
                result.append(suggestion)
            }
        }
        return result
    }
}
