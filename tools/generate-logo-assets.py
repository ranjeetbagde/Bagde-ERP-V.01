#!/usr/bin/env python3
"""Generate Bagde ERP logo assets with subtle white stroke and soft shadow."""
from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
IMG = ROOT / "public" / "assets" / "images"
SOURCE = IMG / "bagde-logo-source.png"
ORIGINAL = IMG / "bagde-logo.png"

STROKE_PX = 2
SHADOW_BLUR = 5
SHADOW_OPACITY = 0.12
SHADOW_OFFSET = (0, 2)
MARGIN = 4


def dilate_alpha(alpha: Image.Image, radius: int) -> Image.Image:
    result = alpha
    for _ in range(radius):
        result = result.filter(ImageFilter.MaxFilter(3))
    return result


def add_stroke_and_shadow(img: Image.Image, stroke_px: int = STROKE_PX) -> Image.Image:
    if img.mode != "RGBA":
        img = img.convert("RGBA")

    w, h = img.size
    pad = max(MARGIN, SHADOW_BLUR + abs(SHADOW_OFFSET[1]) + stroke_px)
    canvas = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))

    alpha = img.split()[3]
    dilated = dilate_alpha(alpha, stroke_px)

    white_ring = Image.new("RGBA", img.size, (255, 255, 255, 255))
    white_ring.putalpha(dilated)
    stroked = Image.alpha_composite(white_ring, img)

    # Soft shadow from stroked silhouette
    shadow_alpha = dilate_alpha(stroked.split()[3], 1).filter(
        ImageFilter.GaussianBlur(SHADOW_BLUR)
    )
    shadow = Image.new("RGBA", img.size, (0, 0, 0, int(255 * SHADOW_OPACITY)))
    shadow.putalpha(shadow_alpha)

    sx, sy = SHADOW_OFFSET
    canvas.paste(shadow, (pad + sx, pad + sy), shadow)
    canvas.paste(stroked, (pad, pad), stroked)

    bbox = canvas.getbbox()
    if bbox:
        canvas = canvas.crop(bbox)

    return canvas


def save_png(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG", optimize=True)
    print(f"  wrote {path.relative_to(ROOT)} ({img.size[0]}x{img.size[1]})")


def write_svg(view_w: int, view_h: int) -> None:
    svg = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     viewBox="0 0 {view_w} {view_h}" width="{view_w}" height="{view_h}" role="img"
     aria-label="Bagde Building Material Supplier">
  <image xlink:href="bagde-logo.png" x="0" y="0" width="{view_w}" height="{view_h}"
         preserveAspectRatio="xMidYMid meet"/>
</svg>
"""
    out = IMG / "bagde-logo.svg"
    out.write_text(svg, encoding="utf-8")
    print(f"  wrote {out.relative_to(ROOT)}")


def main() -> None:
    if not ORIGINAL.exists() and not SOURCE.exists():
        raise SystemExit("Missing bagde-logo.png")

    if ORIGINAL.exists() and not SOURCE.exists():
        shutil.copy2(ORIGINAL, SOURCE)
        print(f"  backed up original -> {SOURCE.relative_to(ROOT)}")

    base = Image.open(SOURCE if SOURCE.exists() else ORIGINAL)
    stroked = add_stroke_and_shadow(base)
    vw, vh = stroked.size

    print("Generating logo assets...")
    save_png(stroked, IMG / "bagde-logo.png")

    for scale, name in ((2, "bagde-logo@2x.png"), (4, "bagde-logo@4x.png")):
        scaled = stroked.resize(
            (vw * scale, vh * scale), Image.Resampling.LANCZOS
        )
        save_png(scaled, IMG / name)

    write_svg(vw, vh)
    print("Done.")


if __name__ == "__main__":
    main()
