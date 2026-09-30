# Zekrom Shapes — 用形狀畫捷克羅姆

作業：[#206 參考 Apple 的 Build with Stacks and Shapes 用形狀創作有趣圖案](https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84%E8%A9%A6%E7%85%89-%E5%8B%87%E8%80%85%E7%9A%84-100-%E9%81%93-swift-ios-app-%E8%AC%8E%E9%A1%8C/206-%E5%8F%83%E8%80%83-apple-%E7%9A%84-build-with-stacks-and-shapes-%E7%94%A8%E5%BD%A2%E7%8B%80%E5%89%B5%E4%BD%9C%E8%87%AA%E7%95%AB%E5%83%8F-self-portrait-b4d4a8eef55e)

用 SwiftUI 的形狀畫出傳說寶可夢捷克羅姆（Zekrom #644），姿勢參考《寶可夢 黑》的官方繪圖：抬頭往左上看、往後延伸的頭冠、像張開的手的大翅膀、舉起的右拳、左手往下伸，以及最有代表性的圓形渦輪尾巴。

<img src="docs/preview.png" width="300" alt="Zekrom 預覽">

> 上圖是用 `tools/zekrom_gen.py` 輸出的 SVG 預覽，座標與 SwiftUI 程式相同，實際 iPhone 畫面的陰影、描邊會略有差異。

參考圖片：
- [Poképédia Miniature 0644](https://www.pokepedia.fr/images/a/ae/Miniature_0644_EV.png)
- [官方繪圖（Pokémon Database）](https://img.pokemondb.net/artwork/large/zekrom.jpg)
- [PokeAPI 官方繪圖、HOME 模型、夢境世界向量圖](https://github.com/PokeAPI/sprites)

## 作業需求對照

| 需求 | 做法 |
|---|---|
| 使用各種形狀 | `Circle`（尾巴外殼、指節、瞳孔、藍光）、`Ellipse`（眼睛、拳頭、渦輪開口與同心圓格柵、手指、雷雲）、`Capsule`（藍色反光線條、雲）、`Rectangle`（雨絲）、`RoundedRectangle`（岩石）、`UnevenRoundedRectangle`（三根腳趾：上圓下平） |
| ZStack 堆疊 | 最外層 ZStack 疊背景與捷克羅姆；捷克羅姆在 380×500 的畫布裡由後往前疊：後翅膀 → 尾巴 → 左腿 → 右腿 → 左手 → 身體 → 頭 → 前翅膀 → 右手 |
| modifier 調整形狀 | `fill`、`stroke`、`frame`、`position`、`offset`、`rotationEffect`、`trim`、`opacity`、`shadow` |
| 全螢幕背景顏色 | `Color.stormSky.ignoresSafeArea()` |
| Assets 設定顏色 RGB | `Assets.xcassets` 裡 7 個 Color Set（StormSky、CloudGray、ZekromBody、ZekromShade、ZekromOutline、ZekromBlue、ZekromRed），以 Xcode 自動產生的 `Color.zekromBody` 等名稱使用 |
| 主要部位註解 | 每個部位各自是一個 View（`ZekromHead`、`ZekromFrontWing`、`ZekromTail`…），主要形狀上方都有中文註解 |

加分項目：

- 自訂形狀：`Outline` 依序連起一串點圍成外形，`smooth: true` 時用二次曲線把轉角修圓（大腿、肩膀）；`Bolt` 畫閃電。
- 線條：所有外形都有黑色描邊（`StrokeStyle` 圓角接合），身上的藍色反光用細長 `Capsule` 旋轉後擺上去。
- 漸層：尾巴渦輪開口用 `RadialGradient`，中心透出藍光。
- 陰影：閃電與渦輪中心的藍光用同色 `shadow` 做發光效果。
- 透明度：雷雲、雨絲。
- `Circle().trim(from:to:)` 畫出尾巴外殼上的弧線。
- `ForEach` 把同一條雨絲放到不同位置。

## 程式怎麼產生的

捷克羅姆的外形很複雜，憑感覺擺形狀很難像，所以改成「描圖」：

1. 把官方繪圖（760×1000）加上座標格線放大檢查，記下每個部位輪廓的轉折點：頭冠、翅膀的三片羽板、尾巴、兩隻腳、手臂等。
2. 在 `tools/zekrom_gen.py` 裡列出每個部位：大外形用點列（之後變成 `Outline`），細節用內建形狀（大小、位置、角度），並寫上中文註解。
3. 輸出 SVG 預覽，並把官方繪圖半透明疊在上面比對位置，反覆修正。
4. 所有座標乘上 0.5 放進 380×500 的畫布，產生 `ContentView.swift` 與 Assets 的顏色設定：

```sh
python3 tools/zekrom_gen.py svg docs/preview.svg                  # 預覽
python3 tools/zekrom_gen.py svg overlay.svg --ref zekrom.jpg      # 疊上參考圖比對
python3 tools/zekrom_gen.py swift ZekromShapes/Sources/ContentView.swift
python3 tools/zekrom_gen.py assets ZekromShapes/Assets.xcassets
```

參考圖因版權沒有放進 repo，需要比對時請自行下載。App icon 是同一張 SVG 裁切上半身輸出的 1024×1024 圖片。

## 執行

Mac 上 clone 後開啟 `ZekromShapes.xcodeproj`，在 Signing & Capabilities 選擇自己的 Team，執行到 iPhone 模擬器或實機（iOS 17 以上，使用 `UnevenRoundedRectangle` 與 `fill` + `stroke` 連用）。

`ZekromShapes.xcodeproj` 是在沒有 Xcode 的環境依照 [TimerCam](https://github.com/Yogurtheyork/TimerCam) 專案手寫產生，程式尚未經過 Xcode 編譯與模擬器實測；若有錯誤，以 Xcode 提示修正後再 commit，並補上模擬器截圖。

## 檔案

- `ZekromShapes/Sources/ZekromShapesApp.swift`：App 入口。
- `ZekromShapes/Sources/ContentView.swift`：整張圖，每個部位一個 View，最後是自訂形狀 `Outline` 與 `Bolt`。
- `ZekromShapes/Assets.xcassets`：顏色與 App icon。
- `tools/zekrom_gen.py`：描圖座標與程式產生器。
- `docs/preview.svg`、`docs/preview.png`：預覽圖。

捷克羅姆（Zekrom）為 Nintendo / Creatures / GAME FREAK 的角色，本專案僅為課程練習。
