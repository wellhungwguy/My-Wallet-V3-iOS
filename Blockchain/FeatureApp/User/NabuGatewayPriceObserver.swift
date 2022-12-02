import Blockchain
import DIKit
import FeatureStakingData
import FeatureStakingDomain

class NabuGatewayPriceObserver: Client.Observer {

    private let app: AppProtocol
    private let service: PriceServiceAPI

    private var subscription: AnyCancellable?, task: Task<Void, Never>?

    init(app: AppProtocol, service: PriceServiceAPI = resolve()) {
        self.app = app
        self.service = service
    }

    func start() {
        subscription = app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .handleEvents(
                receiveOutput: { [app] currency in app.state.set(blockchain.api.nabu.gateway.price.crypto.fiat.id, to: currency.code) }
            )
            .flatMap(service.stream(quote:))
            .sink(to: My.update, on: self)
    }

    func stop() {
        subscription = nil
        task = nil
    }

    func update(_ result: Result<[String: PriceQuoteAtTime], NetworkError>) {
        task = Task {
            do {
                var batch = App.BatchUpdates()
                for (pair, quote) in try result.get() {
                    let (crypto, fiat) = try pair.split(separator: "-").map(\.string).tuple()
                    batch.append((blockchain.api.nabu.gateway.price.crypto[crypto].fiat[fiat].quote.value, quote.moneyValue._data))
                    batch.append((blockchain.api.nabu.gateway.price.crypto[crypto].fiat[fiat].quote.timestamp, quote.timestamp))
                    batch.append((blockchain.api.nabu.gateway.price.crypto[crypto].fiat[fiat].market.cap, quote.marketCap))
                }
                try await app.batch(updates: batch)
            } catch {
                app.post(error: error)
            }
        }
    }
}

extension RangeReplaceableCollection {

    fileprivate func tuple() throws -> (Element, Element) {
        guard count == 2 else { throw "Not a tuple" }
        return (self[startIndex], self[index(after: startIndex)])
    }
}

extension MoneyValue {

    var _data: [String: Any] {
        ["amount": minorString, "currency": code]
    }
}
