"""Generates Fade brand SVGs. Geometry is hand-authored on a 100-unit cap-height grid.
All letterforms are filled paths (no <text>), so they render identically everywhere."""
import os, sys
OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)

INK = "#0B0B0C"; GOLD = "#F5B82E"; BONE = "#F6F3EC"

def fmt(v):
    s = f"{v:.2f}".rstrip('0').rstrip('.')
    return s

def rect(x, y, w, h):
    return f"M{fmt(x)} {fmt(y)}h{fmt(w)}v{fmt(h)}h{fmt(-w)}z"

# ---- F with "fade" stem: solid top, stem dissolves into slices of shrinking height
def glyph_F(ox=0, slices=((68, 11), (83, 8), (95, 5)), stem_end=64, stroke=22, top_w=62, mid_w=54, mid=(40, 60)):
    p = [
        # top arm + stem (one contour)
        f"M{fmt(ox)} 0h{fmt(top_w)}v{fmt(stroke)}h{fmt(-(top_w-stroke))}v{fmt(mid[0]-stroke)}"
        f"h{fmt(mid_w-stroke)}v{fmt(mid[1]-mid[0])}h{fmt(-(mid_w-stroke))}v{fmt(stem_end-mid[1])}h{fmt(-stroke)}z"
    ]
    for y, h in slices:
        p.append(rect(ox, y, stroke, h))
    return "".join(p)

def glyph_A(ox=0):
    # outer: feet at y=100, flat apex 30..58; counter triangle; crossbar 60..78
    pts = [(0,100),(30,0),(58,0),(88,100),(64,100),(57.4,78),(30.6,78),(24,100)]
    outer = "M" + "L".join(f"{fmt(x+ox)} {fmt(y)}" for x,y in pts) + "z"
    cpts = [(44,33.33),(52,60),(36,60)]
    counter = "M" + "L".join(f"{fmt(x+ox)} {fmt(y)}" for x,y in cpts) + "z"
    return outer + counter

def glyph_D(ox=0):
    outer = f"M{fmt(ox)} 0H{fmt(ox+38)}A50 50 0 0 1 {fmt(ox+38)} 100H{fmt(ox)}z"
    counter = f"M{fmt(ox+22)} 22H{fmt(ox+38)}A28 28 0 0 1 {fmt(ox+38)} 78H{fmt(ox+22)}z"
    return outer + counter

def glyph_E(ox=0):
    return (f"M{fmt(ox)} 0h62v22h-40v17h34v22h-34v17h40v22h-62z")

# Wordmark layout (cap height 100)
F_X, A_X, D_X, E_X = 0, 66, 166, 268
WORD_W = E_X + 62
def wordmark_path():
    return glyph_F(F_X) + glyph_A(A_X) + glyph_D(D_X) + glyph_E(E_X)

def svg(w, h, body, vb=None, title="Fade"):
    vb = vb or f"0 0 {fmt(w)} {fmt(h)}"
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}" width="{fmt(w)}" height="{fmt(h)}" role="img" aria-label="{title}">\n'
            f'  <title>{title}</title>\n{body}\n</svg>\n')

def write(name, content):
    with open(os.path.join(OUT, name), "w") as f: f.write(content)

pad = 0  # wordmarks are tight-cropped; give clear space in layout, not in the file
for name, fill, f_fill in [("fade-wordmark-on-dark.svg", BONE, GOLD), ("fade-wordmark-on-light.svg", INK, INK),
                           ("fade-wordmark-mono-white.svg", "#FFFFFF", "#FFFFFF"), ("fade-wordmark-mono-black.svg", "#000000", "#000000")]:
    body = (f'  <path fill="{f_fill}" fill-rule="evenodd" d="{glyph_F(F_X)}"/>\n'
            f'  <path fill="{fill}" fill-rule="evenodd" d="{glyph_A(A_X) + glyph_D(D_X) + glyph_E(E_X)}"/>')
    write(name, svg(WORD_W, 100, body, title="Fade"))

# Logomark: the fading F alone (62 x 100 glyph)
for name, fill in [("fade-logomark-gold.svg", GOLD), ("fade-logomark-ink.svg", INK), ("fade-logomark-white.svg", "#FFFFFF")]:
    write(name, svg(62, 100, f'  <path fill="{fill}" d="{glyph_F()}"/>', title="Fade logomark"))

