//
//  ColorSeriesFilterCell.swift
//  PlantColor
//
//  Created by QY on 2022/4/27.
//

import UIKit

class ColorSeriesFilterCell: UICollectionViewCell {

    @IBOutlet private weak var colorView: UIView! {
        didSet {
            colorView.cornerRadius = 5
        }
    }
    @IBOutlet private weak var nameLabel: UILabel!

    public var item: ColorSeries? {
        didSet {

            guard let item = item else { return }
            nameLabel.text = item.title
            colorView.backgroundColor = item.color
        }
    }
}
