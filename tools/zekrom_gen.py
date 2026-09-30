"""Zekrom drawing spec -> SVG preview + SwiftUI ContentView.swift + Assets colors.

Zekrom is traced from the official Black & White artwork (760 x 1000 px).
Design coordinates below are in that artwork's pixels; everything is scaled by
K = 0.5 into a 380 x 500 pt canvas for SwiftUI.

Two kinds of parts:
  poly  - custom `Outline` shape through a list of points (smooth=True rounds the corners)
  shape - built-in SwiftUI shape: frame (w, h), rotation, .position(x, y) inside the canvas
Background parts ("Sky") use .offset from the screen centre instead.

usage: python3 zekrom_gen.py svg OUT.svg [--ref REF.jpg] | swift OUT.swift | assets ASSETS_DIR
"""
import json, math, os, sys

W, H = 393, 852          # iPhone 15 screen in points
K = 0.5                  # artwork px -> canvas pt
CW, CH = 380, 500        # canvas size in pt
CANVAS_Y = 20            # canvas centre offset from screen centre

COLORS = {
    "StormSky": (0.60, 0.66, 0.76),
    "CloudGray": (0.44, 0.49, 0.59),
    "ZekromBody": (0.29, 0.33, 0.34),
    "ZekromShade": (0.13, 0.14, 0.15),
    "ZekromOutline": (0.04, 0.04, 0.05),
    "ZekromBlue": (0.29, 0.74, 0.93),
    "ZekromRed": (0.90, 0.30, 0.30),
}

GROUPS = {
    "Sky": ("StormBackdrop", "背景：雷雲、閃電、雨絲與岩石"),
    "BackWing": ("ZekromBackWing", "後方的小翅膀（被脖子擋住一半）"),
    "Tail": ("ZekromTail", "尾巴：圓形的渦輪發電機，右側有尖刺"),
    "LeftLeg": ("ZekromLeftLeg", "左腿：往左跨出去的大腿與腳"),
    "RightLeg": ("ZekromRightLeg", "右腿：大腿、膝蓋護甲、小腿與三根腳趾"),
    "LeftArm": ("ZekromLeftArm", "左手：往左下伸出的手臂與張開的手掌"),
    "Torso": ("ZekromTorso", "身體：胸膛、腹部與兩腿之間的腹甲"),
    "Head": ("ZekromHead", "脖子與頭：往後延伸的頭冠、藍色角尖、紅眼睛"),
    "FrontWing": ("ZekromFrontWing", "前方的大翅膀：像張開的手，由三片長條羽板組成"),
    "RightArm": ("ZekromRightArm", "右手：肩膀、舉起的拳頭與前臂護甲"),
}

parts = []


def poly(group, note, pts, fill="ZekromBody", smooth=False, stroke=True, opacity=None):
    parts.append((group, dict(kind="poly", note=note, pts=pts, fill=fill, smooth=smooth,
                              stroke=stroke, opacity=opacity)))


def shape(group, note, s, x, y, w, h, rot=0, fill="ZekromBody", stroke=None, **kw):
    parts.append((group, dict(kind="shape", note=note, shape=s, x=x, y=y, w=w, h=h, rot=rot,
                              fill=fill, stroke=stroke, **kw)))


def line(group, note, p, q, width, fill="ZekromBlue", **kw):
    """Thin capsule from p to q (artwork px) - used for the blue rim highlights."""
    (x1, y1), (x2, y2) = p, q
    L = math.hypot(x2 - x1, y2 - y1)
    rot = math.degrees(math.atan2(x2 - x1, -(y2 - y1)))
    rot = (rot + 90) % 180 - 90
    shape(group, note, "Capsule", (x1 + x2) / 2, (y1 + y2) / 2, width, L, rot, fill=fill, **kw)


OUT = True  # black outline

# ================= background (screen offsets, pt) =================
shape("Sky", "雷雲", "Ellipse", -110, -330, 280, 110, fill="CloudGray", opacity=0.8, sky=True)
shape("Sky", None, "Ellipse", 120, -350, 260, 100, fill="CloudGray", opacity=0.7, sky=True)
shape("Sky", None, "Capsule", 20, -300, 330, 70, fill="CloudGray", opacity=0.6, sky=True)
RAIN = [(-150, -150), (-90, 20), (160, -40), (130, 170), (-160, 190), (60, -230)]
shape("Sky", "雨絲：用 ForEach 把同一條細長方形放到不同位置", "Rectangle", 0, 0, 2, 60, 15,
      fill="ZekromOutline", opacity=0.15, sky=True, rain=RAIN)
