//
//  TraditionalColorModelExtension.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import Foundation
import UIColor_Hex_Swift

extension TraditionalColorModel {

    var colorRGBArray: [String] {
        if colorRGB.isEmpty { return [] }
        return colorRGB.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var colorCMYKArray: [String] {
        if colorCMYK.isEmpty { return [] }
        return colorCMYK.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var textUIColor: UIColor {
        palette.summary.uiColor
    }

    var color: UIColor {
        UIColor(colorHEX)
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

    var literatureDetailString: String {
        var content = ""
        for (index, item) in literatureDetail.enumerated() {
            content += item.title + "\n"
            content += item.author + "\n"
            content += item.content
            if index != literatureDetail.count - 1 {
                content += "\n\n"
            }
        }
        return content
    }
}
