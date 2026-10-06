//
// Created by QY on 2021/8/16.
//

import UIKit

class StackView: UIStackView {

    override init(frame: CGRect) {

        super.init(frame: frame)
        makeUI()
    }

    required init(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {

        axis = .vertical
        updateUI()
    }

    func updateUI() {

        setNeedsDisplay()
    }
}
