//
//  ColorDetailManageCell.swift
//  PlantColor
//
//  Created by QY on 2022/5/2.
//

import UIKit

class ColorDetailManageCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!

    static var height: CGFloat = 44

    public var item: String? {
        didSet {
            nameLabel.text = item
        }
    }
}
