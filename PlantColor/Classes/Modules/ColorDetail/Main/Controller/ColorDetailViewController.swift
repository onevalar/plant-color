//
//  ColorDetailViewController.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit

/// 植物色详情页：内容由 ColorDetailContent 整理，页面由 ColorDetailPageViewController 统一绘制
final class ColorDetailViewController: ColorDetailPageViewController {

    init(colorModel: ColorModel) {
        super.init(item: colorModel,
                   subtitle: ColorDetailContent.subtitle(for: colorModel),
                   blocks: ColorDetailContent.blocks(for: colorModel))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
