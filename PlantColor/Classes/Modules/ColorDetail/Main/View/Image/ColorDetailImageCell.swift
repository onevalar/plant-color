//
//  ColorDetailImageCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit

class ColorDetailImageCell: UITableViewCell {

    @IBOutlet private weak var detailImageView: UIImageView!
    public var item: String? {
        didSet {
            
            guard let item = item else { return }
            detailImageView.image = UIImage(named: item)
        }
    }
}
