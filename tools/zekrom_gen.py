"""Zekrom drawing spec -> SVG preview + SwiftUI ContentView.swift + Assets colors.

Coordinates follow SwiftUI ZStack semantics: origin at screen centre, y down.
Each part: shape, frame (w,h), rotation (deg, clockwise, around own centre), offset (x,y).
Parts marked sym=True are drawn at +x and mirrored to -x (ForEach over side = -1, 1).
All custom shapes are left-right symmetric, so mirroring = negate x offset and rotation.

usage: python3 gen.py svg OUT.svg | swift OUT.swift | assets ASSETS_DIR
"""
import json, math, os, sys

W, H = 393, 852  # iPhone 15 points
S = 0.9  # .scaleEffect on the Zekrom ZStack

COLORS = {
    "StormSky": (0.17, 0.20, 0.33),
    "CloudGray": (0.30, 0.33, 0.45),
    "BoltYellow": (1.00, 0.86, 0.30),
    "ZekromBlack": (0.12, 0.12, 0.14),
    "ZekromGray": (0.30, 0.31, 0.35),
    "ZekromEdge": (0.47, 0.49, 0.56),
    "ZekromRed": (0.95, 0.15, 0.25),
    "ZekromBlue": (0.30, 0.72, 1.00),
}

# custom shapes: unit-rect polygons, all symmetric about x = 0.5
POLYS = {
    "Blade": ("翅膀的羽刃：上尖下寬的五邊形", [(0.5, 0), (1, 0.3), (0.72, 1), (0.28, 1), (0, 0.3)]),
    "Spike": ("尖刺：三角形", [(0.5, 0), (1, 1), (0, 1)]),
    "Bolt": ("閃電", [(0.55, 0), (0.1, 0.55), (0.45, 0.55), (0.3, 1), (0.9, 0.4), (0.55, 0.4), (0.85, 0)]),
    "Crest": ("頭頂的大角冠", [(0.5, 0), (0.85, 0.55), (1, 1), (0.5, 0.8), (0, 1), (0.15, 0.55)]),
}

# group -> (struct name, comment)
GROUPS = {
    "Sky": ("StormBackdrop", "雷雲、閃電與腳下的岩石（不跟著 Zekrom 縮放）"),
    "Tail": ("ZekromTail", "尾巴：黑色尾巴加上發出藍光的發電機"),
    "Wing": ("ZekromWings", "翅膀：從肩膀伸出的骨架，末端展開四片羽刃"),
    "Legs": ("ZekromLegs", "雙腿：大腿、小腿、腳掌與腳爪"),
    "Body": ("ZekromTorso", "身體：脖子、軀幹、胸甲與腹甲"),
    "Arms": ("ZekromArms", "手臂：肩膀、上臂、前臂、手與爪子"),
    "Head": ("ZekromHead", "頭：角冠、側角、臉、口鼻與紅色眼睛"),
}

parts = []  # (group, dict)


def add(group, shape, w, h, x=0, y=0, rot=0, fill="ZekromBlack", note=None, **kw):
    parts.append((group, dict(shape=shape, w=w, h=h, x=x, y=y, rot=rot, fill=fill, note=note, **kw)))


def limb(group, shape, p, q, width, **kw):
    """Place a shape whose long axis runs from base p to top q."""
    (x1, y1), (x2, y2) = p, q
    L = math.hypot(x2 - x1, y2 - y1)
    rot = math.degrees(math.atan2(x2 - x1, -(y2 - y1)))
    if shape in ("Capsule", "Ellipse", "Rectangle", "RoundedRectangle"):
        rot = (rot + 90) % 180 - 90  # these look the same after a half turn
    add(group, shape, width, round(L), round((x1 + x2) / 2), round((y1 + y2) / 2), round(rot), **kw)


def polar(p, deg, L):
    return (p[0] + L * math.sin(math.radians(deg)), p[1] - L * math.cos(math.radians(deg)))


EDGE = ("ZekromEdge", 2)

# ---------------- background: clouds + bolts ----------------
add("Sky", "Ellipse", 260, 90, -120, -330, fill="CloudGray", opacity=0.6, note="雷雲")
add("Sky", "Ellipse", 220, 80, 130, -350, fill="CloudGray", opacity=0.5)
add("Sky", "Capsule", 300, 60, 40, -300, fill="CloudGray", opacity=0.4)
add("Sky", "Bolt", 50, 120, -150, -350, rot=-10, fill="BoltYellow", shadow=("BoltYellow", 12), note="閃電（加黃色陰影當作發光）")
add("Sky", "Bolt", 40, 100, 160, -330, rot=15, fill="BoltYellow", shadow=("BoltYellow", 10), opacity=0.85)
add("Sky", "Capsule", 340, 44, 0, 272, fill="CloudGray", opacity=0.8, note="腳下的岩石")

