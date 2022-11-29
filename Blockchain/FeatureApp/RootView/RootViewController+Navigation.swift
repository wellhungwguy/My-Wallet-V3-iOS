import BlockchainUI
import SwiftUI
import UIKit

extension RootViewController {

    struct NavigationError: Error, CustomStringConvertible {
        static var noTopMostViewController: NavigationError = .init(message: "Unable to determine the top most view controller.")
        static var noNavigationController: NavigationError = .init(message: "No UINavigationController is associated with the top most view controller")
        let message: String
        var description: String { message }
    }

    func getTopMostViewController() throws -> UIViewController {
        guard let viewController = topMostViewController else {
            throw NavigationError.noTopMostViewController
        }
        return viewController
    }

    func present(_ vc: UIViewController, animated: Bool = true) throws {
        try getTopMostViewController()
            .present(vc, animated: animated)
    }

    func push(_ vc: UIViewController, animated: Bool = true) throws {
        try (currentNavigationController ?? getTopMostViewController().navigationController)
            .or(throw: NavigationError.noNavigationController)
            .pushViewController(vc, animated: animated)
    }

    func dismissTop(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let top = topMostViewController else { return }
        if top.isBeingDismissed {
            app.post(error: NavigationError(message: "Attempt to dismiss from view controller \(top) while a dismiss is in progress!"))
        }
        top.dismiss(animated: animated, completion: completion)
    }

    func pop(animated: Bool = true) {
        (currentNavigationController ?? topMostViewController?.navigationController)?
            .popViewController(animated: animated)
    }
}

extension RootViewController {

    func setupNavigationObservers() {
        app.on(blockchain.ui.type.action.then.navigate.to)
            .sink { [weak self] event in
                guard let self else { return }
                Task(priority: .userInitiated) { await self.navigate(to: event) }
            }
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.enter.into)
            .sink { [weak self] event in
                guard let self else { return }
                Task(priority: .userInitiated) { await self.enter(into: event) }
            }
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.close)
            .sink { [weak self] event in
                guard let self else { return }
                Task(priority: .userInitiated) { self.close(event) }
            }
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.replace.current.stack)
            .sink { [weak self] event in
                guard let self else { return }
                Task(priority: .userInitiated) { await self.replaceCurrent(stack: event) }
            }
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.replace.root.stack)
            .sink { [weak self] event in
                guard let self else { return }
                Task(priority: .userInitiated) { await self.replaceRoot(stack: event) }
            }
            .store(in: &bag)
    }

    @MainActor private func hostingController(from event: Session.Event) async throws -> some UIViewController {
        guard let action = event.action else {
            throw NavigationError(message: "received \(event.reference) without an action")
        }
        return try await hostingController(
            from: action.data.decode(Tag.Reference.self),
            in: event.context
        )
    }

    @MainActor private func hostingControllers(from event: Session.Event) async throws -> [UIViewController] {
        guard let action = event.action else {
            throw NavigationError(message: "received \(event.reference) without an action")
        }
        var viewControllers: [UIViewController] = []
        for reference in try action.data.decode([Tag.Reference].self) {
            try await viewControllers.append(
                hostingController(from: reference, in: event.context)
            )
        }
        return viewControllers
    }

    @MainActor private func hostingController(
        from story: Tag.Reference,
        in context: Tag.Context
    ) async throws -> some UIViewController {
        try await UIHostingController(
            rootView: siteMap.view(for: story.in(app), in: context)
                .app(app)
                .context(context)
                .onAppear { [app] in
                    app.post(event: story, context: context)
                }
        )
    }

    @MainActor func navigate(to event: Session.Event) async {
        do {
            try await push(hostingController(from: event))
        } catch {
            app.post(error: error)
        }
    }

    @MainActor func enter(into event: Session.Event) async {
        do {
            try await present(hostingController(from: event))
        } catch {
            app.post(error: error)
        }
    }

    @MainActor func replaceRoot(stack event: Session.Event) async {
        do {
            let controllers = try await hostingControllers(from: event)
            let navigationController = try navigationController
                .or(throw: NavigationError.noNavigationController)
            dismiss(animated: true) {
                navigationController.setViewControllers(controllers, animated: true)
            }
        } catch {
            app.post(error: error)
        }
    }

    @MainActor func replaceCurrent(stack event: Session.Event) async {
        do {
            try await (currentNavigationController ?? topMostViewController?.navigationController)
                .or(throw: NavigationError.noNavigationController)
                .setViewControllers(hostingControllers(from: event), animated: true)
        } catch {
            app.post(error: error)
        }
    }

    @MainActor func close(_ event: Session.Event) {
        do {
            if let close = try? app.state.get(event.reference) as Session.State.Function {
                try close()
            } else {
                dismissTop()
            }
        } catch {
            app.post(error: error)
        }
    }
}
