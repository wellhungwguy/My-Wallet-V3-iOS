# Money

The Money package encompasses all models and services necessary to provide a consumer framework and/or app with data about supported currencies and networks, prices of those currencies, and mathematical operations on top of money values.

## Key Classes

`FiatCurrency` contains all the supported fiat currency on our app. To add new fiat, you will add a new case on that enum

`CryptoCurrency` contains the supported crypto currency on our app. Each crypto has an underlying `AssetModel` which contains all the metadata for that coin.
