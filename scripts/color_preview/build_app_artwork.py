"""Generate lossless template masks for the native home layout from the original PNGs.
Run with Python + Pillow, numpy, scipy. Original assets are never modified.
Unlike the exploratory preview, production never discards the secondary drawing.
"""
import json
from pathlib import Path
import numpy as np
from PIL import Image
import art_layout

root = Path(__file__).resolve().parents[2]
catalog = root / 'PlantColor/Resources/Assets/Assets.xcassets'
destination = catalog / 'HomeHarmony'
destination.mkdir(exist_ok=True)
(destination / 'Contents.json').write_text(json.dumps({'info': {'author': 'xcode', 'version': 1}}))
plants = json.loads((root / 'PlantColor/Resources/PlantColor.json').read_text())
manifest = {}
for plant in plants:
    name = plant['imageName']
    source = next((catalog / 'Home').rglob(f'{name}.imageset/*.png'))
    original = np.array(Image.open(source).convert('RGBA'))
    variants = []
    for mode, pixels in art_layout.compositions(original).items():
        if mode == 'main':
            continue  # Keep every part of the original illustration.
        h, w = pixels.shape[:2]
        footprint, _ = art_layout.footprint(pixels[..., 3])
        asset = f'{name}_harmony_{mode}'
        directory = destination / f'{asset}.imageset'
        directory.mkdir(exist_ok=True)
        # Template rendering only uses alpha. White RGB avoids premultiplication fringes.
        mask = Image.new('RGBA', (w, h), (255, 255, 255, 255))
        mask.putalpha(Image.fromarray(pixels[..., 3]))
        mask.save(directory / 'art.png', optimize=True)
        (directory / 'Contents.json').write_text(json.dumps({
            'images': [{'filename': 'art.png', 'idiom': 'universal'}],
            'info': {'author': 'xcode', 'version': 1},
            'properties': {'template-rendering-intent': 'template'}}, indent=2)+'\n')
        variants.append({'name': asset, 'width': w, 'height': h, 'footprint': footprint/(w*h)})
    manifest[name] = variants
    print(name, len(variants), flush=True)
metadata = destination / 'BotanicalArtLayouts.dataset'
metadata.mkdir(exist_ok=True)
(metadata / 'layouts.json').write_text(json.dumps(manifest, indent=2)+'\n')
(metadata / 'Contents.json').write_text(json.dumps({
    'data': [{'filename': 'layouts.json', 'idiom': 'universal'}],
    'info': {'author': 'xcode', 'version': 1}}, indent=2)+'\n')