shape("Sky", "藍色閃電（捷克羅姆的雷擊）", "Bolt", -150, -250, 44, 110, -12, fill="ZekromBlue", shadow=("ZekromBlue", 10), sky=True)
shape("Sky", "腳下的岩石", "RoundedRectangle", 0, 285, 360, 60, cr=24, fill="CloudGray", sky=True)

# ================= Zekrom (artwork px) =================
# --- back wing ---
poly("BackWing", "翅膀外形", [(222, 343), (160, 352), (95, 400), (106, 413), (150, 400), (122, 428),
                           (160, 430), (192, 412), (165, 442), (205, 446), (240, 420), (240, 380)])
poly("BackWing", "羽板之間的陰影", [(150, 400), (192, 386), (192, 412), (160, 430)], fill="ZekromShade", stroke=False)

# --- tail ---
poly("Tail", "尾巴後側的深色板與尖刺", [(615, 520), (655, 527), (685, 505), (682, 548), (668, 600),
                                     (672, 668), (648, 632), (620, 640)], fill="ZekromShade")
shape("Tail", "尾巴外殼", "Circle", 510, 638, 270, 270, stroke=OUT)
shape("Tail", "上方的排氣口", "Ellipse", 445, 585, 110, 48, rot=-8, fill="ZekromShade", stroke=OUT)
shape("Tail", "渦輪扇葉的開口（放射漸層，中心透出藍光）", "Ellipse", 540, 672, 128, 158, fill="FAN", stroke=OUT)
for i, d in enumerate([0.78, 0.56, 0.34]):
    shape("Tail", "同心圓的扇葉格柵" if i == 0 else None, "Ellipse", 540, 672, 128 * d, 158 * d,
          fill=None, stroke=("ZekromOutline", 1))
shape("Tail", "發電中的藍光", "Circle", 540, 672, 22, 22, fill="ZekromBlue", shadow=("ZekromBlue", 12))
shape("Tail", "用 trim 畫出外殼上的弧線", "Circle", 510, 638, 230, 230, fill=None, trim=(0.55, 0.95),
      stroke=("ZekromOutline", 1.5), rot=0)

# --- left leg ---
poly("LeftLeg", "大腿", [(245, 622), (165, 668), (115, 700), (88, 735), (85, 762), (110, 782), (150, 778),
                        (215, 762), (285, 755), (300, 690)], smooth=True)
poly("LeftLeg", "腳", [(128, 778), (205, 782), (224, 778), (213, 800), (230, 848), (165, 862), (80, 874),
                      (80, 860), (105, 838), (128, 802)])
poly("LeftLeg", "腳背的深色護甲", [(150, 800), (205, 795), (222, 845), (170, 858)], fill="ZekromShade", stroke=False)
line("LeftLeg", "藍色反光", (100, 722), (168, 676), 5)

# --- right leg ---
poly("RightLeg", "大腿", [(320, 590), (395, 640), (445, 690), (474, 752), (466, 800), (440, 814),
                         (385, 812), (348, 790), (322, 740)], smooth=True)
poly("RightLeg", "膝蓋的深色護甲", [(362, 682), (440, 692), (470, 750), (446, 802), (392, 810), (362, 788)],
     fill="ZekromShade")
line("RightLeg", None, (385, 710), (398, 760), 5)
poly("RightLeg", "小腿與腳掌", [(468, 792), (556, 792), (598, 870), (622, 935), (622, 985), (400, 985),
                           (404, 925), (438, 885), (468, 840)])
for i, (x, r) in enumerate([(432, -8), (502, 0), (586, 8)]):
    shape("RightLeg", "三根腳趾：上圓下平的 UnevenRoundedRectangle" if i == 0 else None, "Uneven",
          x, 948, 58, 78, r, radii=(29, 8, 8, 29), stroke=OUT)
    line("RightLeg", "腳趾上的藍色反光" if i == 0 else None, (x + 2, 925), (x + 4, 965), 5)

