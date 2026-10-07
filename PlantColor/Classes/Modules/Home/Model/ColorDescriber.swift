//
//  ColorDescriber.swift
//  PlantColor
//
//  传统色的数据里没有文字介绍时，根据色值自动生成"色彩概述"和"色彩辨析"。
//  内容都来自色值本身（明度、饱和度、色系、与相近色的差别），不涉及典故。
//

import Foundation

enum ColorDescriber {

    /// "「乳白」是极浅、柔和的灰色，HEX 为 #F9F4DC。"
    static func summary(name: String, hex: String, series: ColorSeries?) -> String {
        guard let rgb = RGBColor(hex: hex) else { return "" }
        let hue = (series ?? .gray).title
        return String(format: NSLocalizedString("color_desc_summary", comment: ""),
                      name,
                      lightnessWord(rgb.lab.l),
                      chromaWord(rgb.chroma),
                      hue,
                      rgb.hexString)
    }

    static func summary(for item: TraditionalColorModel) -> String {
        summary(name: item.name, hex: item.colorHEX, series: item.colorSeries)
    }

    /// 与最接近的几个颜色相比有什么不同，用来帮助区分名字相近的颜色
    static func distinction(for swatch: ColorSwatch, catalog: ColorCatalog = .shared) -> String {
        let neighbours = catalog.similar(to: swatch, limit: 3)
        let lines: [String] = neighbours.map { other in
            let diff = difference(from: swatch.rgb, to: other.rgb)
            return String(format: NSLocalizedString("color_desc_distinction_line", comment: ""),
                          other.name, other.kind.title, other.hex, diff)
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private static func difference(from base: RGBColor, to other: RGBColor) -> String {
        let lightness = (base: base.lab.l, other: other.lab.l)
        let chroma = (base: base.chroma, other: other.chroma)
        var parts: [String] = []
        if lightness.other - lightness.base > 3 { parts.append(NSLocalizedString("color_diff_lighter", comment: "")) }
        if lightness.base - lightness.other > 3 { parts.append(NSLocalizedString("color_diff_darker", comment: "")) }
        if chroma.other - chroma.base > 4 { parts.append(NSLocalizedString("color_diff_more_vivid", comment: "")) }
        if chroma.base - chroma.other > 4 { parts.append(NSLocalizedString("color_diff_softer", comment: "")) }

        // 明暗、鲜艳度都差不多时，看色相往哪边偏（a：绿↔红，b：蓝↔黄）
        let da = other.lab.a - base.lab.a
        let db = other.lab.b - base.lab.b
        if parts.isEmpty || max(abs(da), abs(db)) > 6 {
            if abs(da) >= abs(db), abs(da) > 3 {
                parts.append(NSLocalizedString(da > 0 ? "color_diff_redder" : "color_diff_greener", comment: ""))
            } else if abs(db) > 3 {
                parts.append(NSLocalizedString(db > 0 ? "color_diff_yellower" : "color_diff_bluer", comment: ""))
            }
        }
        if parts.isEmpty {
            return NSLocalizedString("color_diff_nearly_same", comment: "")
        }
        return parts.joined(separator: NSLocalizedString("color_diff_separator", comment: ""))
    }

    /// l 为 Lab 明度，0（黑）到 100（白）
    private static func lightnessWord(_ l: Double) -> String {
        switch l {
        case 90...: return NSLocalizedString("color_desc_lightness_very_light", comment: "")
        case 75..<90: return NSLocalizedString("color_desc_lightness_light", comment: "")
        case 50..<75: return NSLocalizedString("color_desc_lightness_medium", comment: "")
        case 30..<50: return NSLocalizedString("color_desc_lightness_deep", comment: "")
        default: return NSLocalizedString("color_desc_lightness_very_deep", comment: "")
        }
    }

    private static func chromaWord(_ chroma: Double) -> String {
        switch chroma {
        case ..<8: return NSLocalizedString("color_desc_saturation_neutral", comment: "")
        case 8..<25: return NSLocalizedString("color_desc_saturation_soft", comment: "")
        case 25..<55: return NSLocalizedString("color_desc_saturation_moderate", comment: "")
        default: return NSLocalizedString("color_desc_saturation_vivid", comment: "")
        }
    }
}
