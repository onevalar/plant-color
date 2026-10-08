//
//  ColorMenuCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/8.
//

import UIKit

class ColorMenuCell: UICollectionViewCell {

    @IBOutlet private weak var button: UIButton!
    var onActivate: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = true
        accessibilityTraits = .button
        button.isAccessibilityElement = false
    }

    override func accessibilityActivate() -> Bool {
        guard let onActivate else { return false }
        onActivate()
        return true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onActivate = nil
        accessibilityLabel = nil
    }
    
    public var item: MenuType? {
        didSet {

            guard let item = item else { return }
            updateAccessibilityLabel()
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
            updateAccessibilityLabel()
        }
    }

    private func updateAccessibilityLabel() {
        guard let item else { return }
        let key: String
        switch item {
        case .collect: key = isButtonSelected ? "color_remove_favorite" : "color_add_favorite"
        case .search: key = "common_search"
        case .share: key = "common_share"
        case .setting: key = "setting_title"
        }
        accessibilityLabel = NSLocalizedString(key, comment: "")
    }
}
