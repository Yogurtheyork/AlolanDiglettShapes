//
//  ContentView.swift
//  ZekromShapes
//
//  #206 參考 Apple 的 Build with Stacks and Shapes，用形狀畫出捷克羅姆（Zekrom）。
//  所有顏色都在 Assets.xcassets 以 RGB 設定，Xcode 會自動產生 Color.zekromBlack 這類名稱。
//

import SwiftUI

/// 左右對稱的部位用 ForEach 畫兩次：x 位移與旋轉角度乘上 side 就會左右翻轉。
let sides: [CGFloat] = [-1, 1]

struct ContentView: View {
    var body: some View {
        ZStack {
            // 全螢幕背景：Assets 裡的 StormSky（暴風雨夜空）
            Color.stormSky
                .ignoresSafeArea()

            StormBackdrop()

            // Zekrom 本體：由後往前疊，後面的部位先畫
            ZStack {
                ZekromTail()
                ZekromWings()
                ZekromLegs()
                ZekromTorso()
                ZekromArms()
                ZekromHead()
            }
            .scaleEffect(0.9)
        }
    }
}

// MARK: - 雷雲、閃電與腳下的岩石（不跟著 Zekrom 縮放）

struct StormBackdrop: View {
    var body: some View {
        ZStack {
            // 雷雲
            Ellipse()
                .fill(Color.cloudGray)
                .frame(width: 260, height: 90)
                .offset(x: -120, y: -330)
                .opacity(0.6)
            Ellipse()
                .fill(Color.cloudGray)
                .frame(width: 220, height: 80)
                .offset(x: 130, y: -350)
                .opacity(0.5)
            Capsule()
                .fill(Color.cloudGray)
                .frame(width: 300, height: 60)
                .offset(x: 40, y: -300)
                .opacity(0.4)
            // 閃電（加黃色陰影當作發光）
            Bolt()
                .fill(Color.boltYellow)
                .frame(width: 50, height: 120)
                .rotationEffect(.degrees(-10))
                .offset(x: -150, y: -350)
                .shadow(color: Color.boltYellow, radius: 12)
            Bolt()
                .fill(Color.boltYellow)
                .frame(width: 40, height: 100)
                .rotationEffect(.degrees(15))
                .offset(x: 160, y: -330)
                .opacity(0.85)
                .shadow(color: Color.boltYellow, radius: 10)
            // 腳下的岩石
            Capsule()
                .fill(Color.cloudGray)
                .frame(width: 340, height: 44)
                .offset(y: 272)
                .opacity(0.8)
        }
    }
}

// MARK: - 尾巴：黑色尾巴加上發出藍光的發電機

struct ZekromTail: View {
    var body: some View {
        ZStack {
            // 尾巴
            Capsule()
                .fill(Color.zekromBlack)
                .stroke(Color.zekromEdge, lineWidth: 2)
                .frame(width: 56, height: 128)
                .rotationEffect(.degrees(-51))
                .offset(x: 90, y: 190)
            // 發電機外殼
            Circle()
                .fill(Color.zekromBlack)
                .stroke(Color.zekromEdge, lineWidth: 3)
                .frame(width: 100, height: 100)
                .offset(x: 140, y: 230)
            // 發電機核心：白到藍的放射漸層＋藍色光暈
            Circle()
                .fill(RadialGradient(colors: [.white, Color.zekromBlue], center: .center, startRadius: 2, endRadius: 32))
                .frame(width: 64, height: 64)
                .offset(x: 140, y: 230)
                .shadow(color: Color.zekromBlue, radius: 20)
            // 用 trim 剪掉一段的藍色電流環
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(Color.zekromBlue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 82, height: 82)
                .rotationEffect(.degrees(-40))
                .offset(x: 140, y: 230)
        }
    }
}

// MARK: - 翅膀：從肩膀伸出的骨架，末端展開四片羽刃

