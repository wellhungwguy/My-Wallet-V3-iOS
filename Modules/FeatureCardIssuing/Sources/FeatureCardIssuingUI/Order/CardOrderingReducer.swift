// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

public enum CardOrderingError: Error, Equatable {
    case noAddress
    case noSsn
    case noProduct
}

public enum CardOrderingResult: Equatable {
    case created
    case cancelled
}

enum CardOrderingAction: Equatable, BindableAction {

    case createCard
    case cardCreationResponse(Result<Card, NabuNetworkError>)
    case fetchProducts
    case productsResponse(Result<[Product], NabuNetworkError>)
    case fetchAddress
    case addressResponse(Result<Card.Address, NabuNetworkError>)
    case close(CardOrderingResult)
    case displayEligibleCountryList
    case displayEligibleStateList
    case selectProduct(Int)
    case residentialAddressModificationAction(ResidentialAddressModificationAction)
    case binding(BindingAction<CardOrderingState>)
}

struct CardOrderingState: Equatable {

    enum Field: Equatable {
        case line1, line2, city, state, zip
    }

    enum OrderProcessingState: Equatable {
        static func == (
            lhs: CardOrderingState.OrderProcessingState,
            rhs: CardOrderingState.OrderProcessingState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.processing, .processing),
                 (.success, .success),
                 (.none, .none),
                 (.error, .error):
                return true
            default:
                return false
            }
        }

        case processing
        case success
        case error(Error)
        case none
    }

    @BindableState var isLegalViewVisible = false
    @BindableState var isOrderProcessingVisible = false
    @BindableState var isSSNInputVisible = false
    @BindableState var isAddressConfirmationVisible = false
    @BindableState var isAddressModificationVisible = false
    @BindableState var isProductSelectionVisible = false
    @BindableState var isProductDetailsVisible = false

    @BindableState var termsAccepted = false
    @BindableState var selectedProductIndex: Int = 0

    @BindableState var ssn: String = ""

    var residentialAddressModificationState: ResidentialAddressModificationState?

    var updatingAddress = false
    var products: [Product] = []
    var selectedProduct: Product?
    var address: Card.Address?
    var error: NabuNetworkError?

    var orderProcessingState: OrderProcessingState = .none

    init(
        products: [Product] = [],
        selectedProduct: Product? = nil,
        address: Card.Address? = nil,
        ssn: String = "",
        error: NabuNetworkError? = nil,
        orderProcessingState: CardOrderingState.OrderProcessingState = .none
    ) {
        self.products = products
        self.selectedProduct = selectedProduct
        self.address = address
        self.ssn = ssn
        self.error = error
        self.orderProcessingState = orderProcessingState
    }
}

struct CardOrderingEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let cardService: CardServiceAPI
    let productsService: ProductsServiceAPI
    let residentialAddressService: ResidentialAddressServiceAPI
    let onComplete: (CardOrderingResult) -> Void

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        cardService: CardServiceAPI,
        productsService: ProductsServiceAPI,
        residentialAddressService: ResidentialAddressServiceAPI,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) {
        self.mainQueue = mainQueue
        self.cardService = cardService
        self.productsService = productsService
        self.residentialAddressService = residentialAddressService
        self.onComplete = onComplete
    }
}

// swiftlint:disable closure_body_length
let cardOrderingReducer: Reducer<
    CardOrderingState,
    CardOrderingAction,
    CardOrderingEnvironment
