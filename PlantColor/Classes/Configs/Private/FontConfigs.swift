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

    static func wenKai(size: CGFloat) -> UIFont {
        UIFont(name: "PlantColorWenKai-Regular", size: size) ?? .systemFont(ofSize: size)
    }

}
