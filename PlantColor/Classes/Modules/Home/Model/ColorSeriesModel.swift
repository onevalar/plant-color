//
//  ColorSeriesModel.swift
//  PlantColor
//
//  Created by QY on 2022/4/27.
//

import RealmSwift

enum ColorSeries: String, PersistableEnum, Codable {

    case red

    case orange

    case yellow

    case green

    case blue

    case indigo

    case purple

    case brown

    case gray
}

extension ColorSeries {
    var title: String {
        switch self {
        case .red:
            return NSLocalizedString("color_series_red", comment: "")
        case .orange:
            return NSLocalizedString("color_series_orange", comment: "")
        case .yellow:
            return NSLocalizedString("color_series_yellow", comment: "")
        case .green:
            return NSLocalizedString("color_series_green", comment: "")
        case .blue:
            return NSLocalizedString("color_series_blue", comment: "")
        case .indigo:
            return NSLocalizedString("color_series_indigo", comment: "")
        case .purple:
            return NSLocalizedString("color_series_purple", comment: "")
        case .brown:
            return NSLocalizedString("color_series_brown", comment: "")
        case .gray:
            return NSLocalizedString("color_series_gray", comment: "")
        }
    }

}