# Icon geometry: glyph scaled to ~54% of canvas height, optically centred (shift right a touch
# because the F's mass sits left).
ICON_SLICES = ((69, 12), (86, 8))  # fewer, bolder slices so the fade survives at 48px
def icon_glyph(canvas, scale_h=0.58, dx_opt=0.02):
    s = canvas * scale_h / 100.0
    gw = 62 * s
    x0 = (canvas - gw) / 2 + canvas * dx_opt
    y0 = (canvas - 100 * s) / 2 + canvas * 0.0
    d = glyph_F(slices=ICON_SLICES, stem_end=63)
    return f'<path transform="translate({fmt(x0)} {fmt(y0)}) scale({fmt(s)})" d="{d}"'

# iOS: full-bleed 1024 square (Apple applies the mask). Gold field, ink F.
write("fade-app-icon-ios.svg", svg(1024, 1024,
      f'  <rect width="1024" height="1024" fill="{GOLD}"/>\n  {icon_glyph(1024)} fill="{INK}"/>', title="Fade app icon"))
# Dark variant (ink field, gold F) — for iOS 18 dark icon / alt icon / social avatar
write("fade-app-icon-dark.svg", svg(1024, 1024,
      f'  <rect width="1024" height="1024" fill="{INK}"/>\n  {icon_glyph(1024)} fill="{GOLD}"/>', title="Fade app icon (dark)"))
# Rounded preview (for decks / web only, not for store upload)
write("fade-app-icon-rounded.svg", svg(1024, 1024,
      f'  <rect width="1024" height="1024" rx="230" fill="{GOLD}"/>\n  {icon_glyph(1024)} fill="{INK}"/>', title="Fade app icon"))

# Android adaptive icon: 108dp canvas, safe zone = 66dp circle. Glyph height 44dp (fits the 66dp circle).
def adaptive_glyph(fill):
    s = 44 / 100.0
    gw = 62 * s
    x0 = (108 - gw) / 2 + 1.2
    y0 = (108 - 44) / 2
    return f'<path transform="translate({fmt(x0)} {fmt(y0)}) scale({fmt(s)})" fill="{fill}" d="{glyph_F(slices=ICON_SLICES, stem_end=63)}"/>'
write("fade-app-icon-android-foreground.svg", svg(108, 108, "  " + adaptive_glyph(INK), title="Fade adaptive icon foreground"))
write("fade-app-icon-android-background.svg", svg(108, 108, f'  <rect width="108" height="108" fill="{GOLD}"/>', title="Fade adaptive icon background"))
write("fade-app-icon-android-monochrome.svg", svg(108, 108, "  " + adaptive_glyph("#000000"), title="Fade themed icon (monochrome)"))

# Favicon: same as icon but slightly larger glyph and rounded corners for browser tabs
def fav(canvas=32):
    s = canvas * 0.62 / 100.0
    gw = 62 * s
    x0 = (canvas - gw) / 2 + canvas * 0.02
    y0 = (canvas - 100 * s) / 2
    return (f'  <rect width="{canvas}" height="{canvas}" rx="{fmt(canvas*0.22)}" fill="{GOLD}"/>\n'
            f'  <path transform="translate({fmt(x0)} {fmt(y0)}) scale({fmt(s)})" fill="{INK}" d="{glyph_F(slices=((70, 13),), stem_end=62)}"/>')
write("fade-favicon.svg", svg(32, 32, fav(), title="Fade"))

# Monogram badge (rounded square) for avatars / social / in-app headers
write("fade-monogram.svg", svg(120, 120,
      f'  <rect width="120" height="120" rx="28" fill="{INK}"/>\n  ' +
      f'<path transform="translate({fmt((120-62*0.6)/2+2.4)} 30) scale(0.6)" fill="{GOLD}" d="{glyph_F()}"/>', title="Fade monogram"))

# Horizontal lockup: monogram + wordmark (on dark / on light)
for name, bg_badge, f_badge, word in [("fade-lockup-on-dark.svg", GOLD, INK, BONE), ("fade-lockup-on-light.svg", INK, GOLD, INK)]:
    s = 0.56
    body = (f'  <rect width="100" height="100" rx="24" fill="{bg_badge}"/>\n'
            f'  <path transform="translate({fmt((100-62*s)/2+2)} {fmt((100-100*s)/2)}) scale({s})" fill="{f_badge}" d="{glyph_F(slices=ICON_SLICES, stem_end=63)}"/>\n'
            f'  <path transform="translate(128 22) scale(0.56)" fill="{word}" fill-rule="evenodd" d="{wordmark_path()}"/>')
    write(name, svg(128 + WORD_W*0.56, 100, body, title="Fade"))
print("ok")
