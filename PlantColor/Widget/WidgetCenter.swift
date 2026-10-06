//
//  WidgetCenter.swift
//  NBAHouse
//
//  Created by Pluto on 2022/01/07.
//

import WidgetKit

struct WidgetKitHelper {
    
    static var groupBundleID: String {
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let groupID = config["WidgetGroupID"] as? String {
            return groupID
        }
        return "group.com.xiaoan.PlantColor"
    }
    
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
