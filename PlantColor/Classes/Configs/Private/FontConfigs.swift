//
//  Font.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import Foundation
import UIKit
import UIFontComplete

extension UIFont {

    static func pingFangRegular(size: CGFloat) -> UIFont {
        UIFont(font: .pingFangSCRegular, size: size)!
    }
    
    static func pingFangSemibold(size: CGFloat) -> UIFont {
        UIFont(font: .pingFangSCSemibold, size: size)!
    }

    static func fzktjwgb10(size: CGFloat) -> UIFont {
        UIFont(name: "FZKTJW--GB1-0", size: size) ?? .systemFont(ofSize: size)
    }

}
