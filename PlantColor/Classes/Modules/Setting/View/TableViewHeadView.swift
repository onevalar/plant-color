//
//  TableViewHeadView.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import UIKit
import UIColor_Hex_Swift

class TableViewHeadView: View {

    @IBOutlet private weak var headTitleLabel: UILabel!
    
    public var item: SetModel? {
        didSet {
            guard let item = item else { return }
            headTitleLabel.text = item.sectionName
        }
    }
    
    override func makeUI() {
        super.updateUI()
        
        backgroundColor = .clear
        headTitleLabel.textColor = UIColor("#666666")
        
    }
    
}
