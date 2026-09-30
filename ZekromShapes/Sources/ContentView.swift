//
//  ContentView.swift
//  ZekromShapes
//
//  #206 參考 Apple 的 Build with Stacks and Shapes，用形狀畫出捷克羅姆（Zekrom）。
//  參考寶可夢官方繪圖描出外形：大部位用自訂的 Outline 形狀，細節用內建形狀。
//  所有顏色都在 Assets.xcassets 以 RGB 設定，Xcode 會自動產生 Color.zekromBody 這類名稱。
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // 全螢幕背景：Assets 裡的 StormSky（暴風雨的天空）
            Color.stormSky
                .ignoresSafeArea()

            StormBackdrop()

            // 捷克羅姆：在 380 x 500 的畫布裡由後往前疊，後面的部位先畫
            ZStack {
                ZekromBackWing()
                ZekromTail()
                ZekromLeftLeg()
                ZekromRightLeg()
                ZekromLeftArm()
                ZekromTorso()
                ZekromHead()
                ZekromFrontWing()
                ZekromRightArm()
            }
            .frame(width: 380, height: 500)
            .offset(y: 20)
        }
    }
}

// MARK: - 自訂形狀

/// 依序連起畫布上的點圍成的外形；smooth 為 true 時用二次曲線把轉角修圓。
struct Outline: Shape {
    var points: [CGPoint]
    var smooth = false

    init(_ points: [(CGFloat, CGFloat)], smooth: Bool = false) {
        self.points = points.map { CGPoint(x: $0.0, y: $0.1) }
        self.smooth = smooth
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let last = points.last else { return path }
        if smooth {
            // 從最後一段的中點出發，每個點當控制點、畫到下一段的中點
            path.move(to: midpoint(last, points[0]))
            for i in points.indices {
                let next = points[(i + 1) % points.count]
                path.addQuadCurve(to: midpoint(points[i], next), control: points[i])
            }
        } else {
            path.addLines(points)
        }
        path.closeSubpath()
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}

/// 閃電
struct Bolt: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.55, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.45, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - 背景：雷雲、閃電、雨絲與岩石

struct StormBackdrop: View {
    var body: some View {
        ZStack {
            // 雷雲
            Ellipse()
                .fill(Color.cloudGray)
                .frame(width: 280, height: 110)
                .offset(x: -110, y: -330)
                .opacity(0.8)
            Ellipse()
                .fill(Color.cloudGray)
                .frame(width: 260, height: 100)
                .offset(x: 120, y: -350)
                .opacity(0.7)
            Capsule()
                .fill(Color.cloudGray)
                .frame(width: 330, height: 70)
                .offset(x: 20, y: -300)
                .opacity(0.6)
            // 雨絲：用 ForEach 把同一條細長方形放到不同位置
            ForEach([
                CGPoint(x: -150, y: -150), CGPoint(x: -90, y: 20), CGPoint(x: 160, y: -40),
                CGPoint(x: 130, y: 170), CGPoint(x: -160, y: 190), CGPoint(x: 60, y: -230)
            ], id: \.x) { spot in
                Rectangle()
                    .fill(Color.zekromOutline)
                    .frame(width: 2, height: 60)
                    .rotationEffect(.degrees(15))
                    .offset(x: spot.x, y: spot.y)
                    .opacity(0.15)
            }
            // 藍色閃電（捷克羅姆的雷擊）
            Bolt()
                .fill(Color.zekromBlue)
                .frame(width: 44, height: 110)
                .rotationEffect(.degrees(-12))
                .offset(x: -150, y: -250)
                .shadow(color: Color.zekromBlue, radius: 10)
            // 腳下的岩石
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cloudGray)
                .frame(width: 360, height: 60)
                .offset(y: 285)
        }
    }
}

// MARK: - 後方的小翅膀（被脖子擋住一半）