# --- left arm ---
poly("LeftArm", "手臂", [(190, 410), (232, 430), (234, 470), (222, 512), (206, 538), (220, 545), (202, 560),
                        (200, 576), (150, 596), (120, 612), (110, 630), (92, 650), (80, 652), (60, 640),
                        (50, 655), (40, 652), (15, 645), (10, 625), (50, 580), (100, 552), (150, 537),
                        (168, 522), (170, 470)])
poly("LeftArm", "掌心", [(56, 592), (112, 574), (112, 608), (88, 640), (62, 630)], fill="ZekromShade", stroke=False)
for i, (x, y) in enumerate([(88, 592), (66, 614), (92, 622)]):
    shape("LeftArm", "手指" if i == 0 else None, "Ellipse", x, y, 18, 24, rot=30, fill="ZekromBody", stroke=OUT)
line("LeftArm", "藍色反光", (30, 600), (90, 562), 5)

# --- torso ---
poly("Torso", "兩腿之間的腹甲", [(228, 560), (335, 555), (352, 620), (346, 700), (352, 758), (300, 776),
                             (250, 760), (224, 690), (218, 610)], smooth=True)
line("Torso", "腹甲上的藍線", (262, 600), (252, 740), 4)
line("Torso", None, (305, 600), (318, 745), 4)
poly("Torso", "胸膛與腰", [(215, 360), (195, 395), (185, 440), (200, 470), (226, 500), (240, 562),
                         (335, 560), (338, 520), (362, 472), (410, 452), (445, 415), (450, 350), (430, 312),
                         (380, 302), (320, 316), (290, 300), (275, 340)])
poly("Torso", "腰部的深色 V 字", [(242, 500), (312, 498), (306, 540), (275, 585), (250, 560)], fill="ZekromShade")
poly("Torso", "胸肌的深色護甲", [(310, 350), (345, 330), (392, 340), (400, 376), (372, 402), (320, 396)],
     fill="ZekromShade")
poly("Torso", None, [(196, 420), (216, 404), (238, 424), (232, 470), (208, 468)], fill="ZekromShade")
line("Torso", "胸口的藍線", (290, 400), (268, 492), 4)

# --- neck + head ---
poly("Head", "脖子", [(210, 300), (248, 278), (282, 288), (292, 340), (282, 395), (236, 410), (216, 360)])
line("Head", None, (232, 320), (236, 390), 4)
poly("Head", "頭與往後延伸的頭冠", [(138, 275), (148, 235), (168, 210), (182, 205), (186, 222), (206, 200),
                             (226, 191), (256, 192), (282, 198), (300, 214), (322, 218), (345, 207),
                             (375, 213), (407, 227), (372, 224), (360, 224), (355, 246), (338, 240),
                             (318, 246), (298, 248), (280, 246), (270, 262), (256, 272), (252, 300),
                             (215, 314), (178, 306), (155, 290)])
poly("Head", "下巴的深色面甲", [(160, 264), (262, 272), (252, 300), (215, 312), (178, 305), (156, 288)],
     fill="ZekromShade")
poly("Head", "頭冠尖端的藍色", [(378, 214), (407, 227), (378, 223)], fill="ZekromBlue", stroke=False)
line("Head", "頭頂的藍色反光", (152, 240), (175, 212), 5)
line("Head", None, (228, 194), (280, 200), 4)
shape("Head", "紅色眼睛", "Ellipse", 207, 231, 30, 13, rot=-15, fill="ZekromRed", stroke=OUT)
shape("Head", "瞳孔", "Circle", 203, 231, 7, 7, fill="ZekromOutline")

# --- front wing ---
poly("FrontWing", "翅膀外形", [(462, 320), (446, 290), (448, 215), (405, 210), (440, 178), (510, 110),
                             (600, 68), (752, 12), (746, 58), (700, 84), (712, 120), (734, 120),
                             (722, 180), (700, 186), (692, 240), (676, 283), (510, 300), (472, 312)])
poly("FrontWing", "羽板之間的陰影", [(552, 150), (690, 84), (706, 122)], fill="ZekromShade")
poly("FrontWing", None, [(552, 232), (700, 184), (692, 240)], fill="ZekromShade")
line("FrontWing", "翅膀前緣的藍色反光", (420, 205), (500, 118), 5)
line("FrontWing", None, (530, 100), (740, 16), 4)

