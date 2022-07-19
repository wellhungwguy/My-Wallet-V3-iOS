// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import DIKit
import Errors
import FeatureFormDomain
import FeatureKYCDomain
import Localization
import PlatformKit
import SwiftUI
import UIComponentsKit
import UIKit

final class KYCSDDVerificationController: KYCBaseViewController {

    private var kycTiersService: KYCTiersServiceAPI = resolve()

    private var bag = Set<AnyCancellable>()
    private var loadingView: KYCSDDVerificationLoadingView!

    private var viewLoadingObject = KYCSDDVerificationLoadingView.LoadingObservable()

    override class func make(with coordinator: KYCRouter) -> KYCSDDVerificationController {
        let controller = KYCSDDVerificationController()
        controller.router = coordinator
        controller.pageType = .sddVerificationCheck
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView = KYCSDDVerificationLoadingView(
            loadingObject: viewLoadingObject,
            retryCallback: performVerificationCheck
        )
        embed(loadingView)
        performVerificationCheck()
        navigationItem.hidesBackButton = true
    }

    // MARK: - UI Configuration

    override func navControllerCTAType() -> NavigationCTA {
        .none
    }

    // MARK: - SDD Verification

    private func performVerificationCheck() {
        viewLoadingObject.loading = true
        checkForSDDVerification { [router, pageType, viewLoadingObject] isVerified in
            router?.handle(event: .nextPageFromPageType(pageType, .sddVerification(isVerified: isVerified)))
            viewLoadingObject.loading = false
        }
    }

    private func checkForSDDVerification(completion: @escaping (Bool) -> Void) {
        kycTiersService.checkSimplifiedDueDiligenceVerification(pollUntilComplete: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &bag)
    }
}

struct KYCSDDVerificationLoadingView: View {

    class LoadingObservable: ObservableObject {
        var loading: Bool = false
    }

    @ObservedObject var loadingObject: LoadingObservable
    let retryCallback: (() -> Void)?

    var body: some View {
        VStack(spacing: LayoutConstants.VerticalSpacing.betweenContentGroups) {
            if loadingObject.loading {
                ActivityIndicatorView()
                VStack(spacing: 0) {
                    Text(LocalizationConstants.KYC.verificationInProgress)
                        .textStyle(.heading)
                    Text(LocalizationConstants.KYC.verificationInProgressWait)
                        .textStyle(.body)
                }
            } else {
                VStack(spacing: 0) {
                    Text(LocalizationConstants.KYC.verificationCompletedTitle)
                        .textStyle(.heading)
                    Text(LocalizationConstants.KYC.verificationCompletedMessage)
                        .textStyle(.body)
                }
                MinimalButton(title: LocalizationConstants.KYC.retryAction) {
                    retryCallback?()
                }
            }
        }
        .padding()
        .background(Color.viewPrimaryBackground)
        .multilineTextAlignment(.center)
    }
}
