//
//  ColorModel.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import RealmSwift

class LiteratureModel: RealmExtensionable, Codable {

    /// 标题
    @Persisted var title: String
    /// 作者
    @Persisted var author: String
    /// 内容
    @Persisted var content: String
}

class ColorModel: RealmExtensionable, Codable {
    
    @Persisted(primaryKey: true) var id: Int = 1

    /// 图片名
    @Persisted var imageName: String
    
    /// 色系
    @Persisted(indexed: true) var colorSeries: ColorSeries?
    @Persisted var colorHEX: String
    @Persisted var colorRGB: String
    @Persisted var colorCMYK: String

    /// 植物名
    @Persisted(indexed: true) var plantName: String
    /// 文字颜色
    @Persisted var textColor: String
    /// 植物简介
    @Persisted var plantAbstract: String
    /// 植物科
    @Persisted(indexed: true) var plantFamily: String
    /// 植物属
    @Persisted(indexed: true) var plantGenus: String
    /// 植物拉丁名
    @Persisted var plantLatin: String
    /// 植物别名
    @Persisted(indexed: true) var plantAlias: String
    /// 植物生长习性
    @Persisted var plantGrowHabit: String
    /// 植物地理分布
    @Persisted var plantDistribution: String
    ///  植物园林应用
    @Persisted var plantLandscapeApplication: String
    /// 植物花期
    @Persisted var plantFlorescence: String
    /// 植物果期
    @Persisted var plantFruitingPeriod: String

    /// 植物的由来标题
    @Persisted var plantDerivationTitle: String
    /// 植物的由来详情
    @Persisted var plantDerivationDetail: String

    /// 植物的食物标题
    @Persisted var plantFoodTitle: String
    /// 植物的食物详情
    @Persisted var plantFoodDetail: String

    /// 植物的风俗标题
    @Persisted var plantCustomTitle: String
    /// 植物的风俗详情
    @Persisted var plantCustomDetail: String

    /// 植物的栽培标题
    @Persisted var plantCultivationTitle: String
    /// 植物的栽培详情
    @Persisted var plantCultivationDetail: String

    /// 植物的应用标题
    @Persisted var plantApplicationTitle: String
    /// 植物的应用详情
    @Persisted var plantApplicationDetail: String

    /// 植物的药用功效标题
    @Persisted var plantMedicinalEffectTitle: String
    /// 植物的药用功效详情
    @Persisted var plantMedicinalEffectDetail: String

    /// 植物故事标题
    @Persisted var plantStoryTitle: String
    /// 植物故事详情
    @Persisted var plantStoryDetail: String

    /// 植物花语标题
    @Persisted var plantMeaningsTitle: String
    /// 植物花语详情
    @Persisted var plantMeaningsDetail: String

    /// 植物文学
    @Persisted var plantLiteratureTitle: String
    /// 植物文学
    @Persisted var plantLiteratureDetail: RealmSwift.List<LiteratureModel>

    /// 是否收藏
    @Persisted var isCollect: Bool = false
}
