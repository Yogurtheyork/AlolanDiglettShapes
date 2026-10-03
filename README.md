# Alolan Diglett Shapes — 用 SwiftUI 形狀畫阿羅拉地鼠

作業：[#206 參考 Apple 的 Build with Stacks and Shapes 用形狀創作有趣圖案](https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84%E8%A9%A6%E7%85%89-%E5%8B%87%E8%80%85%E7%9A%84-100-%E9%81%93-swift-ios-app-%E8%AC%8E%E9%A1%8C/206-%E5%8F%83%E8%80%83-apple-%E7%9A%84-build-with-stacks-and-shapes-%E7%94%A8%E5%BD%A2%E7%8B%80%E5%89%B5%E4%BD%9C%E8%87%AA%E7%95%AB%E5%83%8F-self-portrait-b4d4a8eef55e)

這個專案使用 SwiftUI 的基本形狀、ZStack、modifier、自訂 Shape 與 Assets RGB 顏色，畫出阿羅拉地鼠。

## 作業需求對照

| 需求 | 實作 |
|---|---|
| 使用各種 Shape | `Circle`、`Ellipse`、`Capsule`、`Rectangle`、`RoundedRectangle`、`UnevenRoundedRectangle`，另有自訂 `Shape` |
| ZStack 堆疊 | 背景、地面、角色、眼睛、鼻子、頭髮、土堆與石頭皆使用 ZStack 疊放 |
| modifier 調整形狀 | 使用 `.fill`、`.stroke`、`.frame`、`.position`、`.offset`、`.rotationEffect`、`.opacity`、`.shadow` |
| 全螢幕背景顏色 | `Color("SandBackground").ignoresSafeArea()` |
| Assets 設定 RGB | 顏色集中於 `Assets.xcassets` 的 Color Set，例如 `DiglettBody`、`NosePink`、`HairGold` |
| 主要部位註解 | 身體、眼睛、鼻子、頭髮、土堆與石頭皆有中文註解 |

## 使用的 Assets 顏色

- `SandBackground`
- `GroundBrown`
- `DiglettBody`
- `DiglettShade`
- `DiglettOutline`
- `NosePink`
- `RockGray`
- `RockLight`
- `HairGold`

## 主要檔案

- `AlolanDiglettShapes/Sources/ContentView.swift`：阿羅拉地鼠畫面與所有 Shape
- `AlolanDiglettShapes/Sources/AlolanDiglettShapesApp.swift`：App 入口
- `AlolanDiglettShapes/Assets.xcassets`：作業使用的 RGB 顏色

## 執行

使用 Xcode 開啟 `AlolanDiglettShapes.xcodeproj`，選擇 iPhone Simulator 後執行即可。
