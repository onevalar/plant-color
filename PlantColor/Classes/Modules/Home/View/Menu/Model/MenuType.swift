//
//  MenuType.swift
//  PlantColor
//
//  Created by insect on 2022/2/8.
//

import Foundation
import UIKit

enum MenuType {
    
    case collect
    
    case search
    
    case share
    
    case setting
}

extension MenuType {
    
    var image: UIImage? {
        
        switch self {
        case .collect:
            return .sf(systemSymbol: .heart)
        case .search:
            return .sf(systemSymbol: .magnifyingglass)
        case .share:
            return .sf(systemSymbol: .squareAndArrowUp)
        case .setting:
            return .sf(systemSymbol: .sliderHorizontal3)
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .collect:
            return .sf(systemSymbol: .heartFill, withTintColor: .red)
        case .search:
            return .sf(systemSymbol: .magnifyingglass)
        case .share:
            return .sf(systemSymbol: .squareAndArrowUp)
        case .setting:
            return .sf(systemSymbol: .sliderHorizontal3)
        }
    }
}
