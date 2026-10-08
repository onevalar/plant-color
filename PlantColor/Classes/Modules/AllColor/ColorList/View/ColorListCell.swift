//
//  ColorCollectCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/10.
//

import UIKit
import Hero

class ColorListCell: UITableViewCell {

    public static let height: CGFloat = 120
    
    @IBOutlet private weak var colorImageView: UIImageView!
    @IBOutlet private weak var colorCMYKLabel: UILabel!
    @IBOutlet private weak var colorRGBLabel: UILabel!
    @IBOutlet private weak var colorHexLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel! {
        didSet {
            nameLabel.font = UIFont.fzktjwgb10(size: 20)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isOpaque = true
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    public var item: (any ColorDisplayable)? {
        didSet {
            guard let item = item else { return }
            if item.imageName.isEmpty {
                colorImageView.isHidden = true
            } else {
                colorImageView.isHidden = false
                colorImageView.image = UIImage(named: "\(item.imageName)_mini")
            }
            nameLabel.text = item.displayName
            accessibilityLabel = item.displayName + ", " + item.colorHEX
            accessibilityValue = item.isCollect ? NSLocalizedString("setting_my_collection", comment: "") : nil
            nameLabel.textColor = item.textUIColor
            colorHexLabel.attributedText = item.colorHexAttributedString(type: .list)
            colorRGBLabel.attributedText = item.colorRGBAttributedString(type: .list)
            colorCMYKLabel.attributedText = item.colorCMYKAttributedString(type: .list)
            backgroundColor = item.color

            // 复用的 cell 会残留上一个颜色的转场 id，所以非植物色要清掉
            if let plant = item as? ColorModel {
                hero.id = "color_\(plant.id)"
                nameLabel.hero.id = "color_name_\(plant.id)"
                colorImageView.hero.id = "color_image_\(plant.id)"
            } else {
                hero.id = nil
                nameLabel.hero.id = nil
                colorImageView.hero.id = nil
            }
            hero.modifiers = [.arc]
        }
    }
}

/// Favorites use a quiet swatch list; the original full-color catalog cards stay intact.
final class FavoriteColorCell: UITableViewCell {
    private let swatch = UIView()
    private let name = UILabel()
    private let hex = UILabel()
    private var colorDescription = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        tintColor = .settingsAccent
        isAccessibilityElement = true
        accessibilityTraits = .button
        swatch.layer.cornerRadius = 14
        swatch.layer.cornerCurve = .continuous
        name.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: UIFont.fzktjwgb10(size: 20) ?? .systemFont(ofSize: 20))
        name.textColor = .label
        name.numberOfLines = 0
        name.adjustsFontForContentSizeCategory = true
        hex.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: .monospacedSystemFont(ofSize: 11, weight: .regular))
        hex.textColor = .secondaryLabel
        hex.adjustsFontForContentSizeCategory = true
        let labels = UIStackView(arrangedSubviews: [name, hex])
        labels.axis = .vertical
        labels.spacing = 2
        let row = UIStackView(arrangedSubviews: [swatch, labels])
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
            swatch.widthAnchor.constraint(equalToConstant: 54),
            swatch.heightAnchor.constraint(equalToConstant: 54),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Let UIKit expose its delete controls while editing; the compact row
        // remains a single named button during normal browsing.
        updateAccessibility()
    }

    private func updateAccessibility() {
        let editing = isEditing
        isAccessibilityElement = !editing
        accessibilityTraits = editing ? [] : .button
        accessibilityLabel = editing ? nil : colorDescription
        accessibilityValue = editing ? nil : NSLocalizedString("setting_my_collection", comment: "")
    }

    func configure(item: any ColorDisplayable) {
        swatch.backgroundColor = item.color
        name.text = item.displayName
        hex.text = item.colorHEX
        colorDescription = item.displayName + ", " + item.colorHEX
        updateAccessibility()
    }
}

final class FavoritesHeader: UIView {
    private let countLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let title = UILabel()
        title.text = NSLocalizedString("favorites_heading", comment: "")
        title.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.fzktjwgb10(size: 26) ?? .systemFont(ofSize: 26, weight: .medium))
        title.textColor = .label
        title.numberOfLines = 0
        title.adjustsFontForContentSizeCategory = true
        title.accessibilityTraits = .header
        countLabel.font = .preferredFont(forTextStyle: .subheadline)
        countLabel.adjustsFontForContentSizeCategory = true
        countLabel.textColor = .secondaryLabel
        countLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [title, countLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func update(count: Int) {
        countLabel.text = String(format: NSLocalizedString("favorites_count", comment: ""), count)
    }
}
