//
//  TableViewHeaderFooterView.swift
//  Mobilephone
//
//  Created by Mobilephone on 2021/7/5.
//

import UIKit

class TableViewHeaderFooterView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        self.backgroundView = UIView(frame: bounds)
        self.backgroundView?.backgroundColor = .clear
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
}
