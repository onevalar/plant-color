//
//  TraditionalColorModel.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import RealmSwift

/// 传统色文学引用模型（与植物色共用 LiteratureModel）
class TraditionalColorModel: RealmExtensionable, Codable {

    @Persisted(primaryKey: true) var id: Int = 1

    // MARK: - 基础信息
    /// 色彩名称
    @Persisted(indexed: true) var name: String
    /// 拼音
    @Persisted var pinyin: String
    /// HEX 色值
    @Persisted var colorHEX: String
    /// RGB 色值
    @Persisted var colorRGB: String
    /// CMYK 色值
    @Persisted var colorCMYK: String
    /// 色系分类
    @Persisted(indexed: true) var colorSeries: ColorSeries?
    /// 文字颜色（用于在色彩背景上显示文字）
    @Persisted var textColor: String
    /// 图片名（预留，可用于配图）
    @Persisted var imageName: String

    // MARK: - 色彩由来
    @Persisted var colorOriginTitle: String
    @Persisted var colorOriginDetail: String

    // MARK: - 色彩故事
    @Persisted var colorStoryTitle: String
    @Persisted var colorStoryDetail: String

    // MARK: - 文化习俗
    @Persisted var culturalCustomsTitle: String
    @Persisted var culturalCustomsDetail: String

    // MARK: - 艺术应用
    @Persisted var artApplicationTitle: String
    @Persisted var artApplicationDetail: String

    // MARK: - 象征意义
    @Persisted var symbolismTitle: String
    @Persisted var symbolismDetail: String

    // MARK: - 诗词文学
    @Persisted var literatureTitle: String
    @Persisted var literatureDetail: RealmSwift.List<LiteratureModel>

    // MARK: - 染色工艺
    @Persisted var dyeingCraftTitle: String
    @Persisted var dyeingCraftDetail: String

    // MARK: - 色彩辨析
    @Persisted var colorDistinctionTitle: String
    @Persisted var colorDistinctionDetail: String

    // MARK: - 用户状态
    /// 是否收藏
    @Persisted var isCollect: Bool = false
}
