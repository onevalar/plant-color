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

    /// 自动切换的间隔（5 / 10 / 30 秒）
    case SwitchingInterval

    /// 小组件轮播哪些颜色
    case WidgetSource

    /// 传统色详情页的版块管理
    case TraditionalManagement
}

struct SetModel: Codable {
    
    let sectionName : String
    let imageName   : String
    let title       : String
    let showSwitch  : Bool
    let switchState : Bool
    let setType     : SetType
    
}
