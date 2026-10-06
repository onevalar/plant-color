//
//  ColorModel+AttributeString.swift
//  PlantColor
//
//  Created by insect on 2022/5/10.
//

import BonMot

extension ColorModel {
    
    func colorRGBAttributedString(type: ControllerType) -> NSAttributedString {
        
        let stringArray: [String] = ["R", "G", "B"]
        let result = NSMutableAttributedString()
        for (index, value) in colorRGBArray.enumerated() {
            switch type {
            case .home:
                result.append(stringArray[index].styled(with: homeColorSmallStyle))
                result.append(value.styled(with: homeColorBigStyle))
            case .list:
                result.append(stringArray[index].styled(with: listColorSmallStyle))
                result.append(value.styled(with: listColorBigStyle))
            }
            result.append(" ".attributedString())
        }
        return result
    }
    
    func colorCMYKAttributedString(type: ControllerType) ->  NSAttributedString {
        
        let stringArray: [String] = ["C", "M", "Y", "K"]
        let result = NSMutableAttributedString()
        for (index, value) in colorCMYKArray.enumerated() {
            switch type {
            case .home:
                result.append(stringArray[index].styled(with: homeColorSmallStyle))
                result.append(value.styled(with: homeColorBigStyle))
            case .list:
                result.append(stringArray[index].styled(with: listColorSmallStyle))
                result.append(value.styled(with: listColorBigStyle))
            }
            result.append(" ".attributedString())
        }
        return result
    }
    
    func colorHexAttributedString(type: ControllerType) ->  NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        if colorHEX.isEmpty { return result }

        switch type {
        case .home:
            result.append("#".styled(with: homeColorSmallStyle))
        case .list:
            result.append("#".styled(with: listColorSmallStyle))
        }
        let index = colorHEX.index(colorHEX.startIndex, offsetBy: 1)
        let color = String(colorHEX[index..<colorHEX.endIndex])

        switch type {
        case .home:
            result.append(color.styled(with: homeColorBigStyle))
        case .list:
            result.append(color.styled(with: listColorBigStyle))
        }
        return result
    }
    
    var plantLatinAttributeString: NSAttributedString {
        
        let result = NSMutableAttributedString()
        result.append(NSLocalizedString("home_latin_prefix", comment: "").styled(with: .font(R.font.oppoSansR(size: 12) ?? .systemFont(ofSize: 12))))
        result.append("\(plantLatin)\n".styled(with: .font(R.font.sarasaGothicSCItalic(size: 12) ?? .systemFont(ofSize: 12))))
        return result
    }
    
    var plantAbstractAttributeString: NSAttributedString {
        plantAbstract.styled(with: .font(R.font.oppoSansR(size: 14) ?? .systemFont(ofSize: 14)),
            .lineSpacing(6))
    }

    private var listColorBigStyle: BonMot.StringStyle {
        StringStyle(.color(textUIColor),
                    .font(.systemFont(ofSize: 12)))
    }

    private var listColorSmallStyle: BonMot.StringStyle {
        StringStyle(.color(textUIColor.withAlphaComponent(0.5)),
                           .font(.systemFont(ofSize: 10)))
    }

    private var homeColorBigStyle: BonMot.StringStyle {
        StringStyle(.color(textUIColor),
                    .font(.systemFont(ofSize: 20)))
    }

    private var homeColorSmallStyle: BonMot.StringStyle {
        StringStyle(.color(textUIColor.withAlphaComponent(0.5)),
                           .font(.systemFont(ofSize: 15)))
    }
}
