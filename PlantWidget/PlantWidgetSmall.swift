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
        let model = PlantViewModel.nextModel()
        let hours = PlantViewModel.refreshHours(for: model)
        let refreshDate = Calendar.current.date(byAdding: .hour, value: hours, to: currentDate)!
        let entry = PlantEntry(date: currentDate, plant: model)
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

    var body: some View {
        PlantWidgetView(plant: entry.plant)
    }
}

/// kind 沿用旧名字，已经添加到桌面的小组件不会失效
struct PlantWidgetSmallWidget: Widget {
    private let kind: String = "PlantWidgetSmall"
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlantProvider()) { entry in
            PlantEntryView(entry: entry)
        }
        .configurationDisplayName("widget_name")
        .description("widget_description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
