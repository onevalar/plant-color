//
//  ColorSeriesExtension.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//

import UIKit

extension ColorSeries {
    
    var color: UIColor {
        switch self {
        case .red:
            return .RGBA(236, 85, 52)
        case .orange:
            return .RGBA(240, 142, 74)
        case .yellow:
            return .RGBA(245, 184, 71)
        case .green:
            return .RGBA(185, 218, 77)
        case .blue:
            return .RGBA(109, 204, 242)
        case .indigo:
            return .RGBA(56, 123, 171)
        case .purple:
            return .RGBA(84, 68, 100)
        case .brown:
            return .RGBA(106, 82, 39)
        case .gray:
            return .RGBA(196, 204, 207)
        }
    }
}
