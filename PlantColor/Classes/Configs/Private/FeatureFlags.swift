//
//  FeatureFlags.swift
//  PlantColor
//
//  功能开关。
//

import Foundation

enum FeatureFlags {

    /// 传统色（526 种）在界面上的所有入口：首页切换、色库、搜索、配色推荐、小组件来源、分享等。
    ///
    /// 目前关闭——App 只展示植物色。传统色的数据文件、导入、详情页、分享等代码都原样保留，
    /// 把它改成 true 就能恢复全部传统色界面。
    static let traditionalColorsEnabled = false
}
