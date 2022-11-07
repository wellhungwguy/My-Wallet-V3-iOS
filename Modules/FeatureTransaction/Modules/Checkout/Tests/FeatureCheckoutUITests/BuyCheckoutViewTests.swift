// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if os(iOS)

@testable import FeatureCheckoutUI

import Blockchain
import BlockchainUI
import SnapshotTesting
import XCTest

final class BuyCheckoutViewTests: XCTestCase {

    var scheduler = DispatchQueue.immediate

    override func setUp() {
        super.setUp()
        isRecording = true
    }

    func preview(
        _ modify: (inout BuyCheckout) -> Void = { _ in }
    ) -> PublishedObject<Just<BuyCheckout>, ImmediateSchedulerOf<DispatchQueue>> {
        var checkout = BuyCheckout.preview
        modify(&checkout)
        return PublishedObject(
            publisher: Just(checkout),
            scheduler: scheduler
        )
    }

    func test_buy_checkout() {
        let view = BuyCheckoutView(viewModel: preview())
            .frame(width: 393.pt, height: 852.pt)
            .environment(\.scheduler, scheduler.eraseToAnyScheduler())
            .app(App.test)

        assertSnapshot(matching: view, as: .image)
    }

    func test_buy_checkout_no_quote_timer() {
        let view = BuyCheckoutView(
            viewModel: preview { checkout in
                checkout.quoteExpiration = nil
            }
        )
        .frame(width: 393.pt, height: 852.pt)
        .environment(\.scheduler, scheduler.eraseToAnyScheduler())
        .app(App.test)

        assertSnapshot(matching: view, as: .image)
    }

    func test_buy_checkout_no_fees() {

        let view = BuyCheckoutView(
            viewModel: preview { checkout in
                checkout.fee = .init(
                    value: .create(major: 2 as Double, currency: .USD),
                    promotion: .zero(currency: .USD)
                )
                checkout.purchase = MoneyValuePair(
                    fiatValue: .create(major: 100 as Double, currency: .USD),
                    exchangeRate: .create(major: 47410.61, currency: .USD),
                    cryptoCurrency: .bitcoin,
                    usesFiatAsBase: false
                )
            }
        )
        .frame(width: 393.pt, height: 852.pt)
        .environment(\.scheduler, scheduler.eraseToAnyScheduler())
        .app(App.test)

        assertSnapshot(matching: view, as: .image)
    }

    func test_buy_checkout_is_apple_pay() {

        let view = BuyCheckoutView(
            viewModel: preview { checkout in
                checkout.paymentMethod = .init(
                    name: "Apple Pay",
                    detail: nil,
                    isApplePay: true,
                    isACH: false
                )
            }
        )
        .frame(width: 393.pt, height: 852.pt)
        .environment(\.scheduler, scheduler.eraseToAnyScheduler())
        .app(App.test)

        assertSnapshot(matching: view, as: .image)
    }

    func test_buy_checkout_is_card_with_open_disclaimer() {

        let view = BuyCheckoutView<PublishedObject<Just<BuyCheckout>, DispatchQueue>>.Loaded(
            checkout: .preview,
            information: (true, true)
        )

        assertSnapshot(
            matching: view
                .frame(width: 393.pt, height: 852.pt)
                .environment(\.scheduler, scheduler.eraseToAnyScheduler())
                .app(App.test),
            as: .image
        )
    }
}
#endif
