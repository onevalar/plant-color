//
//  TraditionalColorDetailViewController.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit

/// 传统色详情页：色彩概述 + 各知识版块（顺序和显隐由"科普页管理"决定）
final class TraditionalColorDetailViewController: ColorDetailPageViewController {

    init(model: TraditionalColorModel) {
        super.init(item: model,
                   subtitle: ColorDetailContent.subtitle(for: model),
                   blocks: ColorDetailContent.blocks(for: model))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
