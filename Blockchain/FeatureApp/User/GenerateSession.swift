import Blockchain

final class GenerateSession: Session.Observer {

    unowned var app: AppProtocol
    var http: URLSessionProtocol = URLSession.shared
    var scheduler: AnySchedulerOf<DispatchQueue> = .main

    init(app: AppProtocol, http: URLSessionProtocol = URLSession.shared) {
        self.app = app
        self.http = http
    }

    private var subscription: AnyCancellable?
    private var baseURL = URL(string: "https://\(Bundle.main.plist?.RETAIL_CORE_URL ?? "api.blockchain.info/nabu-gateway")")!

    func start() {
        let request = URLRequest("PUT", baseURL.appendingPathComponent("generate-session"))
        var rng = SystemRandomNumberGenerator()
        subscription = http.dataTaskPublisher(for: request.peek("🌎", \.cURLCommand))
            .retry(delay: .exponential(using: &rng), scheduler: scheduler)
            .map(\.data)
            .decode(type: [String: String].self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { [app] completion in
                    switch completion {
                    case .failure(let error): app.post(error: error)
                    case .finished: break
                    }
                },
                receiveValue: { [app] output in
                    app.state.set(blockchain.api.nabu.gateway.generate.session.headers, to: output.mapKeys { headerMap[$0] ?? $0 })
                }
            )
    }

    func stop() {
        subscription?.cancel()
    }
}

private let headerMap: [String: String] = [
    "xSessionId": "X-Session-ID"
]
