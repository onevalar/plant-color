//
//  SettingConfig.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/9.
//

import RealmSwift
import UIKit

class SettingConfig: RealmExtensionable {

    @Persisted(primaryKey: true) var id: String
    
    @Persisted var automaticSwitching: Bool
    @Persisted var randomSwitching: Bool
    @Persisted var switchingRate: String
    @Persisted var showFigure: Bool
    @Persisted var showTone: Bool
    @Persisted var customContent: String
    @Persisted var refreshRate: String
}

/// Small local preferences stay separate from Realm and widget configuration.
final class HomePreferences {
    static let shared = HomePreferences()

    enum Startup: String { case last, first }
    enum Appearance: String, CaseIterable {
        case system, light, dark
        var style: UIUserInterfaceStyle {
            switch self { case .system: return .unspecified; case .light: return .light; case .dark: return .dark }
        }
    }
    struct Position: Codable, Equatable {
        let colorID: Int
        let page: Int
    }
    private struct History: Codable {
        var mode: Int
        var positions: [String: Position]
    }

    private let defaults: UserDefaults
    private var history = History(mode: 0, positions: [:])
    private let historyKey = "PlantColor.browsingHistory.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let data = defaults.data(forKey: historyKey), data.count <= 4096,
              let saved = try? JSONDecoder().decode(History.self, from: data),
              (0...1).contains(saved.mode), saved.positions.count <= 2,
              saved.positions.allSatisfy({ ["0", "1"].contains($0.key) && $0.value.colorID >= 0 && (0...1).contains($0.value.page) }) else { return }
        history = saved
    }

    var startup: Startup {
        get { Startup(rawValue: defaults.string(forKey: "PlantColor.startup") ?? "") ?? .last }
        set { defaults.set(newValue.rawValue, forKey: "PlantColor.startup") }
    }
    var hapticsEnabled: Bool {
        get { defaults.object(forKey: "PlantColor.haptics") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "PlantColor.haptics") }
    }
    var appearance: Appearance {
        get { Appearance(rawValue: defaults.string(forKey: "PlantColor.appearance") ?? "") ?? .system }
        set { defaults.set(newValue.rawValue, forKey: "PlantColor.appearance") }
    }
    var lastMode: HomeColorMode { HomeColorMode(rawValue: history.mode) ?? .botanical }
    func position(for mode: HomeColorMode) -> Position? { history.positions[String(mode.rawValue)] }

    func remember(mode: HomeColorMode, colorID: Int, page: Int) {
        guard colorID >= 0, (0...1).contains(page) else { return }
        history.mode = mode.rawValue
        history.positions[String(mode.rawValue)] = Position(colorID: colorID, page: page)
        if let data = try? JSONEncoder().encode(history) { defaults.set(data, forKey: historyKey) }
    }
}
