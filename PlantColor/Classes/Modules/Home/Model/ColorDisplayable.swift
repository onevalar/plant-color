//
//  ColorDisplayable.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit

// MARK: - Protocol

protocol ColorDisplayable: AnyObject {
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
    }

    func makeDetailViewController() -> UIViewController {
        ColorDetailViewController(colorModel: self)
    }
}

// MARK: - TraditionalColorModel Conformance

extension TraditionalColorModel: ColorDisplayable {

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
        let text = candidates.first(where: { !$0.isEmpty }) ?? ""
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
    }

    func makeDetailViewController() -> UIViewController {
        TraditionalColorDetailViewController(model: self)
    }
}
