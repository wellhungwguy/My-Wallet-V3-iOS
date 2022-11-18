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
            .receive(on: DispatchQueue.main)
            .sink(to: RootViewController.navigate(to:), on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.enter.into)
            .receive(on: DispatchQueue.main)
            .sink(to: RootViewController.enter(into:), on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.close)
            .receive(on: DispatchQueue.main)
            .sink(to: RootViewController.close, on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.replace.current.stack)
            .receive(on: DispatchQueue.main)
            .sink(to: RootViewController.replaceCurrent(stack:), on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.replace.root.stack)
            .receive(on: DispatchQueue.main)
            .sink(to: RootViewController.replaceRoot(stack:), on: self)
            .store(in: &bag)
    }

    private func hostingController(from event: Session.Event) throws -> some UIViewController {
        guard let action = event.action else {
            throw NavigationError(message: "received \(event.reference) without an action")
        }
        return try hostingController(
            from: action.data.decode(Tag.Reference.self),
            in: event.context
        )
    }

    private func hostingControllers(from event: Session.Event) throws -> [UIViewController] {
        guard let action = event.action else {
            throw NavigationError(message: "received \(event.reference) without an action")
        }
        return try action.data.decode([Tag.Reference].self).map {
            try hostingController(
                from: $0,
                in: event.context
            )
        }
    }

    private func hostingController(
        from story: Tag.Reference,
        in context: Tag.Context
    ) throws -> some UIViewController {
        try UIHostingController(
            rootView: siteMap.view(for: story.in(app), in: context)
                .app(app)
                .context(context)
                .onAppear { [app] in
                    app.post(event: story, context: context)
                }
        )
    }

    func navigate(to event: Session.Event) {
        do {
            try push(hostingController(from: event))
        } catch {
            app.post(error: error)
        }
    }

    func enter(into event: Session.Event) {
        do {
            try present(hostingController(from: event))
        } catch {
            app.post(error: error)
        }
    }

    func replaceRoot(stack event: Session.Event) {
        do {
            let controllers = try hostingControllers(from: event)
            let navigationController = try navigationController
                .or(throw: NavigationError.noNavigationController)
            dismiss(animated: true) {
                navigationController.setViewControllers(controllers, animated: true)
            }
        } catch {
            app.post(error: error)
        }
    }

    func replaceCurrent(stack event: Session.Event) {
        do {
            try (currentNavigationController ?? topMostViewController?.navigationController)
                .or(throw: NavigationError.noNavigationController)
                .setViewControllers(hostingControllers(from: event), animated: true)
        } catch {
            app.post(error: error)
        }
    }

    func close(_ event: Session.Event) {
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
