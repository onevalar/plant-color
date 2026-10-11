//
//  ColorModelExtension.swift
//  PlantColor
//
//  Created by insect on 2022/2/10.
//

import Foundation
import UIColor_Hex_Swift

enum ControllerType {
    case home
    case list
}

extension ColorModel {
    
    var detailImageName: String {
        "\(imageName)_detail"
    }
    
    var colorRGBString: String {
        let stringArray: [String] = ["R", "G", "B"]
        let result = NSMutableString()
        for (index, value) in colorRGBArray.enumerated() {
            result.append(stringArray[index])
            result.append(value)
            result.append(" ")
        }
        return result as String
    }
    
    var colorCMYKString: String {
        
        let stringArray: [String] = ["C", "M", "Y", "K"]
        let result = NSMutableString()
        for (index, value) in colorCMYKArray.enumerated() {
            result.append(stringArray[index])
            result.append(value)
            result.append(" ")
        }
        return result as String
    }

    var colorRGBArray: [String] {
        if colorRGB.isEmpty { return [] }
        return colorRGB.components(separatedBy: ",")
    }
    
    var colorCMYKArray: [String] {
        if colorCMYK.isEmpty { return [] }
        return colorCMYK.components(separatedBy: ",")
    }

    var plantLiteratureDetailString: String {
        var content = ""
        for (index, item) in plantLiteratureDetail.enumerated() {
            content += item.title + "\n"
            content += item.author + "\n"
            content += item.content
            if index != plantLiteratureDetail.count - 1 {
                content += "\n\n"
            }
        }
        return content
    }

    var textUIColor: UIColor {
        palette.summary.uiColor
    }
    
    var color: UIColor {
        UIColor(colorHEX)
    }
}