struct ZekromBackWing: View {
    var body: some View {
        ZStack {
            // 翅膀外形
            Outline([
                (111, 172), (80, 176), (48, 200), (53, 206), (75, 200), (61, 214),
                (80, 215), (96, 206), (82, 221), (102, 223), (120, 210), (120, 190)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 羽板之間的陰影
            Outline([(75, 200), (96, 193), (96, 206), (80, 215)])
                .fill(Color.zekromShade)
        }
    }
}

// MARK: - 尾巴：圓形的渦輪發電機，右側有尖刺

struct ZekromTail: View {
    var body: some View {
        ZStack {
            // 尾巴後側的深色板與尖刺
            Outline([
                (308, 260), (328, 264), (342, 252), (341, 274), (334, 300), (336, 334),
                (324, 316), (310, 320)
            ])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 尾巴外殼
            Circle()
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 135, height: 135)
                .position(x: 255, y: 319)
            // 上方的排氣口
            Ellipse()
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 55, height: 24)
                .rotationEffect(.degrees(-8))
                .position(x: 222.5, y: 292.5)
            // 渦輪扇葉的開口（放射漸層，中心透出藍光）
            Ellipse()
                .fill(RadialGradient(colors: [Color.zekromBlue, Color.zekromShade, Color.zekromOutline],
                                     center: .center, startRadius: 0, endRadius: 39.5))
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 64, height: 79)
                .position(x: 270, y: 336)
            // 同心圓的扇葉格柵
            Ellipse()
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                .frame(width: 50, height: 61.5)
                .position(x: 270, y: 336)
            Ellipse()
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                .frame(width: 36, height: 44)
                .position(x: 270, y: 336)
            Ellipse()
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                .frame(width: 22, height: 27)
                .position(x: 270, y: 336)
            // 發電中的藍光
            Circle()
                .fill(Color.zekromBlue)
                .frame(width: 11, height: 11)
                .position(x: 270, y: 336)
                .shadow(color: Color.zekromBlue, radius: 12)
            // 用 trim 畫出外殼上的弧線
            Circle()
                .trim(from: 0.55, to: 0.95)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 115, height: 115)
                .position(x: 255, y: 319)
        }
    }
}

// MARK: - 左腿：往左跨出去的大腿與腳

struct ZekromLeftLeg: View {
    var body: some View {
        ZStack {
            // 大腿
            Outline([
                (122, 311), (82, 334), (58, 350), (44, 368), (42, 381), (55, 391),
                (75, 389), (108, 381), (142, 378), (150, 345)
            ], smooth: true)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 腳
            Outline([
                (64, 389), (102, 391), (112, 389), (106, 400), (115, 424), (82, 431),
                (40, 437), (40, 430), (52, 419), (64, 401)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 腳背的深色護甲
            Outline([(75, 400), (102, 398), (111, 422), (85, 429)])
                .fill(Color.zekromShade)
            // 藍色反光
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 41)
                .rotationEffect(.degrees(56))
                .position(x: 67, y: 349.5)
        }
    }
}

// MARK: - 右腿：大腿、膝蓋護甲、小腿與三根腳趾

struct ZekromRightLeg: View {
    var body: some View {
        ZStack {
            // 大腿
            Outline([
                (160, 295), (198, 320), (222, 345), (237, 376), (233, 400), (220, 407),
                (192, 406), (174, 395), (161, 370)
            ], smooth: true)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 膝蓋的深色護甲
            Outline([(181, 341), (220, 346), (235, 375), (223, 401), (196, 405), (181, 394)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 26)
                .rotationEffect(.degrees(-14.5))
                .position(x: 196, y: 367.5)
            // 小腿與腳掌
            Outline([
                (234, 396), (278, 396), (299, 435), (311, 468), (311, 492), (200, 492),
                (202, 462), (219, 442), (234, 420)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 三根腳趾：上圓下平的 UnevenRoundedRectangle
            UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 4, bottomTrailingRadius: 4, topTrailingRadius: 14)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 29, height: 39)
                .rotationEffect(.degrees(-8))
                .position(x: 216, y: 474)
            // 腳趾上的藍色反光
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 20)
                .rotationEffect(.degrees(-3))
                .position(x: 217.5, y: 472.5)
            UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 4, bottomTrailingRadius: 4, topTrailingRadius: 14)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 29, height: 39)
                .position(x: 251, y: 474)
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 20)
                .rotationEffect(.degrees(-3))
                .position(x: 252.5, y: 472.5)
            UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 4, bottomTrailingRadius: 4, topTrailingRadius: 14)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 29, height: 39)
                .rotationEffect(.degrees(8))
                .position(x: 293, y: 474)
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 20)
                .rotationEffect(.degrees(-3))
                .position(x: 294.5, y: 472.5)
        }
    }
}

