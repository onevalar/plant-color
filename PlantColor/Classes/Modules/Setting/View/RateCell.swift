//
//  RateCell.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import UIKit

class RateCell: UITableViewCell {

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var selectImageView: UIImageView!
    
    
    public static var height: CGFloat {
        52
    }
    
    
    public var item: RateModel? {
        didSet {

            guard let item = item else { return }
            rateLabel.text = item.displayName
            selectImageView.isHidden = !item.select
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

}
