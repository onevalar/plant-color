"""生成首页配色与插画占比预览页：插画拆分重排、字体子集、数据注入。

依赖：Pillow、numpy、scipy、fonttools、brotli
用法：python scripts/color_preview/build_contrast_preview.py [输出目录]
默认输出到 植物彩雅文档/首页配色预览/
"""
import json, re, subprocess, sys
from pathlib import Path
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
import art_layout  # noqa: E402

here = Path(__file__).parent
repo = here.parents[1]
src = here / "contrast-preview.src.html"     # 页面样式、正文与脚本
template = here / "page-template.html"       # 页面基础样式与目录脚本
out_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else repo / "植物彩雅文档/首页配色预览"
asset_dir = out_dir / "plant-color-contrast"
(asset_dir / "img").mkdir(parents=True, exist_ok=True)

colors = json.loads((repo / "PlantColor/Resources/PlantColor.json").read_text())
swift = (repo / "PlantColor/Classes/Modules/Home/Model/ColorDisplayable.swift").read_text()
summaries = dict(re.findall(r'"([^"]+)": "([^"]+)"', swift))
assets = repo / "PlantColor/Resources/Assets/Assets.xcassets/Home"

data = []
for c in colors:
    png = next(assets.rglob(f"{c['imageName']}.imageset/*.png"))
    modes = {}
    for mode, rgba in art_layout.compositions(np.array(Image.open(png).convert("RGBA"))).items():
        foot, _ = art_layout.footprint(rgba[..., 3])
        h, w = rgba.shape[:2]
        img = Image.fromarray(rgba)
        img.thumbnail((900, 900))
        img.save(asset_dir / "img" / f"{c['imageName']}-{mode}.webp", "WEBP", quality=86)
        modes[mode] = {"w": w, "h": h, "foot": round(foot / (w * h), 4)}
    data.append({"id": c["id"], "name": c["plantName"], "hex": c["colorHEX"].upper(),
                 "text": c["textColor"].upper(), "summary": summaries.get(c["plantName"], ""),
                 "img": c["imageName"], "modes": modes})

chars = "".join(sorted(set("".join(d["name"] + d["summary"] for d in data) + "0123456789:")))
subprocess.run([sys.executable, "-m", "fontTools.subset",
                str(repo / "PlantColor/Resources/Fonts/PlantColorWenKai-Regular.ttf"),
                f"--text={chars}", "--flavor=woff2",
                f"--output-file={asset_dir / 'wenkai.woff2'}"], check=True)

t = template.read_text()
head = t[:t.index("</style>")]
tail_script = t[t.index("<script>"):]
body = src.read_text().replace("__DATA__", json.dumps(data, ensure_ascii=False))
page_style, page_body = body.split("<!--BODY-->")
page = (head.replace('lang="en"', 'lang="zh-CN"')
        .replace("<title>⟦Same text as the h1⟧</title>", "<title>首页文字与按钮颜色跟随底色调和</title>")
        + page_style + "</style>\n</head>\n<body>\n" + page_body.split("<!--SCRIPT-->")[0]
        + tail_script.replace("'Replay'", "'重播'").replace("</body>", page_body.split("<!--SCRIPT-->")[1] + "\n</body>"))
(out_dir / "plant-color-contrast.html").write_text(page)
print("ok", len(data), "colors,", len(chars), "glyphs")