// MARK: - 左手：往左下伸出的手臂與張開的手掌

struct ZekromLeftArm: View {
    var body: some View {
        ZStack {
            // 手臂
            Outline([
                (95, 205), (116, 215), (117, 235), (111, 256), (103, 269), (110, 272),
                (101, 280), (100, 288), (75, 298), (60, 306), (55, 315), (46, 325),
                (40, 326), (30, 320), (25, 328), (20, 326), (8, 322), (5, 312),
                (25, 290), (50, 276), (75, 268), (84, 261), (85, 235)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 掌心
            Outline([(28, 296), (56, 287), (56, 304), (44, 320), (31, 315)])
                .fill(Color.zekromShade)
            // 手指
            Ellipse()
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 9, height: 12)
                .rotationEffect(.degrees(30))
                .position(x: 44, y: 296)
            Ellipse()
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 9, height: 12)
                .rotationEffect(.degrees(30))
                .position(x: 33, y: 307)
            Ellipse()
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 9, height: 12)
                .rotationEffect(.degrees(30))
                .position(x: 46, y: 311)
            // 藍色反光
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 35.5)
                .rotationEffect(.degrees(57.5))
                .position(x: 30, y: 290.5)
        }
    }
}

// MARK: - 身體：胸膛、腹部與兩腿之間的腹甲

