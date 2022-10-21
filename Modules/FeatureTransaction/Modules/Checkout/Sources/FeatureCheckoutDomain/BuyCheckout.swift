import Blockchain

public struct BuyCheckout: Equatable {

    public var input: MoneyValue
    public var purchase: MoneyValuePair
    public var fee: Fee?
    public var total: FiatValue
    public var paymentMethod: PaymentMethod
    public var quoteExpiration: Date?

    public init(
        input: MoneyValue,
        purchase: MoneyValuePair,
        fee: Fee?,
        total: FiatValue,
        paymentMethod: BuyCheckout.PaymentMethod,
        quoteExpiration: Date?
    ) {
        self.input = input
        self.purchase = purchase
        self.fee = fee
        self.total = total
        self.paymentMethod = paymentMethod
        self.quoteExpiration = quoteExpiration
    }
}

extension BuyCheckout {

    public var exchangeRate: MoneyValue { purchase.inverseExchangeRate.quote }

    public var crypto: MoneyValue { purchase.quote }
    public var fiat: MoneyValue { purchase.base }

    public struct PaymentMethod: Equatable {

        public var name: String
        public var detail: String?
        public var isApplePay: Bool

        public init(name: String, detail: String?, isApplePay: Bool) {
            self.name = name
            self.detail = detail
            self.isApplePay = isApplePay
        }
    }

    public struct Fee: Equatable {

        public var value: FiatValue
        public var promotion: FiatValue?

        public init(value: FiatValue, promotion: FiatValue? = nil) {
            self.value = value
            self.promotion = promotion
        }
    }
}

extension BuyCheckout {

    public static var preview: BuyCheckout {
        .init(
            input: .create(major: 0.0021037, currency: .crypto(.bitcoin)),
            purchase: MoneyValuePair(
                fiatValue: .create(major: 98.00, currency: .USD),
                exchangeRate: .create(major: 47410.61, currency: .USD),
                cryptoCurrency: .bitcoin,
                usesFiatAsBase: true
            ),
            fee: .init(
                value: .create(major: 2.00, currency: .USD)
            ),
            total: .create(
                major: 100.00,
                currency: .USD
            ),
            paymentMethod: .init(
                name: "Chase Sapphire",
                detail: "Visa 0392",
                isApplePay: false
            ),
            quoteExpiration: Date()
                .addingTimeInterval(30)
        )
    }
}
