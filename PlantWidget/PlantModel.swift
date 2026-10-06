//
//  PlantWidgetModel.swift
//  PlantWidgetExtension
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import UIKit
import SwiftUI

struct PlantModel: Codable {
    var name: String
    var colorRGB: String
    var colorHEX: String
    var colorCMYK: String
    var textColor: String
    var imageName: String
    var customContent: String
    var refreshRate: String
    var showFigure: Bool
    var showTone: Bool
}


struct PlantViewModel {
    
    public static func placeholderModel() -> PlantModel {
        
        var model = PlantModel(name: "栀子",
                               colorRGB: "250,192,61",
                               colorHEX: "#FAC03D",
                               colorCMYK: "0,30,80,0",
                               textColor: "#333333",
                               imageName: "zhizi_widget",
                               customContent: "",
                               refreshRate: "",
                               showFigure: false,
                               showTone: true)

        if let customContent = UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.object(forKey: WidgetKitHelper.customContent) as? String,
              let refreshRate = UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.object(forKey: WidgetKitHelper.refreshRate) as? String,
              var currentIndex = UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.object(forKey: WidgetKitHelper.currentIndex) as? Int,
              let showFigure = UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.object(forKey: WidgetKitHelper.showFigure) as? Bool,
              let showTone = UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.object(forKey: WidgetKitHelper.showTone) as? Bool {
            model.customContent = customContent
            model.refreshRate = refreshRate
            model.showFigure = showFigure
            model.showTone = showTone
            
            let items: [ColorModel] = ColorProvider.fetchColors()
            if items.isEmpty {
                return model
            }
            
            let item = items[currentIndex]
            model.name = item.plantName
            model.colorRGB = item.colorRGB
            model.colorHEX = item.colorHEX
            model.colorCMYK = item.colorCMYK
            model.textColor = item.textColor
            model.imageName = "\(item.imageName)_widget"
            if currentIndex + 1 < items.count - 1 {
                currentIndex = currentIndex + 1
            } else {
                currentIndex = 0
            }
            UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(currentIndex, forKey: WidgetKitHelper.currentIndex)
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