# --- right arm ---
poly("RightArm", "肩膀", [(362, 286), (430, 296), (456, 338), (440, 372), (392, 360), (366, 330)], smooth=True)
poly("RightArm", "上臂", [(420, 340), (476, 330), (496, 380), (476, 425), (432, 414), (410, 380)], smooth=True)
poly("RightArm", "前臂護甲", [(510, 362), (636, 372), (652, 446), (640, 525), (606, 570), (550, 562),
                            (540, 500), (500, 470)])
poly("RightArm", None, [(560, 442), (622, 430), (612, 468)], fill="ZekromShade", stroke=False)
line("RightArm", None, (560, 368), (632, 374), 4)
shape("RightArm", "拳頭", "Ellipse", 515, 420, 92, 126, rot=-10, stroke=OUT)
shape("RightArm", "指節", "Circle", 498, 366, 36, 36, stroke=OUT)
poly("RightArm", "爪子", [(530, 404), (505, 414), (528, 426)], fill="ZekromShade")
poly("RightArm", None, [(496, 466), (464, 480), (494, 482)], fill="ZekromShade")


# ======================== SVG preview ========================
def rgb(name):
    r, g, b = COLORS[name]
    return f"rgb({int(r*255)},{int(g*255)},{int(b*255)})"


def smooth_d(pts):
    n = len(pts)
    mid = lambda a, b: ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
    s = mid(pts[-1], pts[0])
    d = f"M{s[0]},{s[1]}"
    for i in range(n):
        m = mid(pts[i], pts[(i + 1) % n])
        d += f" Q{pts[i][0]},{pts[i][1]} {m[0]},{m[1]}"
    return d + "Z"


def canvas_pts(p):
    return [(round(x * K), round(y * K)) for x, y in p["pts"]]


def svg_fill(f):
    return {"FAN": "url(#fan)", None: "none"}.get(f) or rgb(f)


def svg_part(p):
    attrs = f'fill="{svg_fill(p["fill"])}"'
    if p.get("opacity"):
        attrs += f' opacity="{p["opacity"]}"'
    st = p.get("stroke")
    if st:
        c, w = st if isinstance(st, tuple) else ("ZekromOutline", 1.5)
        attrs += f' stroke="{rgb(c)}" stroke-width="{w}" stroke-linejoin="round"'
    if p.get("shadow"):
        attrs += f' filter="url(#sh_{p["shadow"][0]})"'
    if p["kind"] == "poly":
        pts = canvas_pts(p)
        d = smooth_d(pts) if p["smooth"] else "M" + " L".join(f"{x},{y}" for x, y in pts) + "Z"
        return f'<path d="{d}" {attrs}/>'
    s = p["shape"]
    if p.get("sky"):
        x, y, w, h = W / 2 + p["x"], H / 2 + p["y"], p["w"], p["h"]
    else:
        x, y, w, h = p["x"] * K, p["y"] * K, p["w"] * K, p["h"] * K
    if s in ("Ellipse", "Circle"):
        rx, ry = (min(w, h) / 2,) * 2 if s == "Circle" else (w / 2, h / 2)
        if p.get("trim"):
            a, b = p["trim"]
            c = 2 * math.pi * rx
            attrs = attrs.replace('fill="none"', 'fill="none" stroke-dasharray="0 %s %s %s"' % (c * a, c * (b - a), c))
        body = f'<ellipse cx="0" cy="0" rx="{rx}" ry="{ry}"/>'
    elif s == "Bolt":
        pts = [(0.55, 0), (0.1, 0.55), (0.45, 0.55), (0.3, 1), (0.9, 0.4), (0.55, 0.4), (0.85, 0)]
        body = '<polygon points="%s"/>' % " ".join(f"{(u-.5)*w},{(v-.5)*h}" for u, v in pts)
    else:
        r = {"Capsule": min(w, h) / 2, "RoundedRectangle": p.get("cr", 0),
             "Uneven": p.get("radii", (0,))[0] * K * 0.8}.get(s, 0)
        body = f'<rect x="{-w/2}" y="{-h/2}" width="{w}" height="{h}" rx="{r}"/>'
    return f'<g transform="translate({x},{y}) rotate({p["rot"]})" {attrs}>{body}</g>'


