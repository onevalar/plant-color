//
//  MBProgressWrapper.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import Foundation

public struct MBHUDWrapper<Base> {

    let base: Base

    init(_ base: Base) {
        self.base = base
    }
}
