//
//  ContentView.swift
//  ZekromShapes
//
//  用 SwiftUI 的基本形狀畫出阿羅拉地鼠。
//  角色由身體、眼睛、鼻子、三根黃色呆毛，以及前景土堆和小石頭組成。
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // 淡色背景，讓棕色地鼠和灰色土堆更容易看清楚。
            Color(red: 0.96, green: 0.95, blue: 0.91)
                .ignoresSafeArea()

            ZStack {
                // 阿羅拉地鼠頭頂的三根黃色呆毛，放在身體最上方。
                AlolanHair()
                    .position(x: 85, y: 4)

                // 地鼠身體：上方圓弧、下方平底，方便被土堆遮住。
                DiglettBodyShape()
                    .fill(
                        // 棕色漸層讓身體有一點立體感。
                        LinearGradient(
                            colors: [
                                Color(red: 0.74, green: 0.56, blue: 0.38),
                                Color(red: 0.58, green: 0.38, blue: 0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    // 深色外框讓地鼠輪廓更接近官方圖的手繪感。
                    .overlay(
                        DiglettBodyShape()
                            .stroke(Color(red: 0.23, green: 0.14, blue: 0.10), lineWidth: 3)
                    )

                // 兩顆直立黑眼睛。
                Eye()
                    .position(x: 60, y: 92)
                Eye()
                    .position(x: 110, y: 92)

                // 粉紅色鼻子。
                Ellipse()
                    .fill(Color(red: 0.95, green: 0.57, blue: 0.66))
                    .overlay(
                        Ellipse()
                            .stroke(Color(red: 0.45, green: 0.20, blue: 0.24), lineWidth: 2)
                    )
                    .frame(width: 62, height: 40)
                    .position(x: 85, y: 132)

                // 鼻子上的小反光。
                Ellipse()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 26, height: 10)
                    .rotationEffect(.degrees(-10))
                    .position(x: 72, y: 122)

                // 前景土堆和小石頭，蓋住身體底部，製造「從地裡鑽出來」的效果。
                FrontRocks()
                    .position(x: 85, y: 284)
            }
            .frame(width: 170, height: 300)
            .offset(y: -24)
        }
    }
}

/// 地鼠前方的灰色土堆，包含一個不規則土堆和幾顆小石頭。
struct FrontRocks: View {
    var body: some View {
        ZStack {
            // 主要土堆。
            GroundShape()
                .fill(Color(red: 0.48, green: 0.49, blue: 0.46))
                .overlay(
                    GroundShape()
                        .stroke(Color(red: 0.22, green: 0.22, blue: 0.20), lineWidth: 1.7)
                )
                .frame(width: 220, height: 95)
                .position(x: 110, y: 48)

            // 散在土堆上的小石頭，集中在土堆附近。
            SmallRock(width: 42, height: 24, rotation: -12)
                .position(x: 42, y: 45)
            SmallRock(width: 34, height: 20, rotation: 9)
                .position(x: 87, y: 34)
            SmallRock(width: 48, height: 25, rotation: 15)
                .position(x: 137, y: 42)
            SmallRock(width: 31, height: 18, rotation: -5)
                .position(x: 177, y: 54)
            SmallRock(width: 25, height: 15, rotation: 18)
                .position(x: 104, y: 64)
        }
        .frame(width: 220, height: 95)
    }
}

/// 單顆橢圓形小石頭，可調整寬高與角度。
struct SmallRock: View {
    var width: CGFloat
    var height: CGFloat
    var rotation: Double

    var body: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.74, green: 0.76, blue: 0.73),
                        Color(red: 0.54, green: 0.55, blue: 0.52)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Ellipse()
                    .stroke(Color(red: 0.22, green: 0.22, blue: 0.20), lineWidth: 1.2)
            )
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation))
    }
}

/// 不規則的灰色土堆外形。
struct GroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 7, y: rect.midY + 8))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 10, y: rect.midY + 4),
            control: CGPoint(x: rect.midX, y: rect.minY - 10)
        )
        path.addLine(to: CGPoint(x: rect.maxX - 2, y: rect.maxY - 16))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 4, y: rect.maxY - 11),
            control: CGPoint(x: rect.midX, y: rect.maxY + 12)
        )
        path.closeSubpath()

        return path
    }
}

/// 地鼠的眼睛：黑色直立膠囊，左上角有白色反光。
struct Eye: View {
    var body: some View {
        Capsule()
            .fill(Color(red: 0.10, green: 0.08, blue: 0.07))
            .frame(width: 14, height: 32)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 4, height: 4)
                    .offset(x: 4, y: 6)
            }
    }
}

/// 阿羅拉地鼠頭上的三根黃色呆毛。
struct AlolanHair: View {
    var body: some View {
        ZStack {
            HairStrand(points: [
                CGPoint(x: 0, y: 32),
                CGPoint(x: -11, y: 5),
                CGPoint(x: -31, y: -18)
            ])

            HairStrand(points: [
                CGPoint(x: 0, y: 32),
                CGPoint(x: 2, y: 2),
                CGPoint(x: 1, y: -31)
            ])

            HairStrand(points: [
                CGPoint(x: 0, y: 32),
                CGPoint(x: 15, y: 5),
                CGPoint(x: 38, y: -15)
            ])
        }
    }
}

/// 一根彎曲的呆毛，由三個點決定：起點、控制點、終點。
struct HairStrand: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count == 3 else { return path }
        let origin = CGPoint(x: rect.midX, y: rect.midY)

        path.move(to: CGPoint(x: origin.x + points[0].x, y: origin.y + points[0].y))
        path.addQuadCurve(
            to: CGPoint(x: origin.x + points[2].x, y: origin.y + points[2].y),
            control: CGPoint(x: origin.x + points[1].x, y: origin.y + points[1].y)
        )

        return path
    }
}

/// 把 HairStrand 畫成黃色粗線，並疊上一條深色細線當外框。
extension HairStrand: View {
    var body: some View {
        self.stroke(
            Color(red: 0.95, green: 0.82, blue: 0.32),
            style: StrokeStyle(lineWidth: 6, lineCap: .round)
        )
        .overlay(
            self.stroke(
                Color(red: 0.37, green: 0.28, blue: 0.05),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
        )
        .frame(width: 100, height: 100)
    }
}

/// 地鼠身體：上半部是圓弧，下方是平底，適合埋進土堆裡。
struct DiglettBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = rect.width / 2

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

#Preview {
    ContentView()
}
