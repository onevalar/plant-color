//
//  ColorListType.swift
//  PlantColor
//
//  Created by insect on 2022/2/10.
//

import Foundation

enum ColorListType {
    
    case all
    
    case collect
}

extension ColorListType {
    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("all_color_title_all", comment: "")
        case .collect:
            return NSLocalizedString("all_color_title_collect", comment: "")
        }
    }
}
