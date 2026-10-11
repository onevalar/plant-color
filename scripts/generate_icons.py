#!/usr/bin/env python3
"""Generate app icon resources from the approved full-resolution PNG masters.

Requires Pillow: python3 -m pip install Pillow
Run from any directory: python3 scripts/generate_icons.py
"""

import json
import shutil
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
MASTERS = ROOT / "assets/icon"
CATALOG = ROOT / "PlantColor/Resources/Assets/Assets.xcassets"
APP_ICON = CATALOG / "AppIcon.appiconset"
IN_APP_ICON = CATALOG / "Material/appIcon.imageset"


def write_catalog(directory, images):
    """Remove only obsolete files referenced by this catalog's old manifest."""
    manifest = directory / "Contents.json"
    old_images = json.loads(manifest.read_text())["images"] if manifest.exists() else []
    filenames = {image["filename"] for image in images}
    for image in old_images:
        name = image.get("filename")
        if name and name not in filenames:
            path = directory / name
            if path.parent == directory:
                path.unlink(missing_ok=True)
    manifest.write_text(json.dumps({
        "images": images,
        "info": {"author": "xcode", "version": 1},
    }, indent=2) + "\n")


def main():
    app_images = []
    in_app_images = []
    for appearance in ("light", "dark"):
        source = MASTERS / f"plantcolor-icon-{appearance}-1254.png"
        with Image.open(source) as image:
            if image.size != (1254, 1254) or image.mode != "RGB":
                raise ValueError(f"Expected an opaque 1254px RGB master: {source}")
            # One downsample directly from the original, never from another size.
            resized = image.resize((1024, 1024), Image.Resampling.LANCZOS)
            resized.save(APP_ICON / f"AppIcon-{appearance}-1024.png",
                         format="PNG", optimize=True,
                         icc_profile=image.info.get("icc_profile"))
        # In-app artwork retains the original PNG bytes and full resolution.
        shutil.copyfile(source, IN_APP_ICON / f"appIcon-{appearance}.png")
        variant = ({"appearances": [{"appearance": "luminosity", "value": "dark"}]}
                   if appearance == "dark" else {})
        app_images.append({
            "filename": f"AppIcon-{appearance}-1024.png",
            "idiom": "universal", "platform": "ios", "size": "1024x1024",
            **variant,
        })
        in_app_images.append({
            "filename": f"appIcon-{appearance}.png",
            "idiom": "universal", **variant,
        })
    write_catalog(APP_ICON, app_images)
    write_catalog(IN_APP_ICON, in_app_images)
    print("Generated light/dark 1024px app icons; preserved 1254px in-app artwork.")


if __name__ == "__main__":
    main()
