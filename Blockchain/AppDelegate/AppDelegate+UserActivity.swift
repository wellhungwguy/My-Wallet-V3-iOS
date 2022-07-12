// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseCore
import FirebaseDynamicLinks
import UIKit

extension AppDelegate {
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        let handled: Bool
        if let webpageURL = userActivity.webpageURL {
            handled = DynamicLinks.dynamicLinks()
                .handleUniversalLink(webpageURL) { dynamiclink, _ in
                    if let url = dynamiclink?.url {
                        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                        components?.query = webpageURL.query
                        components?.fragment = webpageURL.fragment
                        app.post(
                            event: blockchain.app.process.deep_link,
                            context: [
                                blockchain.app.process.deep_link.url: components?.url ?? webpageURL
                            ]
                        )
                    } else {
                        self.handle(userActivity: userActivity)
                    }
                }
        } else {
            handled = false
        }

        viewStore.send(.appDelegate(.userActivity(userActivity)))

        guard handled else {
            return handle(userActivity: userActivity)
        }

        return handled
    }

    @discardableResult private func handle(userActivity: NSUserActivity) -> Bool {
        if let url = userActivity.webpageURL {
            app.post(
                event: blockchain.app.process.deep_link,
                context: [blockchain.app.process.deep_link.url: url]
            )
        }
        return viewStore.appSettings.userActivityHandled
    }
}
