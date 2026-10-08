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
        didSet { updateContent() }
    }

    private func updateContent() {
        guard let item = item else { return }
        var content = UIListContentConfiguration.cell()
        content.text = item.displayName
        content.textProperties.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 15), compatibleWith: traitCollection)
        content.textProperties.numberOfLines = 0
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        contentConfiguration = content
        accessoryType = item.select ? .checkmark : .none
        isAccessibilityElement = true
        accessibilityLabel = item.displayName
        accessibilityTraits = item.select ? [.button, .selected] : .button
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        selectionStyle = .none
    }

}
