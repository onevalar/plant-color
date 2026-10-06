//
//  BaseButton.swift
//  Mobilephone
//
//  Created by Mobilephone on 2021/7/5.
//

import UIKit

class Button: UIButton {

    // MARK: - Inital
    public override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    /// required
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
}
