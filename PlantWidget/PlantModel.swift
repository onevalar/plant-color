//
//  PlantWidgetModel.swift
//  PlantWidgetExtension
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import UIKit
import SwiftUI

struct PlantModel: Codable {
    var kind: String
    var id: Int
    var name: String
    var colorRGB: String
    var colorHEX: String
    var colorCMYK: String
    var textColor: String
    /// 为空表示没有配图（传统色）
    var imageName: String
    var customContent: String
    var refreshRate: String
    var showFigure: Bool
    var showTone: Bool
    /// "收藏为空"时的占位提示
    var isEmptyPlaceholder: Bool = false

    /// 点击小组件后在 App 里打开的页面
    var deepLink: URL? {
        guard !isEmptyPlaceholder else { return nil }
        return URL(string: "\(WidgetKitHelper.urlScheme)://color/\(kind)/\(id)")
    }

    /// 统一成 "249 244 220" 的写法（不同数据源的逗号、空格不一致）
    var displayRGB: String {
        colorRGB.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: " ")
    }

    var displayCMYK: String {
        colorCMYK.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: " ")
    }
}


struct PlantViewModel {

    /// 占位 / 快照用：只读取当前颜色，不推进轮播序号
    public static func placeholderModel() -> PlantModel {
        currentModel(advance: false)
    }

    /// 生成时间线用：读取当前颜色，并把序号推进到下一个
    public static func nextModel() -> PlantModel {
        currentModel(advance: true)
    }

    /// 按用户设置的刷新频率换算出下一次刷新的间隔（小时）
    public static func refreshHours(for model: PlantModel) -> Int {
        switch model.refreshRate {
        case "6hours": return 6
        case "1day": return 24
        default: return 1
        }
    }

    private static func currentModel(advance: Bool) -> PlantModel {

        let defaults = WidgetKitHelper.sharedDefaults

        var model = PlantModel(kind: "plant",
                               id: 1,
                               name: "栀子",
                               colorRGB: "250,192,61",
                               colorHEX: "#FAC03D",
                               colorCMYK: "0,30,80,0",
                               textColor: "#333333",
                               imageName: "zhizi_widget",
                               customContent: defaults?.string(forKey: WidgetKitHelper.customContent) ?? "",
                               refreshRate: defaults?.string(forKey: WidgetKitHelper.refreshRate) ?? "1hour",
                               showFigure: defaults?.object(forKey: WidgetKitHelper.showFigure) as? Bool ?? false,
                               showTone: defaults?.object(forKey: WidgetKitHelper.showTone) as? Bool ?? true)

        // App 写好的轮播列表；App 还没打开过时，退回到随小组件打包的植物色
        let entries: [WidgetPlaylistEntry]
        if let playlist = WidgetKitHelper.readPlaylist() {
            entries = playlist
        } else {
            entries = ColorProvider.fetchColors().map {
                WidgetPlaylistEntry(kind: "plant", id: $0.id, name: $0.plantName, hex: $0.colorHEX,
                                    rgb: $0.colorRGB, cmyk: $0.colorCMYK, textColor: $0.textColor,
                                    imageName: "\($0.imageName)_widget")
            }
        }

        if entries.isEmpty {
            // 选了"仅收藏"但还没有收藏任何颜色
            model.kind = "plant"
            model.name = NSLocalizedString("widget_empty_title", comment: "")
            model.colorHEX = "#F2EFE9"
            model.colorRGB = "242,239,233"
            model.colorCMYK = "0,1,4,5"
            model.textColor = "#333333"
            model.imageName = ""
            model.customContent = NSLocalizedString("widget_empty_hint", comment: "")
            model.isEmptyPlaceholder = true
            return model
        }

        // 序号越界时回到第一个，避免数据变少后闪退
        let storedIndex = defaults?.object(forKey: WidgetKitHelper.currentIndex) as? Int ?? 0
        let currentIndex = (0..<entries.count).contains(storedIndex) ? storedIndex : 0
        let entry = entries[currentIndex]
        model.kind = entry.kind
        model.id = entry.id
        model.name = entry.name
        model.colorRGB = entry.rgb
        model.colorHEX = entry.hex
        model.colorCMYK = entry.cmyk
        model.textColor = entry.textColor
        model.imageName = entry.imageName

        if advance {
            defaults?.set((currentIndex + 1) % entries.count, forKey: WidgetKitHelper.currentIndex)
        }
        return model
    }

}

extension Color {
    init (hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
