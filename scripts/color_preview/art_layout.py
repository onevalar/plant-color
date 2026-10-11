"""把首页插画拆成主体/副体，生成几种重新排列的构图，并测量视觉占比。"""
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

AREA_W, AREA_H = 342, 541          # 首页插画区域（pt）
SPLIT_RADIUS = 0.035               # 膨胀半径，占长边比例：线稿连成"图块"
MIN_PART = 0.06                    # 小于总面积 6% 的碎片并入最近的图块


def disk(r):
    yy, xx = np.ogrid[-r:r + 1, -r:r + 1]
    return xx * xx + yy * yy <= r * r


def footprint(alpha, radius=SPLIT_RADIUS):
    """视觉占地：线稿膨胀后填满孔洞的面积（像素数）。alpha 为 0..255 数组。"""
    k = 400 / max(alpha.shape)
    small = np.array(Image.fromarray(alpha).resize((max(1, round(alpha.shape[1] * k)), max(1, round(alpha.shape[0] * k))), Image.BILINEAR)) > 30
    f = ndi.binary_fill_holes(ndi.binary_dilation(small, disk(max(2, round(radius * max(small.shape)))), iterations=1))
    return f.mean() * alpha.shape[0] * alpha.shape[1], f


def trim(rgba):
    bbox = Image.fromarray(rgba[..., 3]).point(lambda v: 255 if v > 8 else 0).getbbox()
    return rgba[bbox[1]:bbox[3], bbox[0]:bbox[2]]


def split_parts(rgba, radius=SPLIT_RADIUS):
    """返回 [主体, 副体] 两张 RGBA 数组；不可拆时返回 None。"""
    alpha = rgba[..., 3]
    _, f = footprint(alpha, radius)
    lab, n = ndi.label(f)
    if n < 2:
        return None
    sizes = np.bincount(lab.ravel())[1:]
    total = sizes.sum()
    big = [i + 1 for i, s in enumerate(sizes) if s / total >= MIN_PART]
    if len(big) < 2:
        return None
    main = big[int(np.argmax([sizes[i - 1] for i in big]))]
    # 每个小图块归入最近的大图块（按质心距离）
    centers = ndi.center_of_mass(f, lab, range(1, n + 1))
    group = {}
    for i in range(1, n + 1):
        if i in big:
            group[i] = 0 if i == main else 1
        else:
            cy, cx = centers[i - 1]
            nearest = min(big, key=lambda b: (centers[b - 1][0] - cy) ** 2 + (centers[b - 1][1] - cx) ** 2)
            group[i] = 0 if nearest == main else 1
    labels_full = np.array(Image.fromarray(lab.astype(np.int32)).resize((alpha.shape[1], alpha.shape[0]), Image.NEAREST))
    parts = []
    for g in (0, 1):
        ids = [i for i, v in group.items() if v == g]
        mask = np.isin(labels_full, ids)
        part = rgba.copy()
        part[..., 3] = np.where(mask, alpha, 0)
        parts.append(trim(part))
    return parts


def scale_rgba(rgba, f):
    if abs(f - 1) < 1e-3:
        return rgba
    im = Image.fromarray(rgba)
    return np.array(im.resize((max(1, round(im.width * f)), max(1, round(im.height * f))), Image.LANCZOS))


def place(canvas_w, canvas_h, items):
    out = np.zeros((canvas_h, canvas_w, 4), np.uint8)
    for rgba, x, y in items:
        h, w = rgba.shape[:2]
        region = out[y:y + h, x:x + w]
        a = rgba[..., 3:4].astype(np.float32) / 255
        region[..., :3] = (rgba[..., :3] * a + region[..., :3] * (1 - a)).astype(np.uint8)
        region[..., 3] = np.maximum(region[..., 3], rgba[..., 3])
    return trim(out)


def occupancy(rgba, bleed=0.0):
    """在首页区域里按"完整放下"缩放后的最大占比。"""
    foot, _ = footprint(rgba[..., 3])
    h, w = rgba.shape[:2]
    s = min(AREA_W * (1 + bleed) / w, AREA_H / h)
    return foot * s * s / (AREA_W * AREA_H)


def stack(main, sec, sec_scale):
    """主体在上，副体在下并尽量向上收拢；在左右两种对齐里选占比更高的。"""
    sec = scale_rgba(sec, sec_scale)
    h1, w1 = main.shape[:2]
    h2, w2 = sec.shape[:2]
    gap = round(0.03 * max(h1, w1))
    pad = round(0.025 * max(h1, w1))
    best = None
    for main_left in (True, False):
        W = max(w1, w2)
        mx = 0 if main_left else W - w1
        sx = W - w2 if main_left else 0
        # 用膨胀后的掩码检测碰撞，副体从主体下方逐步上移
        m_mask = np.zeros((h1 + h2 + gap, W), bool)
        m_mask[:h1, mx:mx + w1] = ndi.binary_dilation(main[..., 3] > 30, disk(pad))
        s_mask = sec[..., 3] > 30
        y = h1 + gap
        step = max(2, round(0.01 * h1))
        while y - step >= 0 and not (m_mask[y - step:y - step + h2, sx:sx + w2] & s_mask).any():
            y -= step
        comp = place(W, max(h1, y + h2), [(main, mx, 0), (sec, sx, y)])
        occ = occupancy(comp)
        if best is None or occ > best[0]:
            best = (occ, comp)
    return best[1]


def compositions(rgba):
    """返回 {模式: RGBA}。不可拆分的插画只有 original。"""
    rgba = trim(rgba)
    modes = {"original": rgba}
    # 先用较大的半径找明显分开的图块；找不到再用较小的半径试一次
    parts = split_parts(rgba) or split_parts(rgba, 0.02)
    if parts:
        main, sec = parts
        modes["stack"] = stack(main, sec, 1.0)
        modes["mainplus"] = stack(main, sec, 0.6)
        modes["main"] = main
    return modes
