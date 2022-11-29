// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import Extensions
import FeatureProveDomain
import Foundation
import SwiftUI

public final class ProveRouter: ProveRouterAPI {
    private let completionSubject = PassthroughSubject<VerificationResult, Never>()
    private let topViewController: TopMostViewControllerProviding
    private let app: AppProtocol

    struct ProfileInfo {
        var mobileAuthInfo: MobileAuthInfo?
        var prefillInfo: PrefillInfo?
    }

    private var profileInfo: ProfileInfo = .init()

    var step: Step = .beginProve

    enum Step: Int {
        case beginProve = 1
        case enterInfo = 2

        mutating func next() {
            if let step = Step(rawValue: rawValue + 1) {
                self = step
            }
        }

        mutating func previous() {
            if let step = Step(rawValue: rawValue - 1) {
                self = step
            }
        }
    }

    enum Action {
        case next, back
    }

    public init(
        topViewController: TopMostViewControllerProviding,
        app: AppProtocol = resolve()
    ) {
        self.topViewController = topViewController
        self.app = app
    }

    public func presentFlow() -> PassthroughSubject<VerificationResult, Never> {
        Task {
            do {
                step = .beginProve
                await MainActor.run {
                    let navigationViewController = UINavigationController(rootViewController: self.view())
                    topViewController
                        .topMostViewController?
                        .present(navigationViewController, animated: true)
                }
            }
        }
        return completionSubject
    }

    func onNext() {
        step.next()
        topViewController
            .topMostViewController?
            .navigationController?
            .pushViewController(
                view(),
                animated: true
            )
    }

   @objc func onBack() {
        step.previous()
        topViewController
            .topMostViewController?
            .navigationController?
            .popViewController(animated: true)
    }

    @objc func onFailed() {
        exitFlow(result: .failure)
    }

    @objc func onSkip() {
        exitFlow(result: .abandoned)
     }

    @objc
    func onDone() {
        topViewController
            .topMostViewController?
            .dismiss(animated: true)
    }

    private func exitFlow(result: VerificationResult) {
        topViewController
            .topMostViewController?
            .dismiss(animated: true, completion: { [weak self] in
                self?.completionSubject.send(result)
        })
    }

    private func endFlow() {
        completionSubject.send(.success)
        topViewController
            .topMostViewController?
            .dismiss(animated: true)
    }

    func view() -> UIViewController
   {

       switch step {
       case .beginProve:
           let view = BeginVerificationView(store: .init(
               initialState: .init(),
               reducer: BeginVerification(
                   app: app,
                   mobileAuthInfoService: resolve(),
                   dismissFlow: { [weak self] result in
                       switch result {
                       case .failure:
                           self?.onFailed()
                       case .abandoned:
                           self?.onSkip()
                       case .success(let mobileAuthInfo):
                           self?.profileInfo.mobileAuthInfo = mobileAuthInfo
                           self?.onNext()
                       }
                   }
               )
           )).app(app)
           let viewController = UIHostingController(rootView: view)

           return viewController

       case .enterInfo:
           let reducer = EnterInformation(
               app: app,
               prefillInfoService: resolve(),
               dismissFlow: { [weak self] result in
                switch result {
                case .failure:
                    self?.onFailed()
                case .abandoned:
                    self?.onSkip()
                case .success(let prefillInfo):
                    self?.profileInfo.prefillInfo = prefillInfo
                    self?.onDone()
                }
            }
           )
           let store: StoreOf<EnterInformation> = .init(
               initialState: .init(phone: profileInfo.mobileAuthInfo?.phone),
               reducer: reducer
           )
           let view = EnterInformationView(store: store).app(app)

           let viewController = UIHostingController(rootView: view)

           return viewController
       }
   }
}
