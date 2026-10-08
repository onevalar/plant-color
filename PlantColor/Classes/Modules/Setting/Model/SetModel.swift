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

    // Append new cases: existing Codable raw values are persisted by older builds.
    case StartupDisplay
    case HapticFeedback
    case AutomaticSwitchOptions
    case Appearance
    case ReduceTransparency
    case ReduceMotion
    case TextSize
    case About
    case WidgetOptions
    case WidgetOpenCurrent
    /// 二级页面入口：显示与辅助功能 / 详情页内容 / 关于与反馈
    case AccessibilityOptions
    case ContentOptions
    case AboutOptions
}

/// 点开行时弹出的下拉菜单里的一项（"打开时显示""界面外观""语言"这类单选项直接在行内选，不再跳页）
struct MenuChoice {
    let title: String
    let isSelected: Bool
    let handler: () -> Void
}

struct SetModel: Codable {
    
    let sectionName : String
    let imageName   : String
    let title       : String
    let showSwitch  : Bool
    let switchState : Bool
    let setType     : SetType

    var detail: String? = nil

    /// 有值时，这一行点开是下拉菜单
    var menu: [MenuChoice]? = nil

    // 菜单里有闭包，不参与编码
    private enum CodingKeys: String, CodingKey {
        case sectionName, imageName, title, showSwitch, switchState, setType, detail
    }
}
