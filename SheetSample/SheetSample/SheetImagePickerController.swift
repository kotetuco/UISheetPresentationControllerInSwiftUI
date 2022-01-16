//
//  SheetImagePickerController.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import PhotosUI
import SwiftUI
import UIKit

/// SheetをMediumからLargeへスクロールすると、PHPickerViewControllerの問題で途中でPHPickerViewControllerがクラッシュします
/// (Try Againボタンを押すことで元に戻ります)
public struct SheetImagePickerController: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController

    @Binding private var isPresented: Bool
    private var action: ((UIImage) -> Void)
    private var onDismiss: (() -> Void)?

    init(isPresented: Binding<Bool>, action: @escaping ((UIImage) -> Void), onDismiss: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.action = action
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
                var config = PHPickerConfiguration()
                config.selectionLimit = 1
                config.filter = .images
                let sheetViewController = PHPickerViewController(configuration: config)
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

    public final class Coordinator: NSObject, UISheetPresentationControllerDelegate, PHPickerViewControllerDelegate {
        var parent: SheetImagePickerController

        init(parent: SheetImagePickerController) {
            self.parent = parent
        }

        public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if parent.isPresented {
                parent.isPresented = false
                parent.onDismiss?()
            }
        }

        internal func sheetViewControllerDidDisappear<Content>(_ sheetViewController: SheetHostingViewController<Content>) where Content : View {
            parent.isPresented = false
            parent.onDismiss?()
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                parent.isPresented = false
                parent.onDismiss?()
                picker.dismiss(animated: true, completion: nil)
                return
            }
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (object, error) in
                guard let self = self, let image = object as? UIImage else { return }
                Task {
                    await MainActor.run(body: {
                        self.parent.isPresented = false
                        self.parent.action(image)
                        picker.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
    }
}
