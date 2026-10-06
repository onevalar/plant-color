//
//  ColorDetailSubtitleCell.swift
//  PlantColor
//
//  Created by QY on 2022/4/30.
//

import UIKit
import BonMot

class ColorDetailSubtitleCell: UITableViewCell {

    @IBOutlet private weak var subjectLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    public var item: ColorDetailSubtitle? {
        didSet {

            guard let item = item else { return }
            subjectLabel.text = item.safeTitle
            if item.type == .literature {
                detailLabel.attributedText = item.detail.styled(with: BonMotConfigs.colorDetailPoetryStyle)
            } else {
                detailLabel.attributedText = item.detail.styled(with: BonMotConfigs.colorDetailSubtitleStyle)
            }
        }
    }
}