# ---------------- tail: turbine generator ----------------
limb("Tail", "Capsule", (40, 150), (140, 230), 56, stroke=EDGE, note="尾巴")
add("Tail", "Circle", 100, 100, 140, 230, stroke=("ZekromEdge", 3), note="發電機外殼")
add("Tail", "Circle", 64, 64, 140, 230, fill="GLOW", shadow=("ZekromBlue", 20), note="發電機核心：白到藍的放射漸層＋藍色光暈")
add("Tail", "RingTrim", 82, 82, 140, 230, fill="ZekromBlue", trim=(0.1, 0.9), lw=5, rot=-40, note="用 trim 剪掉一段的藍色電流環")

# ---------------- wings ----------------
shoulder = (62, -95)
wrist = polar(shoulder, 45, 100)
limb("Wing", "Capsule", shoulder, wrist, 30, sym=True, stroke=EDGE, note="翅膀骨架")
for deg, L in [(-22, 165), (2, 150), (26, 128), (50, 100)]:
    limb("Wing", "Blade", wrist, polar(wrist, deg, L), 32, sym=True, stroke=EDGE, note="四片羽刃，由內往外展開")
add("Wing", "Circle", 34, 34, round(wrist[0]), round(wrist[1]), sym=True, fill="ZekromGray", note="翅膀關節")

# ---------------- legs ----------------
add("Legs", "Ellipse", 96, 130, 55, 140, rot=-8, sym=True, stroke=EDGE, note="大腿")
add("Legs", "Capsule", 30, 60, 50, 120, rot=-8, sym=True, fill="ZekromGray", opacity=0.9, note="大腿上的灰色護甲")
add("Legs", "RoundedRectangle", 58, 90, 64, 215, rot=5, cr=22, sym=True, stroke=EDGE, note="小腿")
add("Legs", "Uneven", 86, 38, 70, 264, radii=(19, 6, 6, 19), sym=True, fill="ZekromGray", note="腳掌：上方圓角大、下方圓角小")
for dx in (-26, 0, 26):
    add("Legs", "Capsule", 14, 26, 70 + dx, 285, sym=True, fill="ZekromEdge", note="三根腳爪")

# ---------------- body ----------------
add("Body", "Rectangle", 50, 60, 0, -115, note="脖子")
add("Body", "RoundedRectangle", 150, 210, 0, 20, cr=55, stroke=EDGE, note="軀幹")
add("Body", "Uneven", 110, 70, 0, -45, radii=(40, 12, 12, 40), fill="ZekromGray", note="胸甲")
for i, yy in enumerate([35, 68, 99]):
    add("Body", "Capsule", 84 - i * 12, 22, 0, yy, fill="ZekromGray", note="三片腹甲，越往下越窄")

# ---------------- arms ----------------
sh, el, wr = (82, -70), (115, 20), (110, 105)
add("Arms", "Circle", 64, 64, sh[0], sh[1], sym=True, stroke=EDGE, note="肩膀")
limb("Arms", "Capsule", sh, el, 42, sym=True, stroke=EDGE, note="上臂")
limb("Arms", "Capsule", el, wr, 52, sym=True, stroke=EDGE, note="前臂")
limb("Arms", "Spike", el, polar(el, 150, 70), 20, sym=True, fill="ZekromGray", note="手肘的刃")
add("Arms", "Circle", 44, 44, wr[0], wr[1] + 12, sym=True, fill="ZekromGray", note="手")
hand = (wr[0], wr[1] + 14)
for d in (-30, 0, 30):
    limb("Arms", "Spike", hand, polar(hand, 180 + d, 44), 12, sym=True, fill="ZekromEdge", note="三根爪子")

# ---------------- head ----------------
add("Head", "Crest", 70, 120, 0, -228, stroke=EDGE, note="頭頂角冠")
limb("Head", "Spike", (30, -185), polar((30, -185), 50, 55), 22, sym=True, stroke=EDGE, note="兩側的角")
add("Head", "Ellipse", 96, 86, 0, -170, stroke=EDGE, note="臉")
add("Head", "RoundedRectangle", 60, 50, 0, -138, cr=22, stroke=EDGE, note="口鼻")
add("Head", "Capsule", 30, 4, 0, -126, fill="ZekromGray", note="嘴巴")
add("Head", "Ellipse", 20, 9, 22, -172, rot=18, sym=True, fill="ZekromRed", shadow=("ZekromRed", 6), note="發光的紅眼睛")


