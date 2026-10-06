//
//  TraditionalColorProvider.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import CleanJSON
import UIKit

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
            let rawItems: [[String: String]] = try CleanJSONDecoder().decode([[String: String]].self,
                                                                              from: jsonData)
            var items: [TraditionalColorModel] = []
            for (index, raw) in rawItems.enumerated() {
                let model = TraditionalColorModel()
                model.id = index + 1
                model.name = raw["name"] ?? ""
                model.pinyin = raw["pinyin"] ?? ""
                model.colorHEX = raw["hex"] ?? ""
                model.colorRGB = raw["rgb"] ?? ""
                model.colorCMYK = TraditionalColorProvider.rgbToCMYK(rgb: raw["rgb"] ?? "")
                model.colorSeries = TraditionalColorProvider.detectColorSeries(hex: raw["hex"] ?? "")
                model.textColor = TraditionalColorProvider.contrastTextColor(hex: raw["hex"] ?? "")
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

    // MARK: - Auto-detect color series from hex
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
