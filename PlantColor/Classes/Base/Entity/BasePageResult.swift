//
//  BasePageResult.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

struct BasePageResult<T: Codable> : Codable {

    let current: Int
    let pages: Int
    let list: [T]

    var isHasMore: Bool {
        current < pages
    }
}