# =================== SVG preview ===================
def rgb(name):
    r, g, b = COLORS[name]
    return f"rgb({int(r*255)},{int(g*255)},{int(b*255)})"


def svg_shape(p):
    w, h, s = p["w"], p["h"], p["shape"]
    if s in ("Ellipse", "Circle"):
        rx, ry = (min(w, h) / 2,) * 2 if s == "Circle" else (w / 2, h / 2)
        return f'<ellipse cx="0" cy="0" rx="{rx}" ry="{ry}"/>'
    if s in ("Rectangle", "RoundedRectangle", "Capsule", "Uneven"):
        r = {"Rectangle": 0, "RoundedRectangle": p.get("cr", 0), "Capsule": min(w, h) / 2}.get(s, 0)
        if s == "Uneven":
            r = max(p["radii"]) * 0.6
        return f'<rect x="{-w/2}" y="{-h/2}" width="{w}" height="{h}" rx="{r}"/>'
    if s == "RingTrim":
        a, b = p["trim"]
        c = math.pi * w
        return (f'<circle cx="0" cy="0" r="{w/2}" fill="none" stroke="{rgb(p["fill"])}" stroke-width="{p["lw"]}" '
                f'stroke-linecap="round" stroke-dasharray="0 {c*a} {c*(b-a)} {c}"/>')
    pts = " ".join(f"{(u-0.5)*w},{(v-0.5)*h}" for u, v in POLYS[s][1])
    return f'<polygon points="{pts}"/>'


def svg_part(p, side):
    x, rot = p["x"] * side, p["rot"] * side
    fill = "url(#glow)" if p["fill"] == "GLOW" else rgb(p["fill"])
    attrs = f'fill="{fill}" opacity="{p.get("opacity", 1)}"'
    if "stroke" in p:
        attrs += f' stroke="{rgb(p["stroke"][0])}" stroke-width="{p["stroke"][1]}"'
    if "shadow" in p:
        attrs += f' filter="url(#sh_{p["shadow"][0]})"'
    return f'<g transform="translate({W/2 + x},{H/2 + p["y"]}) rotate({rot})" {attrs}>{svg_shape(p)}</g>'


def svg():
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
           '<defs><radialGradient id="glow"><stop offset="0" stop-color="white"/>'
           f'<stop offset="1" stop-color="{rgb("ZekromBlue")}"/></radialGradient>']
    for c in COLORS:
        out.append(f'<filter id="sh_{c}" x="-1" y="-1" width="3" height="3"><feDropShadow dx="0" dy="0" stdDeviation="6" flood-color="{rgb(c)}"/></filter>')
    out.append(f'</defs><rect width="{W}" height="{H}" fill="{rgb("StormSky")}"/>')
    out += [svg_part(p, 1) for g, p in parts if g == "Sky"]
    out.append(f'<g transform="translate({W/2},{H/2}) scale({S}) translate({-W/2},{-H/2})">')
    for g, p in parts:
        if g == "Sky":
            continue
        if p.get("sym"):
            out.append(svg_part(p, -1))
        out.append(svg_part(p, 1))
    out.append("</g></svg>")
    return "\n".join(out)


# =================== SwiftUI code ===================
def lower(name):
    return name[0].lower() + name[1:]


def n(v):
    return str(int(v)) if float(v).is_integer() else f"{v:g}"


