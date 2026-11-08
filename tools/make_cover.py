#!/usr/bin/env python3
"""Draws the 630 by 500 itch.io cover: a skinny pixel fish whose ribs show, in a dark tank, and the
title in the page's colours. Liberation Serif (SIL Open Font License) for the text."""
import sys
from PIL import Image, ImageDraw, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else "assets/cover.png"
W, H = 630, 500
BG_TOP, BG_BOTTOM = (13, 36, 51), (6, 20, 30)  # the page's --bg, darker at the bottom
GOLD, INK, DIM = (255, 210, 122), (232, 241, 242), (143, 179, 191)
BOLD = "/usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf"
REGULAR = "/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf"

# The fish, one character per pixel: o outline, b body, r rib, e eye, f fin, . nothing.
FISH = [
    "..........ooooo..............",
    "........oofffffo.............",
    ".....oooobbbbbbboooo.......oo",
    "...oobbbrbbrbbrbbbbboo....off",
    "..obebbbrbbrbbrbbrbbbbo..offo",
    ".obbbbbbrbbrbbrbbrbbbbbooffo.",
    "obbbbbbbrbbrbbrbbrbbbbbbfffo.",
    ".obbbbbbrbbrbbrbbrbbbbbooffo.",
    "..obbbbbrbbrbbrbbrbbbbo..offo",
    "...oobbbrbbrbbrbbbbboo....off",
    ".....oooobbbbbbboooo.......oo",
    "........oofffffo.............",
    "..........ooooo..............",
]
COLOURS = {"o": (20, 60, 78), "b": (236, 150, 60), "r": (150, 70, 30), "e": (232, 241, 242), "f": (255, 190, 100)}

img = Image.new("RGB", (W, H))
d = ImageDraw.Draw(img)
for y in range(H):
    t = y / (H - 1)
    d.line([(0, y), (W, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))

# Bubbles, and gravel along the bottom.
for x, y, r in [(530, 250, 6), (546, 222, 4), (536, 198, 3), (100, 300, 4), (112, 272, 3)]:
    d.ellipse([x - r, y - r, x + r, y + r], outline=DIM, width=2)
for i in range(0, W, 14):
    h = 6 + (i * 37) % 9
    d.rectangle([i, H - h, i + 11, H], fill=(28, 52, 64))

# The fish, scaled up as pixel art.
S = 11
fw, fh = len(FISH[0]) * S, len(FISH) * S
fx, fy = (W - fw) // 2, 170
for row, line in enumerate(FISH):
    for col, ch in enumerate(line):
        if ch in COLOURS:
            d.rectangle([fx + col * S, fy + row * S, fx + (col + 1) * S - 1, fy + (row + 1) * S - 1], fill=COLOURS[ch])


def centred(y, text, font, fill):
    w = d.textlength(text, font=font)
    d.text(((W - w) / 2, y), text, font=font, fill=fill)


centred(36, "Ichthyophiles", ImageFont.truetype(BOLD, 72), GOLD)
centred(118, "of SPLORR!!", ImageFont.truetype(BOLD, 36), INK)
centred(342, "Fish have ribs.", ImageFont.truetype(REGULAR, 34), INK)
centred(392, "A virtual pet on the real clock", ImageFont.truetype(REGULAR, 22), DIM)
centred(440, "TheGrumpyGameDev", ImageFont.truetype(BOLD, 18), DIM)

img.save(OUT)
print("wrote", OUT, img.size)
