//
//  DictionaryExtension.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import Foundation

typealias TypedUserInfoKey<T> = (key: String, type: T.Type)

extension Dictionary where Key == String, Value == Any {
    subscript<T>(_ typedKey: TypedUserInfoKey<T>) -> T? {
        self[typedKey.key] as? T
    }
}