def swift_part(p, ind):
    s, sym = p["shape"], p.get("sym")
    sx = lambda v: f"{n(v)} * side" if sym and v != 0 else n(v)
    lines = []
    if s == "Uneven":
        tl, bl, br, tr = p["radii"]
        lines.append(f"UnevenRoundedRectangle(topLeadingRadius: {tl}, bottomLeadingRadius: {bl}, "
                     f"bottomTrailingRadius: {br}, topTrailingRadius: {tr})")
    elif s == "RoundedRectangle":
        lines.append(f"RoundedRectangle(cornerRadius: {p['cr']})")
    elif s == "RingTrim":
        a, b = p["trim"]
        lines.append("Circle()")
        lines.append(f"    .trim(from: {a}, to: {b})")
        lines.append(f"    .stroke(Color.{lower(p['fill'])}, style: StrokeStyle(lineWidth: {p['lw']}, lineCap: .round))")
    else:
        lines.append(f"{s}()")
    if s != "RingTrim":
        if p["fill"] == "GLOW":
            lines.append("    .fill(RadialGradient(colors: [.white, Color.zekromBlue], center: .center, startRadius: 2, endRadius: 32))")
        else:
            lines.append(f"    .fill(Color.{lower(p['fill'])})")
    if "stroke" in p:
        lines.append(f"    .stroke(Color.{lower(p['stroke'][0])}, lineWidth: {p['stroke'][1]})")
    lines.append(f"    .frame(width: {n(p['w'])}, height: {n(p['h'])})")
    if p["rot"]:
        lines.append(f"    .rotationEffect(.degrees({sx(p['rot'])}))")
    if p["x"]:
        lines.append(f"    .offset(x: {sx(p['x'])}, y: {n(p['y'])})")
    else:
        lines.append(f"    .offset(y: {n(p['y'])})")
    if "opacity" in p:
        lines.append(f"    .opacity({p['opacity']})")
    if "shadow" in p:
        lines.append(f"    .shadow(color: Color.{lower(p['shadow'][0])}, radius: {p['shadow'][1]})")
    return [ind + l for l in lines]


def swift_group(g):
    name, doc = GROUPS[g]
    out = [f"// MARK: - {doc}", "", f"struct {name}: View {{", "    var body: some View {", "        ZStack {"]
    items = [p for gg, p in parts if gg == g]
    i, last_note = 0, None
    while i < len(items):
        if items[i].get("sym"):
            j = i
            while j < len(items) and items[j].get("sym"):
                j += 1
            out.append("            // 左右各畫一次：side = -1 是左邊、1 是右邊")
            out.append("            ForEach(sides, id: \\.self) { side in")
            for p in items[i:j]:
                if p["note"] and p["note"] != last_note:
                    out.append(f"                // {p['note']}")
                    last_note = p["note"]
                out += swift_part(p, " " * 16)
            out.append("            }")
            i = j
        else:
            p = items[i]
            if p["note"] and p["note"] != last_note:
                out.append(f"            // {p['note']}")
                last_note = p["note"]
            out += swift_part(p, " " * 12)
            i += 1
    out += ["        }", "    }", "}", ""]
    return out


def swift_poly(name):
    doc, pts = POLYS[name]
    out = [f"// {doc}", f"struct {name}: Shape {{", "    func path(in rect: CGRect) -> Path {", "        var path = Path()"]
    for k, (u, v) in enumerate(pts):
        fn = "move" if k == 0 else "addLine"
        out.append(f"        path.{fn}(to: CGPoint(x: rect.width * {u}, y: rect.height * {v}))")
    out += ["        path.closeSubpath()", "        return path", "    }", "}", ""]
    return out


def swift():
    out = ["//",
           "//  ContentView.swift",
           "//  ZekromShapes",
           "//",
           "//  #206 參考 Apple 的 Build with Stacks and Shapes，用形狀畫出捷克羅姆（Zekrom）。",
           "//  所有顏色都在 Assets.xcassets 以 RGB 設定，Xcode 會自動產生 Color.zekromBlack 這類名稱。",
           "//",
           "",
           "import SwiftUI",
           "",
           "/// 左右對稱的部位用 ForEach 畫兩次：x 位移與旋轉角度乘上 side 就會左右翻轉。",
           "let sides: [CGFloat] = [-1, 1]",
           "",
           "struct ContentView: View {",
           "    var body: some View {",
           "        ZStack {",
           "            // 全螢幕背景：Assets 裡的 StormSky（暴風雨夜空）",
           "            Color.stormSky",
           "                .ignoresSafeArea()",
           "",
           "            StormBackdrop()",
           "",
           "            // Zekrom 本體：由後往前疊，後面的部位先畫",
           "            ZStack {",
           "                ZekromTail()",
           "                ZekromWings()",
           "                ZekromLegs()",
           "                ZekromTorso()",
           "                ZekromArms()",
           "                ZekromHead()",
           "            }",
           f"            .scaleEffect({S})",
           "        }",
           "    }",
           "}",
           ""]
    for g in GROUPS:
        out += swift_group(g)
    out.append("// MARK: - 自訂形狀（座標以 rect 的寬高比例表示）")
    out.append("")
    for name in POLYS:
        out += swift_poly(name)
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
        open(target, "w").write(svg())
    elif mode == "swift":
        open(target, "w").write(swift())
    elif mode == "assets":
        assets(target)
