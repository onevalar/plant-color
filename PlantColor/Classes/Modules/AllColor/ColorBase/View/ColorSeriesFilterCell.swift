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

            if let item = item {
                nameLabel.text = item.title
                colorView.backgroundColor = item.color
                colorView.layer.borderWidth = 0
            } else {
                // 没有色系 = "全部"，用描边的空心色块表示
                nameLabel.text = NSLocalizedString("color_series_all", comment: "")
                colorView.backgroundColor = .white
                colorView.layer.borderWidth = 1
                colorView.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
}