struct ZekromWings: View {
    var body: some View {
        ZStack {
            // 左右各畫一次：side = -1 是左邊、1 是右邊
            ForEach(sides, id: \.self) { side in
                // 翅膀骨架
                Capsule()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 30, height: 100)
                    .rotationEffect(.degrees(45 * side))
                    .offset(x: 97 * side, y: -130)
                // 四片羽刃，由內往外展開
                Blade()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 32, height: 165)
                    .rotationEffect(.degrees(-22 * side))
                    .offset(x: 102 * side, y: -242)
                Blade()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 32, height: 150)
                    .rotationEffect(.degrees(2 * side))
                    .offset(x: 135 * side, y: -241)
                Blade()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 32, height: 128)
                    .rotationEffect(.degrees(26 * side))
                    .offset(x: 161 * side, y: -223)
                Blade()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 32, height: 100)
                    .rotationEffect(.degrees(50 * side))
                    .offset(x: 171 * side, y: -198)
                // 翅膀關節
                Circle()
                    .fill(Color.zekromGray)
                    .frame(width: 34, height: 34)
                    .offset(x: 133 * side, y: -166)
            }
        }
    }
}

// MARK: - 雙腿：大腿、小腿、腳掌與腳爪

struct ZekromLegs: View {
    var body: some View {
        ZStack {
            // 左右各畫一次：side = -1 是左邊、1 是右邊
            ForEach(sides, id: \.self) { side in
                // 大腿
                Ellipse()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 96, height: 130)
                    .rotationEffect(.degrees(-8 * side))
                    .offset(x: 55 * side, y: 140)
                // 大腿上的灰色護甲
                Capsule()
                    .fill(Color.zekromGray)
                    .frame(width: 30, height: 60)
                    .rotationEffect(.degrees(-8 * side))
                    .offset(x: 50 * side, y: 120)
                    .opacity(0.9)
                // 小腿
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 58, height: 90)
                    .rotationEffect(.degrees(5 * side))
                    .offset(x: 64 * side, y: 215)
                // 腳掌：上方圓角大、下方圓角小
                UnevenRoundedRectangle(topLeadingRadius: 19, bottomLeadingRadius: 6, bottomTrailingRadius: 6, topTrailingRadius: 19)
                    .fill(Color.zekromGray)
                    .frame(width: 86, height: 38)
                    .offset(x: 70 * side, y: 264)
                // 三根腳爪
                Capsule()
                    .fill(Color.zekromEdge)
                    .frame(width: 14, height: 26)
                    .offset(x: 44 * side, y: 285)
                Capsule()
                    .fill(Color.zekromEdge)
                    .frame(width: 14, height: 26)
                    .offset(x: 70 * side, y: 285)
                Capsule()
                    .fill(Color.zekromEdge)
                    .frame(width: 14, height: 26)
                    .offset(x: 96 * side, y: 285)
            }
        }
    }
}

// MARK: - 身體：脖子、軀幹、胸甲與腹甲

struct ZekromTorso: View {
    var body: some View {
        ZStack {
            // 脖子
            Rectangle()
                .fill(Color.zekromBlack)
                .frame(width: 50, height: 60)
                .offset(y: -115)
            // 軀幹
            RoundedRectangle(cornerRadius: 55)
                .fill(Color.zekromBlack)
                .stroke(Color.zekromEdge, lineWidth: 2)
                .frame(width: 150, height: 210)
                .offset(y: 20)
            // 胸甲
            UnevenRoundedRectangle(topLeadingRadius: 40, bottomLeadingRadius: 12, bottomTrailingRadius: 12, topTrailingRadius: 40)
                .fill(Color.zekromGray)
                .frame(width: 110, height: 70)
                .offset(y: -45)
            // 三片腹甲，越往下越窄
            Capsule()
                .fill(Color.zekromGray)
                .frame(width: 84, height: 22)
                .offset(y: 35)
            Capsule()
                .fill(Color.zekromGray)
                .frame(width: 72, height: 22)
                .offset(y: 68)
            Capsule()
                .fill(Color.zekromGray)
                .frame(width: 60, height: 22)
                .offset(y: 99)
        }
    }
}

// MARK: - 手臂：肩膀、上臂、前臂、手與爪子

