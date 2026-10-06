//
//  PageUtils.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import Foundation

public class PageUtils {

    /// 获取分页的偏移
    /// - Parameters:
    ///   - current: 当前的页码
    ///   - size: 每页的数量
    /// - Returns: 实际的页码
    public static func offset(current: Int, size: Int) -> Int {
        (current - 1) * size
    }

    /// 获取总页码
    /// - Parameters:
    ///   - total: 表中共有多少数据 count(*)
    ///   - size: 每页的数量
    /// - Returns: 总页码
    public static func total(total: Int, size: Int) -> Int {
        (total + size - 1) / size
    }
}