struct ZekromTorso: View {
    var body: some View {
        ZStack {
            // 兩腿之間的腹甲
            Outline([
                (114, 280), (168, 278), (176, 310), (173, 350), (176, 379), (150, 388),
                (125, 380), (112, 345), (109, 305)
            ], smooth: true)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 腹甲上的藍線
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 70)
                .rotationEffect(.degrees(4))
                .position(x: 128.5, y: 335)
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 73)
                .rotationEffect(.degrees(-5))
                .position(x: 156, y: 336)
            // 胸膛與腰
            Outline([
                (108, 180), (98, 198), (92, 220), (100, 235), (113, 250), (120, 281),
                (168, 280), (169, 260), (181, 236), (205, 226), (222, 208), (225, 175),
                (215, 156), (190, 151), (160, 158), (145, 150), (138, 170)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 腰部的深色 V 字
            Outline([(121, 250), (156, 249), (153, 270), (138, 292), (125, 280)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 胸肌的深色護甲
            Outline([(155, 175), (172, 165), (196, 170), (200, 188), (186, 201), (160, 198)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            Outline([(98, 210), (108, 202), (119, 212), (116, 235), (104, 234)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 胸口的藍線
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 47.5)
                .rotationEffect(.degrees(13.5))
                .position(x: 139.5, y: 223)
        }
    }
}

// MARK: - 脖子與頭：往後延伸的頭冠、藍色角尖、紅眼睛

struct ZekromHead: View {
    var body: some View {
        ZStack {
            // 脖子
            Outline([
                (105, 150), (124, 139), (141, 144), (146, 170), (141, 198), (118, 205),
                (108, 180)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 35)
                .rotationEffect(.degrees(-3.5))
                .position(x: 117, y: 177.5)
            // 頭與往後延伸的頭冠
            Outline([
                (69, 138), (74, 118), (84, 105), (91, 102), (93, 111), (103, 100),
                (113, 96), (128, 96), (141, 99), (150, 107), (161, 109), (172, 104),
                (188, 106), (204, 114), (186, 112), (180, 112), (178, 123), (169, 120),
                (159, 123), (149, 124), (140, 123), (135, 131), (128, 136), (126, 150),
                (108, 157), (89, 153), (78, 145)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 下巴的深色面甲
            Outline([(80, 132), (131, 136), (126, 150), (108, 156), (89, 152), (78, 144)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 頭冠尖端的藍色
            Outline([(189, 107), (204, 114), (189, 112)])
                .fill(Color.zekromBlue)
            // 頭頂的藍色反光
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 18)
                .rotationEffect(.degrees(39.5))
                .position(x: 82, y: 113)
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 26)
                .rotationEffect(.degrees(-83.5))
                .position(x: 127, y: 98.5)
            // 紅色眼睛
            Ellipse()
                .fill(Color.zekromRed)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 15, height: 6.5)
                .rotationEffect(.degrees(-15))
                .position(x: 103.5, y: 115.5)
            // 瞳孔
            Circle()
                .fill(Color.zekromOutline)
                .frame(width: 3.5, height: 3.5)
                .position(x: 101.5, y: 115.5)
        }
    }
}

// MARK: - 前方的大翅膀：像張開的手，由三片長條羽板組成

struct ZekromFrontWing: View {
    var body: some View {
        ZStack {
            // 翅膀外形
            Outline([
                (231, 160), (223, 145), (224, 108), (202, 105), (220, 89), (255, 55),
                (300, 34), (376, 6), (373, 29), (350, 42), (356, 60), (367, 60),
                (361, 90), (350, 93), (346, 120), (338, 142), (255, 150), (236, 156)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 羽板之間的陰影
            Outline([(276, 75), (345, 42), (353, 61)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            Outline([(276, 116), (350, 92), (346, 120)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 翅膀前緣的藍色反光
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2.5, height: 59)
                .rotationEffect(.degrees(42.5))
                .position(x: 230, y: 81)
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 113)
                .rotationEffect(.degrees(68))
                .position(x: 317.5, y: 29)
        }
    }
}

// MARK: - 右手：肩膀、舉起的拳頭與前臂護甲

struct ZekromRightArm: View {
    var body: some View {
        ZStack {
            // 肩膀
            Outline([(181, 143), (215, 148), (228, 169), (220, 186), (196, 180), (183, 165)], smooth: true)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 上臂
            Outline([(210, 170), (238, 165), (248, 190), (238, 212), (216, 207), (205, 190)], smooth: true)
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            // 前臂護甲
            Outline([
                (255, 181), (318, 186), (326, 223), (320, 262), (303, 285), (275, 281),
                (270, 250), (250, 235)
            ])
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            Outline([(280, 221), (311, 215), (306, 234)])
                .fill(Color.zekromShade)
            Capsule()
                .fill(Color.zekromBlue)
                .frame(width: 2, height: 36)
                .rotationEffect(.degrees(-85))
                .position(x: 298, y: 185.5)
            // 拳頭
            Ellipse()
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 46, height: 63)
                .rotationEffect(.degrees(-10))
                .position(x: 257.5, y: 210)
            // 指節
            Circle()
                .fill(Color.zekromBody)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .frame(width: 18, height: 18)
                .position(x: 249, y: 183)
            // 爪子
            Outline([(265, 202), (252, 207), (264, 213)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
            Outline([(248, 233), (232, 240), (247, 241)])
                .fill(Color.zekromShade)
                .stroke(Color.zekromOutline, style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
        }
    }
}

#Preview {
    ContentView()
}
