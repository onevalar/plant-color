//
//  ColorMenuCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/8.
//

import UIKit

class ColorMenuCell: UICollectionViewCell {

    @IBOutlet private weak var button: UIButton!
    
    public var item: MenuType? {
        didSet {

            guard let item = item else { return }
            button.setImage(item.image?.withTintColor(displayItem?.textUIColor ?? .white),
                            for: .normal)
            if item == .collect {
                button.setImage(item.selectedImage, for: .selected)
            } else {
                button.setImage(item.image?.withTintColor(displayItem?.textUIColor ?? .black),
                                for: .selected)
            }
        }
    }

    var displayItem: (any ColorDisplayable)?
    
    public var isButtonSelected: Bool = false {
        didSet {
            button.isSelected = isButtonSelected
        }
    }
}
