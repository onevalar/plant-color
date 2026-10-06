//
//  SettingConfig.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/9.
//

import RealmSwift

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
