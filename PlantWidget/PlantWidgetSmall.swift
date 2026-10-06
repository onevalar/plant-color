//
//  PlantWidget.swift
//  PlantWidget
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import WidgetKit
import SwiftUI

struct PlantProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> PlantEntry {
        PlantEntry(date: Date(), plant: PlantViewModel.placeholderModel())
    }

    func getSnapshot(in context: Context, completion: @escaping (PlantEntry) -> ()) {
        let entry = PlantEntry(date: Date(), plant: PlantViewModel.placeholderModel())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = PlantEntry(date: currentDate, plant: PlantViewModel.placeholderModel())
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
        
    }    
}

struct PlantEntry: TimelineEntry {
    public let date: Date
    public let plant: PlantModel
}

struct PlantEntryView : View {
    
    var entry: PlantProvider.Entry
    @ViewBuilder
    var body: some View {
        PlantSmallView(plant: entry.plant)
    }
}

struct PlantWidgetSmallWidget: Widget {
    private let kind: String = "PlantWidgetSmall"
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantProvider()) { entry in
            PlantEntryView(entry: entry)
        }
        .configurationDisplayName("植物彩雅")
        .description("每日精彩颜色分享")
        .supportedFamilies([.systemSmall])
    }
    
}