def svg(ref=None):
    ox, oy = (W - CW) / 2, (H - CH) / 2 + CANVAS_Y
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
           '<defs><radialGradient id="fan"><stop offset="0" stop-color="%s"/>'
           '<stop offset="0.35" stop-color="%s"/><stop offset="1" stop-color="%s"/></radialGradient>'
           % (rgb("ZekromBlue"), rgb("ZekromShade"), rgb("ZekromOutline"))]
    for c in COLORS:
        out.append(f'<filter id="sh_{c}" x="-1" y="-1" width="3" height="3"><feDropShadow dx="0" dy="0" '
                   f'stdDeviation="5" flood-color="{rgb(c)}"/></filter>')
    out.append(f'</defs><rect width="{W}" height="{H}" fill="{rgb("StormSky")}"/>')
    for g, p in parts:
        if g == "Sky":
            out += [svg_part(dict(p, x=x, y=y)) for x, y in p.get("rain", [(p["x"], p["y"])])]
    out.append(f'<g transform="translate({ox},{oy})">')
    out += [svg_part(p) for g, p in parts if g != "Sky"]
    if ref:
        out.append(f'<image href="{ref}" width="{CW}" height="{CH}" opacity="0.45"/>')
    out.append("</g></svg>")
    return "\n".join(out)


# ======================== SwiftUI code ========================
def lower(name):
    return name[0].lower() + name[1:]


def n(v):
    v = round(v * 2) / 2
    return str(int(v)) if float(v).is_integer() else f"{v:g}"


def swift_stroke(st):
    c, w = st if isinstance(st, tuple) else ("ZekromOutline", 1.5)
    return f".stroke(Color.{lower(c)}, style: StrokeStyle(lineWidth: {n(w)}, lineJoin: .round))"


def swift_part(p, ind):
    L = []
    if p["kind"] == "poly":
        pts = [f"({x}, {y})" for x, y in canvas_pts(p)]
        arg = ", smooth: true" if p["smooth"] else ""
        if len(pts) <= 6:
            L.append(f"Outline([{', '.join(pts)}]{arg})")
        else:
            L.append("Outline([")
            L += ["    " + ", ".join(pts[i:i + 6]) + "," for i in range(0, len(pts), 6)]
            L[-1] = L[-1].rstrip(",")
            L.append(f"]{arg})")
        L.append(f"    .fill(Color.{lower(p['fill'])})")
        if p["stroke"]:
            L.append("    " + swift_stroke(True))
        if p.get("opacity"):
            L.append(f"    .opacity({p['opacity']})")
        return [ind + l for l in L]

    s, sky = p["shape"], p.get("sky")
    f = (lambda v: v) if sky else (lambda v: v * K)
    if s == "Uneven":
        tl, bl, br, tr = [round(r * K) for r in p["radii"]]
        L.append(f"UnevenRoundedRectangle(topLeadingRadius: {tl}, bottomLeadingRadius: {bl}, "
                 f"bottomTrailingRadius: {br}, topTrailingRadius: {tr})")
    elif s == "RoundedRectangle":
        L.append(f"RoundedRectangle(cornerRadius: {p['cr']})")
    else:
        L.append(f"{s}()")
    if p.get("trim"):
        L.append(f"    .trim(from: {p['trim'][0]}, to: {p['trim'][1]})")
    if p["fill"] == "FAN":
        L.append("    .fill(RadialGradient(colors: [Color.zekromBlue, Color.zekromShade, Color.zekromOutline],")
        L.append(f"                         center: .center, startRadius: 0, endRadius: {n(p['h'] * K / 2)}))")
    elif p["fill"]:
        L.append(f"    .fill(Color.{lower(p['fill'])})")
    if p["stroke"]:
        L.append("    " + swift_stroke(p["stroke"]))
    L.append(f"    .frame(width: {n(f(p['w']))}, height: {n(f(p['h']))})")
    if p["rot"]:
        L.append(f"    .rotationEffect(.degrees({n(p['rot'])}))")
    if p.get("rain"):
        L.append("    .offset(x: spot.x, y: spot.y)")
    elif sky:
        L.append(f"    .offset(x: {n(p['x'])}, y: {n(p['y'])})" if p["x"] else f"    .offset(y: {n(p['y'])})")
    else:
        L.append(f"    .position(x: {n(f(p['x']))}, y: {n(f(p['y']))})")
    if p.get("opacity"):
        L.append(f"    .opacity({p['opacity']})")
    if p.get("shadow"):
        L.append(f"    .shadow(color: Color.{lower(p['shadow'][0])}, radius: {p['shadow'][1]})")
    if p.get("rain"):
        spots = ", ".join(f"CGPoint(x: {x}, y: {y})" for x, y in p["rain"][:3])
        spots2 = ", ".join(f"CGPoint(x: {x}, y: {y})" for x, y in p["rain"][3:])
        L = ["ForEach([", f"    {spots},", f"    {spots2}", "], id: \\.x) { spot in"] + ["    " + l for l in L] + ["}"]
    return [ind + l for l in L]


