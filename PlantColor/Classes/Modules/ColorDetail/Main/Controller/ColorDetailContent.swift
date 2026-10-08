//
//  ColorDetailContent.swift
//  PlantColor
//
//  把植物色、传统色的数据整理成详情页要显示的内容块（顺序和显隐跟"科普页管理"一致）。
//

import Foundation

enum ColorDetailContent {

    // MARK: - 植物色

    static func subtitle(for plant: ColorModel) -> String {
        let family = [plant.plantFamily, plant.plantGenus].filter { !$0.isEmpty }.joined(separator: " ")
        return [family, plant.plantLatin].filter { !$0.isEmpty }.joined(separator: "\n")
    }

    static func blocks(for plant: ColorModel) -> [DetailBlock] {
        guard var order = try? ColorDetailConfig.re.objects().first?.defaultNow.toArray else { return [] }
        // 配图穿插在文字之间，与原来的版式保持一致
        order.insert(.image0, at: min(1, order.count))
        order.append(.image2)
        order.insert(.image1, at: min(order.count / 2 + 1, order.count))

        var result: [DetailBlock] = []
        for type in order {
            func text(_ title: String, _ detail: String, poetry: Bool = false) {
                guard !detail.isEmpty else { return }
                let safeTitle = title.isEmpty ? type.title : title
                result.append(.text(title: safeTitle, body: detail, isPoetry: poetry))
            }
            switch type {
            case .intro:
                let rows = facts(for: plant)
                if !rows.isEmpty { result.append(.facts(rows)) }
            case .derivation: text(plant.plantDerivationTitle, plant.plantDerivationDetail)
            case .food: text(plant.plantFoodTitle, plant.plantFoodDetail)
            case .custom: text(plant.plantCustomTitle, plant.plantCustomDetail)
            case .application: text(plant.plantApplicationTitle, plant.plantApplicationDetail)
            case .cultivation: text(plant.plantCultivationTitle, plant.plantCultivationDetail)
            case .medicinalEffect: text(plant.plantMedicinalEffectTitle, plant.plantMedicinalEffectDetail)
            case .story: text(plant.plantStoryTitle, plant.plantStoryDetail)
            case .meanings: text(plant.plantMeaningsTitle, plant.plantMeaningsDetail)
            case .literature:
                if !plant.plantLiteratureDetail.isEmpty {
                    text(plant.plantLiteratureTitle, plant.plantLiteratureDetailString, poetry: true)
                }
            case .image0: result.append(.image("\(plant.detailImageName)_0"))
            case .image1: result.append(.image("\(plant.detailImageName)_1"))
            case .image2: result.append(.image("\(plant.detailImageName)_2"))
            }
        }
        return result
    }

    private static func facts(for plant: ColorModel) -> [(title: String, value: String)] {
        let pairs: [(String, String)] = [
            ("plant_detail_alias", plant.plantAlias),
            ("plant_detail_growth_habit", plant.plantGrowHabit),
            ("plant_detail_distribution", plant.plantDistribution),
            ("plant_detail_landscape_app", plant.plantLandscapeApplication),
            ("plant_detail_florescence", plant.plantFlorescence),
            ("plant_detail_fruiting_period", plant.plantFruitingPeriod),
        ]
        return pairs.compactMap { key, value in
            guard !value.isEmpty else { return nil }
            // 原来的文案以"："或": "结尾，作为小标题时去掉
            let title = NSLocalizedString(key, comment: "").trimmingCharacters(in: CharacterSet(charactersIn: ":： "))
            return (title, value)
        }
    }

    // MARK: - 传统色

    static func subtitle(for color: TraditionalColorModel) -> String {
        [color.pinyin, color.colorSeries?.title].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
    }

    static func blocks(for color: TraditionalColorModel) -> [DetailBlock] {
        var result: [DetailBlock] = [.summary(ColorDescriber.summary(for: color))]

        let order: [TraditionalColorDetailInfoType]
        if let config = try? TraditionalColorDetailConfig.re.objects().first {
            order = config.defaultNow.toArray
        } else {
            order = [.colorOrigin, .colorStory, .culturalCustoms, .artApplication, .dyeingCraft]
        }

        for type in order {
            guard let body = body(for: type, color: color), !body.isEmpty else { continue }
            result.append(.text(title: title(for: type, color: color), body: body, isPoetry: type == .literature))
        }
        return result
    }

    private static func title(for type: TraditionalColorDetailInfoType, color: TraditionalColorModel) -> String {
        let stored: String
        switch type {
        case .colorOrigin: stored = color.colorOriginTitle
        case .colorStory: stored = color.colorStoryTitle
        case .culturalCustoms: stored = color.culturalCustomsTitle
        case .artApplication: stored = color.artApplicationTitle
        case .symbolism: stored = color.symbolismTitle
        case .literature: stored = color.literatureTitle
        case .dyeingCraft: stored = color.dyeingCraftTitle
        case .colorDistinction: stored = color.colorDistinctionTitle
        case .intro: stored = ""
        }
        return stored.isEmpty ? type.title : stored
    }

    private static func body(for type: TraditionalColorDetailInfoType, color: TraditionalColorModel) -> String? {
        switch type {
        case .intro: return nil
        case .colorOrigin: return color.colorOriginDetail
        case .colorStory: return color.colorStoryDetail
        case .culturalCustoms: return color.culturalCustomsDetail
        case .artApplication: return color.artApplicationDetail
        case .symbolism: return color.symbolismDetail
        case .literature: return color.literatureDetailString
        case .dyeingCraft: return color.dyeingCraftDetail
        case .colorDistinction:
            if !color.colorDistinctionDetail.isEmpty { return color.colorDistinctionDetail }
            guard let swatch = ColorCatalog.shared.swatch(for: color) else { return nil }
            return ColorDescriber.distinction(for: swatch)
        }
    }
}
