//
//  VerticalButton.swift
//  Candy
//
//  Created by Insect on 2019/5/21.
//  Copyright © 2019 Insect. All rights reserved.
//

import UIKit

class VerticalButton: Button {

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpVertical()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setUpVertical()
    }

    func setUpVertical() {

        guard
            let imageView = imageView,
            let titleLabel = titleLabel
        else {
            return
        }
        imageView.x = (width - 60) / 2
        imageView.y = 10
        imageView.width = 60
        imageView.height = 60

        titleLabel.x = 0
        titleLabel.y = imageView.bottom + 10
        titleLabel.width = width
        titleLabel.height = height - titleLabel.y

        titleLabel.textAlignment = .center
    }
}