def swift_group(g):
    name, doc = GROUPS[g]
    out = [f"// MARK: - {doc}", "", f"struct {name}: View {{", "    var body: some View {", "        ZStack {"]
    for gg, p in parts:
        if gg != g:
            continue
        if p["note"]:
            out.append(f"            // {p['note']}")
        out += swift_part(p, " " * 12)
    out += ["        }", "    }", "}", ""]
    return out


SWIFT_HEAD = f'''//
//  ContentView.swift
//  ZekromShapes
//
//  #206 參考 Apple 的 Build with Stacks and Shapes，用形狀畫出捷克羅姆（Zekrom）。
//  參考寶可夢官方繪圖描出外形：大部位用自訂的 Outline 形狀，細節用內建形狀。
//  所有顏色都在 Assets.xcassets 以 RGB 設定，Xcode 會自動產生 Color.zekromBody 這類名稱。
//

import SwiftUI

struct ContentView: View {{
    var body: some View {{
        ZStack {{
            // 全螢幕背景：Assets 裡的 StormSky（暴風雨的天空）
            Color.stormSky
                .ignoresSafeArea()

            StormBackdrop()

            // 捷克羅姆：在 {CW} x {CH} 的畫布裡由後往前疊，後面的部位先畫
            ZStack {{
{chr(10).join(" " * 16 + GROUPS[g][0] + "()" for g in GROUPS if g != "Sky")}
            }}
            .frame(width: {CW}, height: {CH})
            .offset(y: {CANVAS_Y})
        }}
    }}
}}

// MARK: - 自訂形狀

/// 依序連起畫布上的點圍成的外形；smooth 為 true 時用二次曲線把轉角修圓。
struct Outline: Shape {{
    var points: [CGPoint]
    var smooth = false

    init(_ points: [(CGFloat, CGFloat)], smooth: Bool = false) {{
        self.points = points.map {{ CGPoint(x: $0.0, y: $0.1) }}
        self.smooth = smooth
    }}

    func path(in rect: CGRect) -> Path {{
        var path = Path()
        guard let last = points.last else {{ return path }}
        if smooth {{
            // 從最後一段的中點出發，每個點當控制點、畫到下一段的中點
            path.move(to: midpoint(last, points[0]))
            for i in points.indices {{
                let next = points[(i + 1) % points.count]
                path.addQuadCurve(to: midpoint(points[i], next), control: points[i])
            }}
        }} else {{
            path.addLines(points)
        }}
        path.closeSubpath()
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }}

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {{
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }}
}}

/// 閃電
struct Bolt: Shape {{
    func path(in rect: CGRect) -> Path {{
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
    }}
}}
'''


def swift():
    out = [SWIFT_HEAD]
    for g in GROUPS:
        out += swift_group(g)
    out += ["#Preview {", "    ContentView()", "}", ""]
    return "\n".join(out)


def assets(root):
    for name, (r, g, b) in COLORS.items():
        d = os.path.join(root, f"{name}.colorset")
        os.makedirs(d, exist_ok=True)
        data = {"colors": [{"color": {"color-space": "srgb", "components": {
            "alpha": "1.000", "red": f"{r:.3f}", "green": f"{g:.3f}", "blue": f"{b:.3f}"}},
            "idiom": "universal"}], "info": {"author": "xcode", "version": 1}}
        with open(os.path.join(d, "Contents.json"), "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")


if __name__ == "__main__":
    mode, target = sys.argv[1], sys.argv[2]
    if mode == "svg":
        ref = sys.argv[4] if len(sys.argv) > 4 and sys.argv[3] == "--ref" else None
        open(target, "w").write(svg(ref))
    elif mode == "swift":
        open(target, "w").write(swift())
    elif mode == "assets":
        assets(target)
