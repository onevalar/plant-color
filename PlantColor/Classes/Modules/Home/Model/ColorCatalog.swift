//
//  ColorCatalog.swift
//  PlantColor
//
//  把植物色和传统色放进同一个"色库"里，用来做相近色、互补色、邻近色的推荐。
//

import Foundation
import RealmSwift

/// 色库中的一个颜色（轻量，只带推荐所需的信息）
struct ColorSwatch: Equatable {
    let kind: ColorKind
    let id: Int
    let name: String
    let rgb: RGBColor
    let series: ColorSeries?

    var hex: String { rgb.hexString }

    func isSame(as other: ColorSwatch) -> Bool {
        kind == other.kind && id == other.id
    }
}

final class ColorCatalog {

    static let shared = ColorCatalog()

    private var cache: [ColorSwatch]?

    private init() {}

    /// 数据重新导入后调用，下次使用时会重新读取
    func invalidate() {
        cache = nil
    }

    var swatches: [ColorSwatch] {
        if let cache = cache { return cache }
        var result: [ColorSwatch] = []
        if let plants = try? ColorModel.re.objects() {
            for item in plants {
                if let rgb = RGBColor(hex: item.colorHEX) {
                    result.append(ColorSwatch(kind: .plant, id: item.id, name: item.plantName,
                                              rgb: rgb, series: item.colorSeries))
                }
            }
        }
        if FeatureFlags.traditionalColorsEnabled, let traditional = try? TraditionalColorModel.re.objects() {
            for item in traditional {
                if let rgb = RGBColor(hex: item.colorHEX) {
                    result.append(ColorSwatch(kind: .traditional, id: item.id, name: item.name,
                                              rgb: rgb, series: item.colorSeries))
                }
            }
        }
        cache = result
        return result
    }

    func swatch(for item: any ColorDisplayable) -> ColorSwatch? {
        guard let rgb = RGBColor(hex: item.colorHEX) else { return nil }
        return ColorSwatch(kind: item.colorKind, id: item.id, name: item.displayName,
                           rgb: rgb, series: item.colorSeries)
    }

    /// 根据色库里的记录找回完整的颜色对象，用来跳转详情页
    func resolve(_ swatch: ColorSwatch) -> (any ColorDisplayable)? {
        let id = swatch.id
        switch swatch.kind {
        case .plant:
            let plant: ColorModel? = try? ColorModel.re.objects().where { $0.id == id }.first
            return plant
        case .traditional:
            let traditional: TraditionalColorModel? = try? TraditionalColorModel.re.objects().where { $0.id == id }.first
            return traditional
        }
    }

    // MARK: - 推荐

    /// 与目标颜色最接近的颜色（可限定来源）
    func similar(to swatch: ColorSwatch, kind: ColorKind? = nil, limit: Int = 4) -> [ColorSwatch] {
        nearest(to: swatch.rgb, excluding: [swatch], kind: kind, limit: limit)
    }

    /// 互补色：色相转 180°；黑白灰则取明暗相反的颜色
    func complementary(of swatch: ColorSwatch, limit: Int = 3) -> [ColorSwatch] {
        let target: RGBColor
        if swatch.rgb.isNeutral {
            let value = swatch.rgb.hsl
            target = RGBColor(h: value.h, s: value.s, l: 1 - value.l)
        } else {
            target = swatch.rgb.rotatedHue(by: 180)
        }
        return nearest(to: target, excluding: [swatch], kind: nil, limit: limit)
    }

    /// 邻近色：色相左右各偏 30°，保持相近的明度和饱和度
    func analogous(of swatch: ColorSwatch, limit: Int = 4) -> [ColorSwatch] {
        guard !swatch.rgb.isNeutral else { return [] }
        let perSide = max(limit / 2, 1)
        var result: [ColorSwatch] = []
        for degrees in [-30.0, 30.0] {
            let target = swatch.rgb.rotatedHue(by: degrees)
            let found = nearest(to: target, excluding: [swatch] + result, kind: nil, limit: perSide)
            result += found
        }
        return result
    }

    private func nearest(to target: RGBColor,
                         excluding: [ColorSwatch],
                         kind: ColorKind?,
                         limit: Int) -> [ColorSwatch] {
        swatches
            .filter { candidate in
                (kind == nil || candidate.kind == kind)
                    && !excluding.contains(where: { $0.isSame(as: candidate) })
            }
            .map { ($0, $0.rgb.distance(to: target)) }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
}
