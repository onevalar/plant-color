//
//  CollectionViewCell.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
