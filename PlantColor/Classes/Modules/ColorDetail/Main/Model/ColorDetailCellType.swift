//
//  ColorDetailCellType.swift
//  PlantColor
//
//  Created by insect on 2022/2/8.
//

import Foundation
import RealmSwift

struct ColorDetailSubtitle {
    let title: String
    let detail: String
    let type: ColorDetailInfoType

    var safeTitle: String {
        title.isEmpty ? type.title : title
    }
}

enum ColorDetailCellType {
    
    case intro(ColorModel)
    
    case image(String)

    case subtitle((ColorDetailSubtitle))
}

enum ColorDetailInfoType: String, PersistableEnum, Codable {

    case intro

    case derivation

    case food

    case custom

    case application

    case cultivation

    case medicinalEffect

    case story

    case meanings

    case literature

    case image0

    case image1

    case image2
}

extension ColorDetailInfoType {

    var title: String {
        switch self {
        case .intro:
            return NSLocalizedString("plant_detail_intro", comment: "")
        case .derivation:
            return NSLocalizedString("plant_detail_derivation", comment: "")
        case .food:
            return NSLocalizedString("plant_detail_food", comment: "")
        case .custom:
            return NSLocalizedString("plant_detail_custom", comment: "")
        case .application:
            return NSLocalizedString("plant_detail_application", comment: "")
        case .medicinalEffect:
            return NSLocalizedString("plant_detail_medicinal_effect", comment: "")
        case .story:
            return NSLocalizedString("plant_detail_story", comment: "")
        case .cultivation:
            return NSLocalizedString("plant_detail_cultivation", comment: "")
        case .meanings:
            return NSLocalizedString("plant_detail_meanings", comment: "")
        case .literature:
            return NSLocalizedString("plant_detail_literature", comment: "")
        case .image0:
            return NSLocalizedString("plant_detail_image0", comment: "")
        case .image1:
            return NSLocalizedString("plant_detail_image1", comment: "")
        case .image2:
            return NSLocalizedString("plant_detail_image2", comment: "")
        }
    }
}
