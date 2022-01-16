//
//  SheetPresentationController.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import SwiftUI
import UIKit

/// - Note: ImagePickerControllerは使わないでください(UIHostingControllerと合わせて使うことで動作がカクついてスクロールが使い物にならなくなります)
public struct SheetPresentationController<SheetView: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController

    @Binding private var isPresented: Bool
    private var sheetView: SheetView
    private var onDismiss: (() -> Void)?

    init(isPresented: Binding<Bool>, sheetView: SheetView, onDismiss: (() -> ())? = nil) {
        self._isPresented = isPresented
        self.sheetView = sheetView
        self.onDismiss = onDismiss
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            if uiViewController.presentedViewController == nil {
                let sheetViewController = SheetHostingViewController(rootView: sheetView)
                sheetViewController.sheetPresentationController?.delegate = context.coordinator
                sheetViewController.delegate = context.coordinator
                if let sheetPresentationController = sheetViewController.sheetPresentationController {
                    sheetPresentationController.detents = [.medium(), .large()]
                    sheetPresentationController.prefersGrabberVisible = true
                    sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheetPresentationController.preferredCornerRadius = 20
                }
                uiViewController.present(sheetViewController, animated: true)
            }
        } else {
            uiViewController.dismiss(animated: true)
        }
    }

    public final class Coordinator: NSObject, UISheetPresentationControllerDelegate, SheetHostingViewControllerDelegate {
        var parent: SheetPresentationController

        init(parent: SheetPresentationController) {
            self.parent = parent
        }

        public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if self.parent.isPresented {
                self.parent.isPresented = false
                if let onDismiss = self.parent.onDismiss {
                    onDismiss()
                }
            }
        }

        internal func sheetViewControllerDidDisappear<Content>(_ sheetViewController: SheetHostingViewController<Content>) where Content : View {
            self.parent.isPresented = false
            if let onDismiss = self.parent.onDismiss {
                onDismiss()
            }
        }
    }
}

protocol SheetHostingViewControllerDelegate: AnyObject {
    func sheetViewControllerDidDisappear<Content: View>(_ sheetViewController: SheetHostingViewController<Content>)
}

final class SheetHostingViewController<Content: View>: UIHostingController<Content> {
    weak var delegate: SheetHostingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.sheetViewControllerDidDisappear(self)
    }
}
