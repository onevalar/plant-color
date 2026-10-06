//
//  SFImage.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import Foundation
import UIKit
import SFSafeSymbols

extension UIImage {
    
    static func sf(systemSymbol: SFSymbol, withTintColor tintColor: UIColor = .icon) -> UIImage {
        UIImage(systemSymbol: systemSymbol).withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
    }
    
}
