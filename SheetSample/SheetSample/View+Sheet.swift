//
//  View+Sheet.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import SwiftUI
import UIKit

public extension View {
    func sheetPresentation<Content>(isPresented: Binding<Bool>,
                                    onDismiss: (() -> Void)? = nil,
                                    @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        background {
            SheetPresentationController(isPresented: isPresented, onDismiss: onDismiss, content: content())
        }
    }

    func sheetPresentationWithImagePicker(isPresented: Binding<Bool>,
                                          action: @escaping (UIImage) -> Void,
                                          onDismiss: (() -> Void)? = nil) -> some View {
        background {
            SheetImagePickerController(isPresented: isPresented, action: action, onDismiss: onDismiss)
        }
    }
}
