//
//  ImagePickerController.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import PhotosUI
import SwiftUI
import UIKit

public struct ImagePickerController: UIViewControllerRepresentable {
    public typealias UIViewControllerType = PHPickerViewController
    private var action: ((UIImage) -> Void)

    init(action: @escaping ((UIImage) -> Void)) {
        self.action = action
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        let config = PHPickerConfiguration()
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public final class Coordinator : PHPickerViewControllerDelegate {
        var parent: ImagePickerController

        init(parent: ImagePickerController) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                guard let image = object as? UIImage else { return }
                Task {
                    await MainActor.run(body: {
                        self.parent.action(image)
                        picker.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
    }
}
