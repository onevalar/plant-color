//
//  TraditionalColorDetailConfig.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import RealmSwift

class TraditionalColorDetailConfig: RealmExtensionable {

    @Persisted(primaryKey: true) var id: String

    @Persisted var defaultNow: RealmSwift.List<TraditionalColorDetailInfoType>

    @Persisted var defaultOther: RealmSwift.List<TraditionalColorDetailInfoType>
}
