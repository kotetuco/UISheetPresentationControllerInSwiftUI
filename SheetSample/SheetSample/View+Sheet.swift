//
//  View+Sheet.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import SwiftUI
import UIKit

public extension View {
    func sheetPresentation<SheetView: View>(isPresented: Binding<Bool>,
                                            @ViewBuilder sheetView: @escaping () -> SheetView,
                                            onDismiss: (() -> Void)? = nil) -> some View {
        background {
            SheetPresentationController(isPresented: isPresented, sheetView: sheetView(), onDismiss: onDismiss)
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
