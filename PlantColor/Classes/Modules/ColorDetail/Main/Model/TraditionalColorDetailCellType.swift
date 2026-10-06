//
//  TraditionalColorDetailCellType.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import Foundation
import RealmSwift

struct TraditionalColorDetailSubtitle {
    let title: String
    let detail: String
    let type: TraditionalColorDetailInfoType

    var safeTitle: String {
        title.isEmpty ? type.title : title
    }
}

enum TraditionalColorDetailCellType {

    case intro(TraditionalColorModel)

    case subtitle(TraditionalColorDetailSubtitle)
}

enum TraditionalColorDetailInfoType: String, PersistableEnum, Codable {

    case intro

    case colorOrigin

    case colorStory

    case culturalCustoms

    case artApplication

    case symbolism

    case literature

    case dyeingCraft

    case colorDistinction
}

extension TraditionalColorDetailInfoType {

    var title: String {
        switch self {
        case .intro:
            return NSLocalizedString("traditional_detail_intro", comment: "")
        case .colorOrigin:
            return NSLocalizedString("traditional_detail_color_origin", comment: "")
        case .colorStory:
            return NSLocalizedString("traditional_detail_color_story", comment: "")
        case .culturalCustoms:
            return NSLocalizedString("traditional_detail_cultural_customs", comment: "")
        case .artApplication:
            return NSLocalizedString("traditional_detail_art_application", comment: "")
        case .symbolism:
            return NSLocalizedString("traditional_detail_symbolism", comment: "")
        case .literature:
            return NSLocalizedString("traditional_detail_literature", comment: "")
        case .dyeingCraft:
            return NSLocalizedString("traditional_detail_dyeing_craft", comment: "")
        case .colorDistinction:
            return NSLocalizedString("traditional_detail_color_distinction", comment: "")
        }
    }
}
