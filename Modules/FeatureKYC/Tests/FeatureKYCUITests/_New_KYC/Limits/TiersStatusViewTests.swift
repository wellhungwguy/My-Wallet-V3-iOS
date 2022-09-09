// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureKYCUI
import PlatformKit
import SnapshotTesting
import SwiftUI
import XCTest

final class TiersStatusViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func test_view_no_approved_tiers() throws {
        let tiers = KYC.UserTiers(
            tiers: [
                .init(tier: .tier0, state: .none),
                .init(tier: .tier1, state: .none),
                .init(tier: .tier2, state: .none)
            ]
        )
        let view = buildView(tiers: tiers)
        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func test_view_tier_1_approved() throws {
        let tiers = KYC.UserTiers(
            tiers: [
                .init(tier: .tier0, state: .verified),
                .init(tier: .tier1, state: .verified),
                .init(tier: .tier2, state: .none)
            ]
        )
        let view = buildView(tiers: tiers)
        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func test_view_tier_1_pending() throws {
        let tiers = KYC.UserTiers(
            tiers: [
                .init(tier: .tier0, state: .verified),
                .init(tier: .tier1, state: .pending),
                .init(tier: .tier2, state: .none)
            ]
        )
        let view = buildView(tiers: tiers)
        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func test_view_tier_2_pending() throws {
        let tiers = KYC.UserTiers(
            tiers: [
                .init(tier: .tier0, state: .verified),
                .init(tier: .tier1, state: .verified),
                .init(tier: .tier2, state: .pending)
            ]
        )
        let view = buildView(tiers: tiers)
        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func test_view_all_pending() throws {
        let tiers = KYC.UserTiers(
            tiers: [
                .init(tier: .tier0, state: .pending),
                .init(tier: .tier1, state: .pending),
                .init(tier: .tier2, state: .pending)
            ]
        )
        let view = buildView(tiers: tiers)
        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    private func buildView(tiers: KYC.UserTiers) -> some View {
        TiersStatusView(
            store: .init(
                initialState: tiers,
                reducer: tiersStatusViewReducer,
                environment: TiersStatusViewEnvironment(presentKYCFlow: { _ in })
            )
        )
        // fix the frame to a size that fits the content otherwise tests fail on CI
        .frame(width: 320, height: 850)
        .fixedSize()
    }
}
