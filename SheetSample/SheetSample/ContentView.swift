//
//  ContentView.swift
//  SheetSample
//
//  Created by kotetuco on 2022/01/16.
//

import SwiftUI

struct ContentView: View {
    @State private var showSheet: Bool = false
    @State private var uiImage: UIImage?
    @State private var date = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .padding()
                } else {
                    Text(dateTimeText)
                }

                Button {
                    showSheet.toggle()
                } label: {
                    Text("Show a half sheet.")
                }
                .buttonStyle(.borderedProminent)
                .sheetPresentation(isPresented: $showSheet, sheetView: {
//                    ImagePickerController { uiImage in
//                        self.uiImage = uiImage
//                    }
//                    .edgesIgnoringSafeArea(.bottom)
                    DatePicker("Select date and time.", selection: $date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: Locale.preferredLanguages.first!))
                }, onDismiss: nil)
                .padding()
            }
            .navigationTitle("Half Sheet Sample")
        }
    }

    private var dateTimeText: String {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return "\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!) \(dateComponents.hour!):\(dateComponents.minute!)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
