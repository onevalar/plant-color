//
//  ColorDetailManageSectionHeader.swift
//  PlantColor
//
//  Created by QY on 2022/5/2.
//

import UIKit

class ColorDetailManageSectionHeader: UITableViewHeaderFooterView {

    static var height: CGFloat = 60

    @IBOutlet private weak var nameLabel: UILabel!

    public var item: String? {
        didSet {

            nameLabel.text = item
        }
    }
}
