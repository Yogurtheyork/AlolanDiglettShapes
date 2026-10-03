//
//  ContentView.swift
//  ZekromShapes
//
//  SwiftUI Shapes 作業：用基本形狀畫出阿羅拉地鼠。
//  使用 Circle、Ellipse、Capsule、Rectangle、RoundedRectangle、
//  UnevenRoundedRectangle、自訂 Shape、ZStack 與 Assets RGB 顏色。
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // 全螢幕背景：顏色來自 Assets.xcassets。
            Color("SandBackground")
                .ignoresSafeArea()

            // 底部地面色帶，示範 Rectangle。
            Rectangle()
                .fill(Color("GroundBrown").opacity(0.18))
                .frame(height: 150)
                .frame(maxHeight: .infinity, alignment: .bottom)

            ZStack {
                // 頭頂三根金黃色呆毛。
                AlolanHair()
                    .position(x: 110, y: 34)

                // 地鼠身體。
                DiglettBodyShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("DiglettBody"),
                                Color("DiglettShade")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        DiglettBodyShape()
                            .stroke(Color("DiglettOutline"), lineWidth: 3)
                    )
                    .shadow(radius: 4, y: 2)

                // 左眼。
                Eye()
                    .position(x: 78, y: 118)

                // 右眼。
                Eye()
                    .position(x: 142, y: 118)

                // 鼻子：Ellipse。
                Ellipse()
                    .fill(Color("NosePink"))
                    .overlay(
                        Ellipse()
                            .stroke(Color("DiglettOutline"), lineWidth: 2)
                    )
                    .frame(width: 76, height: 48)
                    .position(x: 110, y: 164)

                // 鼻子反光。
                Ellipse()
                    .fill(.white.opacity(0.38))
                    .frame(width: 30, height: 11)
                    .rotationEffect(.degrees(-10))
                    .position(x: 94, y: 151)

                // 前景土堆與石頭，遮住身體底部。
                FrontRocks()
                    .position(x: 110, y: 332)
            }
            .frame(width: 220, height: 360)
            .offset(y: -18)
        }
    }
}

/// 地鼠前方的土堆與小石頭。
struct FrontRocks: View {
    var body: some View {
        ZStack {
            // 不規則主土堆。
            GroundShape()
                .fill(Color("RockGray"))
                .overlay(
                    GroundShape()
                        .stroke(Color("DiglettOutline"), lineWidth: 1.7)
                )
                .frame(width: 255, height: 105)
                .position(x: 128, y: 52)

            // RoundedRectangle：左側扁石。
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("RockLight"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("DiglettOutline"), lineWidth: 1.2)
                )
                .frame(width: 52, height: 24)
                .rotationEffect(.degrees(-10))
                .position(x: 48, y: 46)

            // UnevenRoundedRectangle：右側較不規則的扁石。
            UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: 5,
                bottomTrailingRadius: 10,
                topTrailingRadius: 4
            )
            .fill(Color("RockLight"))
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 5,
                    bottomTrailingRadius: 10,
                    topTrailingRadius: 4
                )
                .stroke(Color("DiglettOutline"), lineWidth: 1.2)
            )
            .frame(width: 58, height: 25)
            .rotationEffect(.degrees(13))
            .position(x: 160, y: 49)

            // Ellipse：中央小石頭。
            SmallRock(width: 38, height: 21, rotation: 6)
                .position(x: 103, y: 34)

            SmallRock(width: 30, height: 17, rotation: -7)
                .position(x: 205, y: 61)

            SmallRock(width: 27, height: 15, rotation: 15)
                .position(x: 124, y: 69)
        }
        .frame(width: 255, height: 105)
    }
}

/// 單顆橢圓形小石頭。
struct SmallRock: View {
    var width: CGFloat
    var height: CGFloat
    var rotation: Double

    var body: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color("RockLight"),
                        Color("RockGray")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Ellipse()
                    .stroke(Color("DiglettOutline"), lineWidth: 1.2)
            )
            .frame(width: width, height: height)
            .rotationEffect(.degrees(rotation))
    }
}

/// 不規則土堆外形。
struct GroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 8, y: rect.midY + 8))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 10, y: rect.midY + 5),
            control: CGPoint(x: rect.midX, y: rect.minY - 12)
        )
        path.addLine(to: CGPoint(x: rect.maxX - 3, y: rect.maxY - 16))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + 4, y: rect.maxY - 10),
            control: CGPoint(x: rect.midX, y: rect.maxY + 13)
        )
        path.closeSubpath()

        return path
    }
}

/// 地鼠眼睛：Capsule + Circle 反光。
struct Eye: View {
    var body: some View {
        Capsule()
            .fill(Color("DiglettOutline"))
            .frame(width: 16, height: 38)
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 5, height: 5)
                    .offset(x: 4, y: 7)
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

/// 一根彎曲的呆毛。
struct HairStrand: Shape {
    var points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count == 3 else { return path }

        let origin = CGPoint(x: rect.midX, y: rect.midY)

        path.move(
            to: CGPoint(
                x: origin.x + points[0].x,
                y: origin.y + points[0].y
            )
        )
        path.addQuadCurve(
            to: CGPoint(
                x: origin.x + points[2].x,
                y: origin.y + points[2].y
            ),
            control: CGPoint(
                x: origin.x + points[1].x,
                y: origin.y + points[1].y
            )
        )

        return path
    }
}

extension HairStrand: View {
    var body: some View {
        self.stroke(
            Color("HairGold"),
            style: StrokeStyle(lineWidth: 7, lineCap: .round)
        )
        .overlay(
            self.stroke(
                Color("DiglettOutline"),
                style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
            )
        )
        .frame(width: 100, height: 100)
    }
}

/// 地鼠身體：上方圓弧、下方平底。
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
