// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UIKit

enum CustomSheetPresentation {}

struct ModalSheetContext: Equatable {

    /// A `CGFloat` specifying the progress how much the modal is expanded or collapsed.
    /// `1.0` is fully expanded whereas `0.0` is fully collapsed
    let progress: CGFloat

    /// A `CGPoint` of the `x` and `y` position of the modal
    let offset: CGPoint

    static let zero = ModalSheetContext(progress: 0.0, offset: .zero)
}

extension View {

    @available(iOS 16, *)
    @ViewBuilder
    func largestUndimmedDetentIdentifier(_ identifier: String?, modalOffset: Binding<ModalSheetContext>) -> some View {
        let detentIdentifier = identifier != nil ? UISheetPresentationController.Detent.Identifier(identifier!) : nil
        background(CustomSheetPresentation.Representable(largestUndimmedDetent: detentIdentifier, modalOffset: modalOffset))
    }
}

@available(iOS 16, *)
extension CustomSheetPresentation {

    struct Representable: UIViewControllerRepresentable {
        let largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?
        let modalOffset: Binding<ModalSheetContext>

        func makeUIViewController(context: Context) -> Controller {
            Controller(largestUndimmedDetent: largestUndimmedDetent, modalOffset: modalOffset)
        }

        func updateUIViewController(_ controller: Controller, context: Context) {
            controller.update(largestUndimmedDetent: largestUndimmedDetent, modalOffset: modalOffset)
        }
    }

    final class Controller: UIViewController, UISheetPresentationControllerDelegate {
        private var observation: NSKeyValueObservation?

        private var modalOffset: Binding<ModalSheetContext>
        private var largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?
        private weak var _delegate: UISheetPresentationControllerDelegate?

        init(largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?, modalOffset: Binding<ModalSheetContext>) {
            self.largestUndimmedDetent = largestUndimmedDetent
            self.modalOffset = modalOffset
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            if let controller = parent?.sheetPresentationController {
                if controller.delegate !== self {
                    _delegate = controller.delegate
                    controller.delegate = self
                }
            }
            update(largestUndimmedDetent: largestUndimmedDetent, modalOffset: modalOffset)
        }

        func update(largestUndimmedDetent: UISheetPresentationController.Detent.Identifier?, modalOffset: Binding<ModalSheetContext>) {
            self.largestUndimmedDetent = largestUndimmedDetent

            if let controller = parent?.sheetPresentationController {
                controller.largestUndimmedDetentIdentifier = largestUndimmedDetent
                controller.preferredCornerRadius = 24
                controller.prefersGrabberVisible = false
                controller.prefersScrollingExpandsWhenScrolledToEdge = true

                // oh dear... the only way that I found to be accurate enough in order to track the position of a modal sheet
                // is by observing its frame property.
                // Tried PanGesture on the presentedView of SheetPresentationController and it seemed to be only triggered
                // when the gesture originated within the navigation bar of the sheet...
                observation = controller.presentedView?.observe(\.frame) { [modalOffset] view, _ in
                    guard let superview = view.superview else {
                        return
                    }

                    let extraModalPadding = superview.safeAreaInsets.top > 20 ? 10.0 : 20.0
                    let frameHeight = superview.safeAreaLayoutGuide.layoutFrame.height - extraModalPadding
                    let leastCollapsedHeight = frameHeight * CollapsedDetent.fraction
                    let expandedHeight = frameHeight * ExpandedDetent.fraction
                    let effectiveHeight = expandedHeight - leastCollapsedHeight
                    let offsetY = view.frame.minY - superview.safeAreaInsets.top - extraModalPadding
                    let percentage = offsetY / effectiveHeight

                    let offset = CGPoint(
                        x: view.frame.origin.y,
                        y: view.frame.minY - superview.safeAreaInsets.top
                    )
                    modalOffset.wrappedValue = ModalSheetContext(
                        progress: percentage,
                        offset: offset
                    )
                }
            }
        }

        func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
            // TODO: should we respond to this?
            // it is updated when a detent change occured via gesture not when setting the `selectedDetentIdentifier` programmatically.
        }

        override func responds(to aSelector: Selector!) -> Bool {
            if super.responds(to: aSelector) { return true }
            if _delegate?.responds(to: aSelector) ?? false { return true }
            return false
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if super.responds(to: aSelector) { return self }
            return _delegate
        }
    }
}
