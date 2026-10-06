//
//  DBConfigs.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

extension String {

    /// Documents 目录路径
    static var documentPath: String {

        NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                            .userDomainMask,
                                            true).first ?? ""
    }
}
