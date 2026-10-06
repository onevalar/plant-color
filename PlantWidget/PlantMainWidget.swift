//
//  PlantMainWidget.swift
//  PlantWidgetExtension
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    public let date: Date
}

struct PlaceholderView : View {
    var body: some View {
        Text("欢迎来到植物彩雅组件模块")
    }
}

@main
struct Widgets: WidgetBundle {
    @WidgetBundleBuilder
    
    var body: some Widget {
        PlantWidgetSmallWidget()
//        PlantWidgetSmallWidgetColor()
    }

}

