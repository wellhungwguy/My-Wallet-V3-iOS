// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxCocoa
import RxRelay
import RxSwift
import UIComponentsKit

public final class WebViewRouter: WebViewRouterAPI {

    // MARK: - Exposed

    public let launchRelay = PublishRelay<TitledLink>()

    // MARK: - Private

    private var launch: Signal<TitledLink> {
        launchRelay.asSignal()
    }

    private let disposeBag = DisposeBag()

    // MARK: - Injected

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let webViewServiceAPI: WebViewServiceAPI

    // MARK: - Setup

    public init(
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        webViewServiceAPI: WebViewServiceAPI = resolve()
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.webViewServiceAPI = webViewServiceAPI

        launch
            .map(\.url)
            .emit(onNext: { [weak self] url in
                guard let self else { return }
                guard let topViewController = self.topMostViewControllerProvider.topMostViewController else {
                    return
                }
                self.webViewServiceAPI.openSafari(url: url, from: topViewController)
            })
            .disposed(by: disposeBag)
    }
}
