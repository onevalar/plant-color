//
//  BaseResult.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import Foundation

/// 服务端自定义 code
enum ServerCode: Int {
    case success = 2000
}

public struct BaseResult<T: Codable>: Codable {

    /// 状态 code
    let code: Int
    /// 信息
    let msg: String
    /// 数据
    let data: T

    /// 是否返回成功
    var isSuccess: Bool {
        code == ServerCode.success.rawValue
    }
}
