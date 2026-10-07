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
