//
//  MBProgressHUDNameSpace.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import Foundation

public protocol MBHUDCompatible {

    associatedtype T

    var mbHUD: MBHUDWrapper<T> { get }
}

public extension MBHUDCompatible {

    var mbHUD: MBHUDWrapper<Self> {
        return MBHUDWrapper(self)
    }

    static var mbHUD: MBHUDWrapper<Self>.Type {
        return MBHUDWrapper<Self>.self
    }
}

extension UIView: MBHUDCompatible {}
