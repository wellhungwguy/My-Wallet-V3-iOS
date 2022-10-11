# Money

The Money Package encompasses the models that represent fiat and crypto currencies. There are also services that returns Blockchain supported assets and enabled currencies for users.

## Key Classes

`FiatCurrency` contains all the supported fiat currency on our app. To add new fiat, you will add a new case on that enum

`CryptoCurrency` contains the supported crypto currency on our app. Each crypto has an underlying `AssetModel` which contains all the metadata for that coin.
