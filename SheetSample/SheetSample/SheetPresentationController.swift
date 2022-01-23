//
//  SheetPresentationController.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import SwiftUI
import UIKit

/// - Note: ImagePickerControllerは使わないでください(UIHostingControllerと合わせて使うことで動作がカクついてスクロールが使い物にならなくなります)
public struct SheetPresentationController<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController

    @Binding private var isPresented: Bool
    private var onDismiss: (() -> Void)?
    private var content: Content

    init(isPresented: Binding<Bool>, onDismiss: (() -> ())? = nil, content: Content) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content
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
                let sheetViewController = SheetHostingViewController(rootView: content)
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
