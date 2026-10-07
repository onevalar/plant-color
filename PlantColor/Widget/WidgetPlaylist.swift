//
//  WidgetPlaylist.swift
//  PlantColor
//
//  把"小组件该轮播哪些颜色"写进 App Group，供小组件读取。
//

import Foundation
import RealmSwift

enum WidgetPlaylist {

    static var source: WidgetSource {
        get {
            let raw = WidgetKitHelper.sharedDefaults?.string(forKey: WidgetKitHelper.source) ?? ""
            return WidgetSource(rawValue: raw) ?? .all
        }
        set {
            WidgetKitHelper.sharedDefaults?.set(newValue.rawValue, forKey: WidgetKitHelper.source)
        }
    }

    /// 按当前来源重新生成列表，并让小组件从头开始轮播
    static func rebuild() {
        var plants: [WidgetPlaylistEntry] = []
        var traditional: [WidgetPlaylistEntry] = []
        let source = self.source
        let onlyCollected = source == .collect

        if source != .traditional, let items = try? ColorModel.re.objects() {
            plants = items
                .filter { !onlyCollected || $0.isCollect }
                .map {
                    WidgetPlaylistEntry(kind: ColorKind.plant.rawValue, id: $0.id, name: $0.plantName,
                                        hex: $0.colorHEX, rgb: $0.colorRGB, cmyk: $0.colorCMYK,
                                        textColor: $0.textColor, imageName: "\($0.imageName)_widget")
                }
        }
        if source != .plant, let items = try? TraditionalColorModel.re.objects() {
            traditional = items
                .filter { !onlyCollected || $0.isCollect }
                .map {
                    WidgetPlaylistEntry(kind: ColorKind.traditional.rawValue, id: $0.id, name: $0.name,
                                        hex: $0.colorHEX, rgb: $0.colorRGB, cmyk: $0.colorCMYK,
                                        textColor: $0.textColor, imageName: "")
                }
        }

        WidgetKitHelper.writePlaylist(interleave(plants, traditional))
        WidgetKitHelper.sharedDefaults?.set(0, forKey: WidgetKitHelper.currentIndex)
        WidgetKitHelper.reloadAllWidgets()
    }

    /// 收藏变化时，只有"仅收藏"模式的列表需要更新
    static func collectDidChange() {
        guard source == .collect else { return }
        rebuild()
    }

    /// 两类颜色交替排列，避免先连着看 32 个植物色再连着看几百个传统色
    private static func interleave(_ a: [WidgetPlaylistEntry], _ b: [WidgetPlaylistEntry]) -> [WidgetPlaylistEntry] {
        var result: [WidgetPlaylistEntry] = []
        result.reserveCapacity(a.count + b.count)
        for index in 0..<max(a.count, b.count) {
            if index < a.count { result.append(a[index]) }
            if index < b.count { result.append(b[index]) }
        }
        return result
    }
}
