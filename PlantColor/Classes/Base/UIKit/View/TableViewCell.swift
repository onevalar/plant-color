//
//  TableViewCell.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {

        selectionStyle = .none
        backgroundColor = .clear
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
