//
//  ColorDisplayable.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit

// MARK: - Kind

/// 颜色的来源：植物色 / 传统色
enum ColorKind: String {
    case plant
    case traditional

    var title: String {
        switch self {
        case .plant: return NSLocalizedString("color_kind_plant", comment: "")
        case .traditional: return NSLocalizedString("color_kind_traditional", comment: "")
        }
    }
}

// MARK: - Protocol

protocol ColorDisplayable: AnyObject {
    /// 数据库主键。植物色与传统色各自独立编号，需配合 colorKind 才能唯一确定一个颜色
    var id: Int { get }
    var colorKind: ColorKind { get }
    var colorHEX: String { get }
    var colorRGB: String { get }
    var colorCMYK: String { get }
    var colorSeries: ColorSeries? { get }
    var displayName: String { get }
    var displayAbstract: NSAttributedString { get }
    var color: UIColor { get }
    var textUIColor: UIColor { get }
    var imageName: String { get }
    var isCollect: Bool { get }
    func colorRGBAttributedString(type: ControllerType) -> NSAttributedString
    func colorCMYKAttributedString(type: ControllerType) -> NSAttributedString
    func colorHexAttributedString(type: ControllerType) -> NSAttributedString
    func toggleCollect()
    func makeDetailViewController() -> UIViewController
}

// MARK: - ColorModel Conformance

extension ColorModel: ColorDisplayable {

    var colorKind: ColorKind {
        .plant
    }

    var displayName: String {
        plantName
    }

    var displayAbstract: NSAttributedString {
        plantAbstractAttributeString
    }

    func toggleCollect() {
        ColorModel.re.transaction(writeHandler: { _ in
            self.isCollect = !self.isCollect
        })
        WidgetPlaylist.collectDidChange()
    }

    func makeDetailViewController() -> UIViewController {
        ColorDetailViewController(colorModel: self)
    }
}

// MARK: - TraditionalColorModel Conformance

extension TraditionalColorModel: ColorDisplayable {

    var colorKind: ColorKind {
        .traditional
    }

    var displayName: String {
        name
    }

    var displayAbstract: NSAttributedString {
        // Use first non-empty content section as abstract
        let candidates = [
            colorOriginDetail,
            colorStoryDetail,
            culturalCustomsDetail,
            artApplicationDetail,
            symbolismDetail,
            dyeingCraftDetail,
            colorDistinctionDetail
        ]
        let text = candidates.first(where: { !$0.isEmpty }) ?? ColorDescriber.summary(for: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        return NSAttributedString(string: text, attributes: [
            .font: R.font.oppoSansR(size: 14) ?? UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle
        ])
    }

    func toggleCollect() {
        TraditionalColorModel.re.transaction(writeHandler: { _ in
            self.isCollect = !self.isCollect
        })
        WidgetPlaylist.collectDidChange()
    }

    func makeDetailViewController() -> UIViewController {
        TraditionalColorDetailViewController(model: self)
    }
}

extension ColorDisplayable {
    /// 每条保持简短，避免不同植物的正文长度改变首页布局。
    var homeSummary: String {
        let summaries = [
            "栀子": "花开清白，果实染黄", "檎丹": "林间野苹果的一抹红",
            "顺圣": "秋菊花瓣间的浅紫", "欧碧": "牡丹花间的一缕浅绿",
            "魏红": "千叶牡丹，层叠肉红", "丹罽": "荔枝枝头的鲜红",
            "鞠衣": "秋菊凝成的明黄", "菘蓝": "一片绿叶，染出靛蓝",
            "郁金裙": "阳光浸润的姜黄", "缃叶": "初生桑叶的嫩黄",
            "姚黄": "洛阳牡丹的一枝金黄", "鞓红": "牡丹盛放的浓红",
            "银红": "牡丹红里泛起银光", "魏紫": "牡丹层瓣间的紫意",
            "松花": "松枝春日的新黄", "芸黄": "凌霄花开，明黄映夏",
            "麴尘": "初生柳叶的一抹嫩色", "柘黄": "柘木染出的暖黄",
            "盈盈": "桃花映水，浅浅春红", "绿沈": "西瓜皮上的深沉绿意",
            "木槿": "朝开暮落，花开不息", "樱花": "春风里的一树柔粉",
            "绢纨": "成熟麦茎的浅黄", "紫菀": "秋日花瓣的一点紫",
            "枣褐": "熟枣凝成的红褐", "紫菂": "莲蓬里嫩莲子的紫",
            "莲红": "莲花映水，清香悠长", "杏子": "枝头熟杏的黄红",
            "棠梨": "棠梨叶染出的红褐", "紫梅": "梅枝上凝聚的紫意",
            "丁香": "细小花簇，幽香绵长", "苍筤": "初生竹子的春日青绿",
        ]
        if colorKind == .plant, let summary = summaries[displayName] { return summary }
        return String(displayAbstract.string.split(whereSeparator: { "。！？\n".contains($0) }).first ?? "")
    }
}

extension RGBColor {
    var uiColor: UIColor { UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1) }
}

/// Bounded, thread-safe cache: scrolling can visit many intermediate background colors.
private final class PaletteBox: NSObject {
    let value: BotanicalPalette
    init(_ value: BotanicalPalette) { self.value = value }
}
private let botanicalPaletteCache: NSCache<NSString, PaletteBox> = {
    let cache = NSCache<NSString, PaletteBox>()
    cache.countLimit = 512
    return cache
}()
extension BotanicalPalette {
    static func cached(background: RGBColor) -> BotanicalPalette {
        let key = background.hexString as NSString
        if let box = botanicalPaletteCache.object(forKey: key) { return box.value }
        let value = make(background: background)
        botanicalPaletteCache.setObject(PaletteBox(value), forKey: key)
        return value
    }
    var interfaceStyle: UIUserInterfaceStyle { usesDarkInk ? .light : .dark }
}
extension ColorDisplayable {
    var palette: BotanicalPalette {
        .cached(background: RGBColor(hex: colorHEX) ?? RGBColor(r: 255, g: 255, b: 255))
    }
}
