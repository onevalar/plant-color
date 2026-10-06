//
//  ColorCollectCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/10.
//

import UIKit
import Hero

class ColorListCell: UITableViewCell {

    public static let height: CGFloat = 120
    
    @IBOutlet private weak var colorImageView: UIImageView!
    @IBOutlet private weak var colorCMYKLabel: UILabel!
    @IBOutlet private weak var colorRGBLabel: UILabel!
    @IBOutlet private weak var colorHexLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = UIFont.fzktjwgb10(size: 20)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isOpaque = true
    }

    public var item: (any ColorDisplayable)? {
        didSet {
            guard let item = item else { return }
            if item.imageName.isEmpty {
                colorImageView.isHidden = true
            } else {
                colorImageView.isHidden = false
                colorImageView.image = UIImage(named: "\(item.imageName)_mini")
            }
            nameLabel.text = item.displayName
            nameLabel.textColor = item.textUIColor
            colorHexLabel.attributedText = item.colorHexAttributedString(type: .list)
            colorRGBLabel.attributedText = item.colorRGBAttributedString(type: .list)
            colorCMYKLabel.attributedText = item.colorCMYKAttributedString(type: .list)
            backgroundColor = item.color

            if let plant = item as? ColorModel {
                hero.id = "color_\(plant.id)"
                nameLabel.hero.id = "color_name_\(plant.id)"
                colorImageView.hero.id = "color_image_\(plant.id)"
            }
            hero.modifiers = [.arc]
        }
    }
}