struct ZekromArms: View {
    var body: some View {
        ZStack {
            // 左右各畫一次：side = -1 是左邊、1 是右邊
            ForEach(sides, id: \.self) { side in
                // 肩膀
                Circle()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 64, height: 64)
                    .offset(x: 82 * side, y: -70)
                // 上臂
                Capsule()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 42, height: 96)
                    .rotationEffect(.degrees(-20 * side))
                    .offset(x: 98 * side, y: -25)
                // 前臂
                Capsule()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 52, height: 85)
                    .rotationEffect(.degrees(3 * side))
                    .offset(x: 112 * side, y: 62)
                // 手肘的刃
                Spike()
                    .fill(Color.zekromGray)
                    .frame(width: 20, height: 70)
                    .rotationEffect(.degrees(150 * side))
                    .offset(x: 132 * side, y: 50)
                // 手
                Circle()
                    .fill(Color.zekromGray)
                    .frame(width: 44, height: 44)
                    .offset(x: 110 * side, y: 117)
                // 三根爪子
                Spike()
                    .fill(Color.zekromEdge)
                    .frame(width: 12, height: 44)
                    .rotationEffect(.degrees(150 * side))
                    .offset(x: 121 * side, y: 138)
                Spike()
                    .fill(Color.zekromEdge)
                    .frame(width: 12, height: 44)
                    .rotationEffect(.degrees(180 * side))
                    .offset(x: 110 * side, y: 141)
                Spike()
                    .fill(Color.zekromEdge)
                    .frame(width: 12, height: 44)
                    .rotationEffect(.degrees(-150 * side))
                    .offset(x: 99 * side, y: 138)
            }
        }
    }
}

// MARK: - 頭：角冠、側角、臉、口鼻與紅色眼睛

struct ZekromHead: View {
    var body: some View {
        ZStack {
            // 頭頂角冠
            Crest()
                .fill(Color.zekromBlack)
                .stroke(Color.zekromEdge, lineWidth: 2)
                .frame(width: 70, height: 120)
                .offset(y: -228)
            // 左右各畫一次：side = -1 是左邊、1 是右邊
            ForEach(sides, id: \.self) { side in
                // 兩側的角
                Spike()
                    .fill(Color.zekromBlack)
                    .stroke(Color.zekromEdge, lineWidth: 2)
                    .frame(width: 22, height: 55)
                    .rotationEffect(.degrees(50 * side))
                    .offset(x: 51 * side, y: -203)
            }
            // 臉
            Ellipse()
                .fill(Color.zekromBlack)
                .stroke(Color.zekromEdge, lineWidth: 2)
                .frame(width: 96, height: 86)
                .offset(y: -170)
            // 口鼻
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.zekromBlack)
                .stroke(Color.zekromEdge, lineWidth: 2)
                .frame(width: 60, height: 50)
                .offset(y: -138)
            // 嘴巴
            Capsule()
                .fill(Color.zekromGray)
                .frame(width: 30, height: 4)
                .offset(y: -126)
            // 左右各畫一次：side = -1 是左邊、1 是右邊
            ForEach(sides, id: \.self) { side in
                // 發光的紅眼睛
                Ellipse()
                    .fill(Color.zekromRed)
                    .frame(width: 20, height: 9)
                    .rotationEffect(.degrees(18 * side))
                    .offset(x: 22 * side, y: -172)
                    .shadow(color: Color.zekromRed, radius: 6)
            }
        }
    }
}

// MARK: - 自訂形狀（座標以 rect 的寬高比例表示）

// 翅膀的羽刃：上尖下寬的五邊形
struct Blade: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0))
        path.addLine(to: CGPoint(x: rect.width * 1, y: rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.width * 0.72, y: rect.height * 1))
        path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 1))
        path.addLine(to: CGPoint(x: rect.width * 0, y: rect.height * 0.3))
        path.closeSubpath()
        return path
    }
}

// 尖刺：三角形
struct Spike: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0))
        path.addLine(to: CGPoint(x: rect.width * 1, y: rect.height * 1))
        path.addLine(to: CGPoint(x: rect.width * 0, y: rect.height * 1))
        path.closeSubpath()
        return path
    }
}

// 閃電
struct Bolt: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0))
        path.addLine(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.45, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.height * 1))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0))
        path.closeSubpath()
        return path
    }
}

// 頭頂的大角冠
struct Crest: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 1, y: rect.height * 1))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: rect.width * 0, y: rect.height * 1))
        path.addLine(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.55))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ContentView()
}
