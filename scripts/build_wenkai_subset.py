#!/usr/bin/env python3
"""Build the bundled OFL font from LXGW WenKai v1.522 Regular.

Usage: python3 scripts/build_wenkai_subset.py /path/to/LXGWWenKai-Regular.ttf
Requires fonttools. Source: https://github.com/lxgw/LxgwWenKai/releases/tag/v1.522
The subset is renamed PlantColor WenKai to respect the reserved font names.
"""
import argparse
import json
from pathlib import Path
from fontTools import subset
from fontTools.ttLib import TTFont

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('source', type=Path)
args = parser.parse_args()
chars = set(chr(i) for i in range(32, 127))
for folder in ['PlantColor/Classes', 'PlantColor/Resources', 'PlantWidget']:
    for path in (root / folder).rglob('*'):
        if path.suffix not in {'.swift', '.strings', '.json'} or 'Generated' in path.parts:
            continue
        text = path.read_text(encoding='utf-8')
        if path.suffix == '.json':
            text = json.dumps(json.loads(text), ensure_ascii=False)
        chars.update(text)
font = TTFont(args.source)
cmap = font.getBestCmap()
plants = json.loads((root / 'PlantColor/Resources/PlantColor.json').read_text())
names = set(''.join(p['plantName'] for p in plants))
missing = sorted(ch for ch in names if ord(ch) not in cmap)
assert not missing, f'Missing botanical name glyphs: {missing}'
options = subset.Options()
options.name_IDs = ['*']
options.name_legacy = True
options.name_languages = ['*']
subsetter = subset.Subsetter(options=options)
subsetter.populate(unicodes={ord(ch) for ch in chars if ord(ch) in cmap})
subsetter.subset(font)
# Preserve copyright/license records; rename all family/full/PostScript names.
renames = {1:'PlantColor WenKai', 2:'Regular', 3:'PlantColorWenKai-Regular-1.522-subset',
           4:'PlantColor WenKai Regular', 6:'PlantColorWenKai-Regular',
           16:'PlantColor WenKai', 17:'Regular'}
for record in font['name'].names:
    if record.nameID in renames:
        record.string = renames[record.nameID].encode(record.getEncoding())
output = root / 'PlantColor/Resources/Fonts/PlantColorWenKai-Regular.ttf'
font.save(output)
verified = TTFont(output).getBestCmap()
assert all(ord(ch) in verified for ch in names)
print(f'{len(plants)} plant names covered; {len(verified)} glyph codepoints; {output.stat().st_size:,} bytes')
