//
//  SettingCell.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleNameLabel: UILabel!
    @IBOutlet private weak var mySwitch: UISwitch!
    
    public static var height: CGFloat {
        52
    }
    
    var switchDidClick: ((Bool) -> Void)?
    
    public var item: SetModel? {
        didSet {

            guard let item = item else { return }
            
            if item.imageName.hasPrefix("sf.") {
                let symbolName = String(item.imageName.dropFirst(3))
                iconImageView.image = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = .icon
            } else {
                iconImageView.image = UIImage(named: item.imageName)
            }
            titleNameLabel.text = item.title
            mySwitch.isHidden = !item.showSwitch
            mySwitch.isOn = item.switchState
            accessoryType = item.showSwitch ? .none : .disclosureIndicator
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    
    @IBAction func switchChange(_ sender: UISwitch) {
        switchDidClick?(sender.isOn)
    }
    
    
    
}
