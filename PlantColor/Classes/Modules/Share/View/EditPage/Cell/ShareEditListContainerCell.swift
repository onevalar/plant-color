//
//  ShareEditListContainerCell.swift
//  PlantColor
//
//  Created by QY on 2022/5/7.
//

import UIKit

class ShareEditListContainerCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = R.font.oppoSansR(size: 15)
        }
    }

    @IBOutlet private weak var iconImageView: UIImageView!

    var isOnSelected: Bool = false {

        didSet {
            if isOnSelected {
                titleLabel.textColor = colorModel?.color
                titleLabel.font = R.font.oppoSansM(size: 15)
            } else {
                titleLabel.textColor = .black
                titleLabel.font = R.font.oppoSansR(size: 15)
            }
        }
    }

    var colorModel: ColorModel?

    var item: ShareEditType? {
        didSet {

            guard let item = item else { return }
            titleLabel.text = item.title
            iconImageView.image = UIImage(named: item.image)
        }
    }
}
