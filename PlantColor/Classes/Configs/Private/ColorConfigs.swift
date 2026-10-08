//
//  UIColor+Common.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

public extension UIColor {

    static var navBarBackground: UIColor {
        .systemBackground
    }
    
    static var navBarTitle: UIColor {
        .label
    }
    
    
    static var icon: UIColor {
        .label
    }
    
    static var main: UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? .systemGroupedBackground : .RGBA(245, 246, 243) }
    }

    static var settingsAccent: UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? .RGBA(160, 185, 167) : .RGBA(61, 86, 72) }
    }
}
