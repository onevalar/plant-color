//
//  HUDEnum.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import MBProgressHUD

public enum ProgressHUDAnimation {

    case fade

    case zoom

    case zoomOut

    case zoomIn
}

public enum ProgressHUDMode {

    case indeterminate

    case determinate

    case determinateHorizontalBar

    case annularDeterminate

    case customView

    case text
}

public enum ProgressHUDBackgroundStyle {

    case solidColor

    case blur
}

extension ProgressHUDMode {

    var mbType: MBProgressHUDMode {
        switch self {
        case .indeterminate:
            return .indeterminate
        case .determinate:
            return .determinate
        case .determinateHorizontalBar:
            return .determinateHorizontalBar
        case .annularDeterminate:
            return .annularDeterminate
        case .customView:
            return .customView
        case .text:
            return .text
        }
    }
}

extension ProgressHUDAnimation {

    var mbType: MBProgressHUDAnimation {
        switch self {
        case .fade:
            return .fade
        case .zoom:
            return .zoom
        case .zoomOut:
            return .zoomOut
        case .zoomIn:
            return .zoomIn
        }
    }
}

extension ProgressHUDBackgroundStyle {

    var mbType: MBProgressHUDBackgroundStyle {
        switch self {
        case .solidColor:
            return .solidColor
        case .blur:
            return .blur
        }
    }
}
