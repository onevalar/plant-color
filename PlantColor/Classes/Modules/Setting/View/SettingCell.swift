import UIKit

class SettingCell: UITableViewCell {
    // Kept for compatibility with the existing nib; settings now use native content configurations.
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleNameLabel: UILabel!
    @IBOutlet private weak var mySwitch: UISwitch!
    private let preferenceSwitch = UISwitch()
    static let height: CGFloat = 52
    var switchDidClick: ((Bool) -> Void)?
    var item: SetModel? { didSet { updateContent() } }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        configure()
    }
    private func configure() {
        selectionStyle = .none
        preferenceSwitch.addTarget(self, action: #selector(switchChange(_:)), for: .valueChanged)
        preferenceSwitch.onTintColor = .settingsAccent
    }
    private func updateContent() {
        guard let item else { return }
        var content = UIListContentConfiguration.valueCell()
        content.text = item.title
        content.secondaryText = item.showSwitch ? nil : item.detail
        content.textProperties.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 15), compatibleWith: traitCollection)
        content.textProperties.numberOfLines = 0
        content.secondaryTextProperties.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 13), compatibleWith: traitCollection)
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.numberOfLines = 0
        content.prefersSideBySideTextAndSecondaryText = !traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        content.textToSecondaryTextVerticalPadding = 4
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        if item.imageName.hasPrefix("sf.") {
            content.image = UIImage(systemName: String(item.imageName.dropFirst(3)))
            content.imageProperties.tintColor = .secondaryLabel
        } else { content.image = UIImage(named: item.imageName) }
        content.imageProperties.maximumSize = CGSize(width: 24, height: 24)
        contentConfiguration = content
        accessoryType = item.showSwitch ? .none : .disclosureIndicator
        accessoryView = item.showSwitch ? preferenceSwitch : nil
        preferenceSwitch.isOn = item.switchState
        preferenceSwitch.accessibilityLabel = item.title
        if item.showSwitch {
            isAccessibilityElement = false
            accessibilityLabel = nil
            accessibilityValue = nil
            accessibilityTraits = []
            accessibilityElements = [preferenceSwitch]
        } else {
            accessibilityElements = nil
            isAccessibilityElement = true
            accessibilityLabel = item.title
            accessibilityValue = item.detail
            accessibilityTraits = .button
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContent()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        switchDidClick = nil
        accessibilityValue = nil
    }
    @IBAction func switchChange(_ sender: UISwitch) { switchDidClick?(sender.isOn) }
}
