#!/usr/bin/env python3
"""Build Play Store tablet screenshots from phone captures (centered on black canvas)."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PHONE_DIR = ROOT / "store-assets" / "screenshots" / "phone"

# Play Console recommended portrait sizes
TABLET_SIZES = {
    "tablet-7": (1200, 1920),
    "tablet-10": (1600, 2560),
}

BG = (0, 0, 0)


def fit_center(phone: Image.Image, canvas_size: tuple[int, int]) -> Image.Image:
    cw, ch = canvas_size
    canvas = Image.new("RGB", canvas_size, BG)
    pw, ph = phone.size
    scale = min(cw / pw, ch / ph)
    nw, nh = int(pw * scale), int(ph * scale)
    resized = phone.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas.paste(resized, ((cw - nw) // 2, (ch - nh) // 2))
    return canvas


def main() -> None:
    phones = sorted(PHONE_DIR.glob("*.png"))
    if not phones:
        raise SystemExit(f"No phone screenshots in {PHONE_DIR}")

    for folder, size in TABLET_SIZES.items():
        out_dir = ROOT / "store-assets" / "screenshots" / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        for src in phones:
            img = Image.open(src).convert("RGB")
            out = fit_center(img, size)
            dst = out_dir / src.name
            out.save(dst, format="PNG", optimize=True)
        print(f"{folder}: {len(phones)} files @ {size[0]}x{size[1]} -> {out_dir}")


if __name__ == "__main__":
    main()
