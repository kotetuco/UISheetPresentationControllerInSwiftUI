# UISheetPresentationControllerInSwiftUI

SwiftUIでUISheetPresentationControllerを利用するサンプルコードです。[Sansan Builders Blog](https://buildersbox.corp-sansan.com/)で書いた解説記事で使用しているサンプルコードとなります。

## 動作環境

- Xcode 13.2.1、iOS 15.1, 15.2にて動作確認をしています。
- いずれのサンプルコードも、Deployment Targetは15.0です(iOS 15.0以降のiOSで実行できます)。

## サンプルコードの実行方法

- **SheetSample.xcodeproj** を開いて実行するとサンプルアプリケーションを起動できます。

## シートで表示するUIの切り替え

`ContentView.swift` 内の下記ビルドフラグ設定を変更してください。

```swift
#if true  // ここのtrue/falseを変更してください
                .sheetPresentation(isPresented: $showSheet) {
                    DatePicker("Select date and time.", selection: $date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale(identifier: Locale.preferredLanguages.first!))
                }
#else
                .sheetPresentationWithImagePicker(isPresented: $showSheet) { uiImage in
                    self.uiImage = uiImage
                }
#endif
```

### `true` にした場合

シートに `DatePicker` を表示するサンプルが実行されます。

<img src="https://user-images.githubusercontent.com/2371902/150663049-ff8e73fc-6219-4369-83a1-3200c6ac7b58.png" width="320" alt="DatePicker" />

### `false` にした場合

シートに `PHPickerViewController` を表示するサンプルが実行されます。

<img src="https://user-images.githubusercontent.com/2371902/150663113-03e95d35-8bfe-46cc-8bc5-21e60a29a601.png" width="320" alt="PHPickerViewController" />

※注意
`PHPickerViewController` の問題(と推定されます)でシートを動かした際にクラッシュすることがあります。
