//
//  WidgetCenter.swift
//  NBAHouse
//
//  Created by Pluto on 2022/01/07.
//

import WidgetKit

struct WidgetKitHelper {
    
    /// App Group 的名字，必须和两个 target 的 entitlements 里的一致，
    /// 否则 App 和小组件各读各的，设置永远传不过去。
    /// 小组件的包里没有 AppConfig.plist，所以这里直接写死，不再从配置文件读。
    static let groupBundleID = "group.com.anyujia.PlantColor"
    
    static var showTone: String {
        "showTone"
    }
    
    static var showFigure: String {
        "showFigure"
    }
    
    static var refreshRate: String {
        "refreshRate"
    }
    
    static var customContent: String {
        "customContent"
    }
    
    static var currentIndex: String {
        "currentIndex"
    }
    
    static func reloadAllWidgets() {
        #if arch(arm64) || arch(i386) || arch(x86_64)
            WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
}

// MARK: - App 与小组件之间共享的数据

/// 小组件的颜色来源
enum WidgetSource: String {
    /// 植物色 + 传统色
    case all
    case plant
    case traditional
    /// 仅我收藏的颜色
    case collect
}

/// 小组件要轮播的一个颜色。App 把整份列表写进 App Group，小组件只管按顺序读取。
struct WidgetPlaylistEntry: Codable {
    var kind: String
    var id: Int
    var name: String
    var hex: String
    var rgb: String
    var cmyk: String
    var textColor: String
    /// 为空表示没有配图（传统色没有图案）
    var imageName: String
}

extension WidgetKitHelper {

    static var source: String {
        "widgetSource"
    }

    static var playlist: String {
        "widgetPlaylist"
    }

    /// 点击小组件时打开 App 里对应颜色的链接
    static let urlScheme = "plantcolor"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: groupBundleID)
    }

    /// nil 表示 App 还没有写过列表（比如刚安装、还没打开过 App）
    static func readPlaylist() -> [WidgetPlaylistEntry]? {
        guard let data = sharedDefaults?.data(forKey: playlist) else { return nil }
        return try? JSONDecoder().decode([WidgetPlaylistEntry].self, from: data)
    }

    static func writePlaylist(_ entries: [WidgetPlaylistEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        sharedDefaults?.set(data, forKey: playlist)
    }
}
