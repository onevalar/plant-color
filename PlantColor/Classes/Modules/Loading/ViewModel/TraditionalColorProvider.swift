//
//  TraditionalColorProvider.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import CleanJSON
import UIKit

/// chinese_traditional_colors.json 中的一条记录。
/// 只有 name / pinyin / hex 是必填，文字内容由 scripts/build_traditional_colors.py 补充。
private struct RawTraditionalColor: Decodable {

    struct RawLiterature: Decodable {
        let title: String
        let author: String
        let content: String
    }

    let name: String
    let pinyin: String
    let hex: String
    let origin: String?
    let story: String?
    let customs: String?
    let art: String?
    let symbolism: String?
    let craft: String?
    let distinction: String?
    let literature: [RawLiterature]?
}

class TraditionalColorProvider {

    static func fetchColors() -> [TraditionalColorModel] {

        guard
            let jsonPath = Bundle.main.path(forResource: "chinese_traditional_colors", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath))
        else {
            AppLogger.shared.error("Unable to find chinese_traditional_colors.json")
            return []
        }

        do {
            let rawItems = try CleanJSONDecoder().decode([RawTraditionalColor].self, from: jsonData)
            var items: [TraditionalColorModel] = []
            for (index, raw) in rawItems.enumerated() {
                // 以 HEX 为准换算 RGB，避免两个字段对不上
                guard let rgb = RGBColor(hex: raw.hex) else {
                    AppLogger.shared.warning("Skip traditional color with invalid hex: \(raw.name) \(raw.hex)")
                    continue
                }
                let model = TraditionalColorModel()
                model.id = index + 1
                model.name = raw.name
                model.pinyin = raw.pinyin
                model.colorHEX = rgb.hexString
                model.colorRGB = "\(rgb.r), \(rgb.g), \(rgb.b)"
                model.colorCMYK = TraditionalColorProvider.rgbToCMYK(rgb: model.colorRGB)
                model.colorSeries = TraditionalColorProvider.detectColorSeries(name: raw.name, hex: rgb.hexString)
                model.textColor = TraditionalColorProvider.contrastTextColor(hex: rgb.hexString)

                // 标题留空，详情页会按当前语言显示默认标题
                model.colorOriginDetail = raw.origin ?? ""
                model.colorStoryDetail = raw.story ?? ""
                model.culturalCustomsDetail = raw.customs ?? ""
                model.artApplicationDetail = raw.art ?? ""
                model.symbolismDetail = raw.symbolism ?? ""
                model.dyeingCraftDetail = raw.craft ?? ""
                model.colorDistinctionDetail = raw.distinction ?? ""
                for entry in raw.literature ?? [] {
                    let literature = LiteratureModel()
                    literature.title = entry.title
                    literature.author = entry.author
                    literature.content = entry.content
                    model.literatureDetail.append(literature)
                }
                items.append(model)
            }
            AppLogger.shared.info("Successfully parsed \(items.count) traditional colors")
            return items
        } catch {
            AppLogger.shared.error("Failed to parse chinese_traditional_colors.json: \(error.localizedDescription)")
        }
        return []
    }

    // MARK: - RGB to CMYK conversion
    static func rgbToCMYK(rgb: String) -> String {
        let components = rgb.components(separatedBy: ",").compactMap {
            Double($0.trimmingCharacters(in: .whitespaces))
        }
        guard components.count == 3 else { return "0,0,0,0" }

        let r = components[0] / 255.0
        let g = components[1] / 255.0
        let b = components[2] / 255.0

        let k = 1.0 - max(r, g, b)
        if k >= 1.0 {
            return "0,0,0,100"
        }

        let c = (1.0 - r - k) / (1.0 - k)
        let m = (1.0 - g - k) / (1.0 - k)
        let y = (1.0 - b - k) / (1.0 - k)

        return "\(Int(round(c * 100))),\(Int(round(m * 100))),\(Int(round(y * 100))),\(Int(round(k * 100)))"
    }

    // MARK: - Detect color series

    /// 名字里已经点明色系的（棕、褐、灰、白……）以名字为准，其余按色值判断
    static func detectColorSeries(name: String, hex: String) -> ColorSeries {
        let brownWords = ["棕", "褐", "咖啡", "驼", "可可", "赭", "栗"]
        if brownWords.contains(where: { name.contains($0) }) { return .brown }
        if name.hasSuffix("灰") || name.hasSuffix("白") { return .gray }
        return detectColorSeries(hex: hex)
    }

    /// 仅按色值判断色系
    static func detectColorSeries(hex: String) -> ColorSeries {
        let cleanHex = hex.replacingOccurrences(of: "#", with: "")
        guard cleanHex.count == 6,
              let hexInt = UInt32(cleanHex, radix: 16) else { return .gray }

        let r = Double((hexInt >> 16) & 0xFF) / 255.0
        let g = Double((hexInt >> 8) & 0xFF) / 255.0
        let b = Double(hexInt & 0xFF) / 255.0

        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC

        // Saturation
        let saturation = maxC == 0 ? 0 : delta / maxC

        // Low saturation = gray/brown
        if saturation < 0.1 { return .gray }

        // Calculate hue
        var hue: Double = 0
        if delta > 0 {
            if maxC == r {
                hue = 60.0 * fmod((g - b) / delta, 6.0)
            } else if maxC == g {
                hue = 60.0 * ((b - r) / delta + 2.0)
            } else {
                hue = 60.0 * ((r - g) / delta + 4.0)
            }
        }
        if hue < 0 { hue += 360 }

        // Low brightness + low saturation = brown
        let brightness = maxC
        if brightness < 0.35 && saturation < 0.4 {
            return .brown
        }

        // Map hue to color series
        switch hue {
        case 0..<15:    return .red
        case 15..<45:   return .orange
        case 45..<75:   return .yellow
        case 75..<165:  return .green
        case 165..<210: return .blue
        case 210..<260: return .indigo
        case 260..<330: return .purple
        case 330..<360: return .red
        default:        return .gray
        }
    }

    // MARK: - Contrast text color (black or white)
    static func contrastTextColor(hex: String) -> String {
        let cleanHex = hex.replacingOccurrences(of: "#", with: "")
        guard cleanHex.count == 6,
              let hexInt = UInt32(cleanHex, radix: 16) else { return "#000000" }

        let r = Double((hexInt >> 16) & 0xFF) / 255.0
        let g = Double((hexInt >> 8) & 0xFF) / 255.0
        let b = Double(hexInt & 0xFF) / 255.0

        // W3C relative luminance
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5 ? "#333333" : "#FFFFFF"
    }
}
