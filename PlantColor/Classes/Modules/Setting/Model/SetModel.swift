//
//  SetModel.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import UIKit

enum SetType: Int, Codable {
    
    case AllColor
    
    case MyCollection
    
    case ScientificManagement
    
    case AutomaticSwitch
    
    case RandomSwitching
    
    case ShowFigure
    
    case ShowColorValue
    
    case CustomContent
    
    case ColorRefresh
    
    case Acknowledgement
    
    case ShareApplication
    
    case EvaluationApplication
    
    case ContactFeedback

    case Language
}

struct SetModel: Codable {
    
    let sectionName : String
    let imageName   : String
    let title       : String
    let showSwitch  : Bool
    let switchState : Bool
    let setType     : SetType
    
}
