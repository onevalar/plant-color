//
//  ColorDetailConfig.swift
//  PlantColor
//
//  Created by QY on 2022/5/4.
//

import RealmSwift

class ColorDetailConfig: RealmExtensionable {

    @Persisted(primaryKey: true) var id: String

    @Persisted var defaultNow: RealmSwift.List<ColorDetailInfoType>

    @Persisted var defaultOther: RealmSwift.List<ColorDetailInfoType>
}
