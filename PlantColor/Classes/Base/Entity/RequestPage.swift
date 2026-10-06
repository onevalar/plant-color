//
//  BasePage.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

struct RequestPage: Codable {

    var current: Int
    var queryString: String
    let size: Int

    init(current: Int,
         queryString: String = "",
         size: Int = 10) {
        self.current = current
        self.queryString = queryString
        self.size = size
    }
}
