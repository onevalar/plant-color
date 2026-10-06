//
//  PlantWidgetSmallColor.swift
//  PlantWidgetExtension
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import WidgetKit
import SwiftUI

struct PlantProviderColor: TimelineProvider {
    
    func placeholder(in context: Context) -> PlantEntry {
        PlantEntry(date: Date(), plant: PlantViewModel.placeholderModel())
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantEntry) -> ()) {
        let entry = PlantEntry(date: Date(), plant: PlantViewModel.placeholderModel())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let model = PlantViewModel.placeholderModel()
        var hour = 1
        if model.refreshRate == "1hour" {
            hour = 1
        } else if model.refreshRate == "6hours" {
            hour = 6
        } else if model.refreshRate == "1day" {
            hour = 24
        }
        let refreshDate = Calendar.current.date(byAdding: .hour, value: hour, to: currentDate)!
        let entry = PlantEntry(date: currentDate, plant: model)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
        
    }
}

struct PlantEntryColor: TimelineEntry {
    public let date: Date
    public let plant: PlantModel
}

struct PlantEntryColorView : View {
    
    var entry: PlantProviderColor.Entry
    @ViewBuilder
    var body: some View {
        PlantSmallViewColor(plant: entry.plant)
    }
}

struct PlantWidgetSmallWidgetColor: Widget {
    private let kind: String = "PlantWidgetSmallColor"
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantProviderColor()) { entry in
            PlantEntryColorView(entry: entry)
        }
        .configurationDisplayName("植物彩雅")
        .description("每日精彩颜色分享")
        .supportedFamilies([.systemSmall])
    }
    
}
