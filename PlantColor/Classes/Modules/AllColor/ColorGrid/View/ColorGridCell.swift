//
//  ColorGridCell.swift
//  PlantColor
//
//  Created by QY on 2022/4/25.
//

import UIKit
import Hero

class ColorGridCell: UICollectionViewCell {

    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = UIFont.fzktjwgb10(size: 20)
        }
    }
    @IBOutlet private weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = 10
        isOpaque = true
    }

    public var item: (any ColorDisplayable)? {
        didSet {

            guard let item = item else { return }
            if item.imageName.isEmpty {
                imageView.isHidden = true
            } else {
                imageView.isHidden = false
                imageView.image = UIImage(named: "\(item.imageName)_mini")
            }
            nameLabel.text = item.displayName
            nameLabel.textColor = item.textUIColor
            backgroundColor = item.color

            // 复用的 cell 会残留上一个颜色的转场 id，所以非植物色要清掉
            if let plant = item as? ColorModel {
                hero.id = "color_\(plant.id)"
                nameLabel.hero.id = "color_name_\(plant.id)"
                imageView.hero.id = "color_image_\(plant.id)"
            } else {
                hero.id = nil
                nameLabel.hero.id = nil
                imageView.hero.id = nil
            }
            hero.modifiers = [.arc]
        }
    }
}
