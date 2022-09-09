import BlockchainNamespace
import Combine
import MoneyKit
import ToolKit

public protocol UpdateSettingsClientAPI: AnyObject {

    func updatePublisher(
        currency: String,
        context: String,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, Error>
}

func provideUpdateCurrencyForWallets(
    app: AppProtocol,
    client: UpdateSettingsClientAPI
) -> (_ country: String, _ guid: String, _ sharedKey: String) -> AnyPublisher<Void, Never> {
    { country, guid, sharedKey in
        Deferred { () -> AnyPublisher<Void, Never> in
            app.publisher(for: blockchain.app.configuration.wallet.country.to.currency)
                .replaceError(with: HardcodedCountryToCurrency.mapping)
                .prefix(1)
                .flatMap { map -> AnyPublisher<Void, Never> in
                    let defaultCurrency = "USD"
                    let currency = map[country.uppercased()] ?? defaultCurrency
                    return client.updatePublisher(
                        currency: FiatCurrency.supported.contains(
                            where: { $0.code == currency }
                        ) ? currency : defaultCurrency,
                        context: "SETTINGS",
                        guid: guid,
                        sharedKey: sharedKey
                    )
                    .ignoreFailure()
                    .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Mapping (borrowed from web v4)

enum HardcodedCountryToCurrency {
    static let mapping = [
        "AD": "EUR",
        "AT": "EUR",
        "BE": "EUR",
        "CA": "CAD",
        "CS": "EUR",
        "DE": "EUR",
        "DK": "DKK",
        "EE": "EUR",
        "ES": "EUR",
        "FI": "EUR",
        "FO": "DKK",
        "FR": "EUR",
        "GB": "GBP",
        "GF": "EUR",
        "GL": "DKK",
        "GP": "EUR",
        "GR": "EUR",
        "GY": "EUR",
        "IE": "EUR",
        "IT": "EUR",
        "LT": "EUR",
        "LU": "EUR",
        "LV": "EUR",
        "MC": "EUR",
        "MQ": "EUR",
        "MT": "EUR",
        "NL": "EUR",
        "PL": "PLN",
        "PM": "EUR",
        "PT": "EUR",
        "RE": "EUR",
        "SE": "SEK",
        "SI": "EUR",
        "SK": "EUR",
        "SM": "EUR",
        "TF": "EUR",
        "VA": "EUR",
        "YT": "EUR"
    ]
}