> = Reducer.combine(
    residentialAddressModificationReducer.optional().pullback(
        state: \.residentialAddressModificationState,
        action: /CardOrderingAction.residentialAddressModificationAction,
        environment: {
            ResidentialAddressModificationEnvironment(
                mainQueue: $0.mainQueue,
                residentialAddressService: $0.residentialAddressService
            )
        }
    ),
    Reducer<
        CardOrderingState,
        CardOrderingAction,
        CardOrderingEnvironment
    > { state, action, env in
        switch action {
        case .createCard:
            state.orderProcessingState = .processing
            state.isOrderProcessingVisible = true
            guard let product = state.selectedProduct else {
                state.orderProcessingState = .error(CardOrderingError.noProduct)
                return .none
            }
            guard let address = state.address else {
                state.orderProcessingState = .error(CardOrderingError.noAddress)
                return .none
            }
            guard !state.ssn.isEmpty else {
                state.orderProcessingState = .error(CardOrderingError.noSsn)
                return .none
            }
            return env.cardService
                .orderCard(product: product, at: address, with: state.ssn)
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.cardCreationResponse)
        case .cardCreationResponse(.success(let card)):
            state.orderProcessingState = .success
            return .none
        case .cardCreationResponse(.failure(let error)):
            state.orderProcessingState = .error(error)
            return .none
        case .fetchAddress:
            return env
                .residentialAddressService
                .fetchResidentialAddress()
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.addressResponse)
        case .addressResponse(.success(let address)):
            state.residentialAddressModificationState = .init(address: address, error: nil)
            state.isAddressModificationVisible = false
            state.updatingAddress = false
            state.address = address
            return .none
        case .addressResponse(.failure(let error)):
            state.residentialAddressModificationState = .init(address: nil, error: error)
            state.error = error
            return .none
        case .fetchProducts:
            return env
                .productsService
                .fetchProducts()
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.productsResponse)
        case .productsResponse(.success(let products)):
            state.products = products
            state.selectedProductIndex = 0
            state.selectedProduct = products[safe: 0]
            return .none
        case .productsResponse(.failure(let error)):
            state.error = error
            return .none
        case .close(let result):
            return .fireAndForget {
                env.onComplete(result)
            }
        case .displayEligibleStateList:
            return .none
        case .displayEligibleCountryList:
            return .none
        case .selectProduct(let index):
            state.selectedProductIndex = index
            state.selectedProduct = state.products[safe: index]
            return .none
        case .residentialAddressModificationAction(let modificationAction):
            switch modificationAction {
            case .updateAddressResponse(.success(let address)):
                state.address = address
                state.isAddressModificationVisible = false
                return .none
            default:
                return .none
            }
        case .binding:
            return .none
        }
    }
    .binding()
)

#if DEBUG
extension CardOrderingEnvironment {
    static var preview: CardOrderingEnvironment {
        CardOrderingEnvironment(
            mainQueue: .main,
            cardService: MockServices(),
            productsService: MockServices(),
            residentialAddressService: MockServices(),
            onComplete: { _ in }
        )
    }
}

struct MockServices: CardServiceAPI,
    ProductsServiceAPI,
    AccountProviderAPI,
    TopUpRouterAPI,
    SupportRouterAPI,
    ResidentialAddressServiceAPI
{

    static let address = Card.Address(
        line1: "614 Lorimer Street",
        line2: nil,
        city: "",
        postCode: "11111",
        state: "CA",
        country: "US"
    )

    let error = NabuError(id: "mock", code: .stateNotEligible, type: .unknown, description: "")
    let card = Card(
        id: "",
        type: .virtual,
        last4: "1234",
        expiry: "12/99",
        brand: .visa,
        status: .active,
        orderStatus: nil,
        createdAt: "01/10"
    )

    let accountCurrencyPair = AccountCurrency(
        accountCurrency: "BTC"
    )
    let accountBalancePair = AccountBalance(
        balance: Money(
            value: "50000",
            symbol: "BTC"
        )
    )
    let settings = CardSettings(
        locked: true,
        swipePaymentsEnabled: true,
        contactlessPaymentsEnabled: true,
        preAuthEnabled: true,
        address: Card.Address(
            line1: "48 rue de la Santé",
            line2: nil,
            city: "Paris",
            postCode: "75001",
            state: nil,
            country: "FR"
        )
    )

    func orderCard(
        product: Product,
        at address: Card.Address,
        with ssn: String
    ) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        .just([card])
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func helperUrl(for card: Card) -> AnyPublisher<URL, NabuNetworkError> {
        .just(URL(string: "https://blockchain.com/")!)
    }

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        .just("")
    }

    func fetchLinkedAccount(for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        .just(accountCurrencyPair)
    }

    func update(account: AccountBalance, for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        .just(accountCurrencyPair)
    }

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        .just([
            Product(productCode: "0", price: .init(value: "0.0", symbol: "BTC"), brand: .visa, type: .virtual),
            Product(productCode: "1", price: .init(value: "0.1", symbol: "BTC"), brand: .visa, type: .physical)
        ])
    }

    func eligibleAccounts(for card: Card) -> AnyPublisher<[AccountBalance], NabuNetworkError> {
        .just([accountBalancePair])
    }

    func selectAccount(for card: Card) -> AnyPublisher<AccountBalance, NabuNetworkError> {
        .just(accountBalancePair)
    }

    func linkedAccount(for card: Card) -> AnyPublisher<AccountSnapshot?, Never> {
        .just(nil)
    }

    func lock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func unlock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(card)
    }

    func openBuyFlow(for currency: CryptoCurrency?) {}

    func openBuyFlow(for currency: FiatCurrency?) {}

    func openSwapFlow() {}

    func handleSupport() {}

    func fetchResidentialAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        .just(Self.address)
    }

    func update(residentialAddress: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        .just(Self.address)
    }
}

extension MockServices: TransactionServiceAPI {

    func fetchMore(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        .just([])
    }

    func fetchTransactions(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        .just([])
    }
}
#endif
