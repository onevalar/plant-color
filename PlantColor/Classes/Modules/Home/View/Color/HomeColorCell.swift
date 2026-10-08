//
//  HomeColorCell.swift
//  PlantColor
//
//  首页的一屏：整屏色块 + 居中完整显示的植物图案 + 色名 / 副标题 / HEX。
//  上下滑动换颜色；简介和更多操作通过点击色块或底部工具条打开。
//

import UIKit

final class HomeColorCell: UICollectionViewCell {

    /// 点击色块（图案、名字）想看简介
    var onShowInfo: (() -> Void)?

    private let artView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hexButton = UIButton(type: .system)
    private let stack = UIStackView()

    /// 有图案：内容从顶部撑满到工具条之上，图案在剩余空间里居中缩放
    private var withArtConstraints: [NSLayoutConstraint] = []
    /// 没有图案（传统色）：色名整体在可用区域中间
    private var noArtConstraints: [NSLayoutConstraint] = []

    /// 顶部给"植物 / 传统"切换条留出的高度
    private let topInset: CGFloat = 76
    /// 底部给浮动工具条留出的高度
    private var bottomInset: CGFloat { DS.barHeight + DS.barBottomGap + 28 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var displayItem: (any ColorDisplayable)? {
        didSet { configure() }
    }

    private func setUp() {
        artView.contentMode = .scaleAspectFit
        artView.isAccessibilityElement = false
        artView.setContentHuggingPriority(.defaultLow, for: .vertical)
        artView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "doc.on.doc",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        hexButton.configuration = config
        hexButton.addTarget(self, action: #selector(copyHex), for: .touchUpInside)

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        stack.setCustomSpacing(18, after: artView)
        [artView, nameLabel, subtitleLabel, hexButton].forEach(stack.addArrangedSubview)
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        let guide = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DS.margin + 4),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(DS.margin + 4)),
            artView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
        ])
        withArtConstraints = [
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: topInset),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -bottomInset),
        ]
        noArtConstraints = [
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.topAnchor.constraint(greaterThanOrEqualTo: guide.topAnchor, constant: topInset),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: guide.bottomAnchor, constant: -bottomInset),
        ]

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInfo)))

        nameLabel.isAccessibilityElement = true
        nameLabel.accessibilityTraits = .header
        nameLabel.accessibilityHint = NSLocalizedString("home_info_hint", comment: "")
        nameLabel.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: NSLocalizedString("home_show_info", comment: "")) { [weak self] _ in
                self?.onShowInfo?()
                return true
            },
        ]
    }

    private func configure() {
        guard let item = displayItem else { return }
        let textColor = item.textUIColor
        contentView.backgroundColor = item.color

        let hasArt = !item.imageName.isEmpty
        artView.image = hasArt ? UIImage(named: item.imageName) : nil
        artView.isHidden = !hasArt
        NSLayoutConstraint.deactivate(hasArt ? noArtConstraints : withArtConstraints)
        NSLayoutConstraint.activate(hasArt ? withArtConstraints : noArtConstraints)

        nameLabel.text = item.displayName
        nameLabel.textColor = textColor
        nameLabel.font = UIFont.fzktjwgb10(size: hasArt ? 44 : 76)
        nameLabel.accessibilityLabel = item.displayName

        subtitleLabel.attributedText = nil
        subtitleLabel.text = Self.subtitle(for: item)
        subtitleLabel.textColor = textColor.withAlphaComponent(0.72)

        var config = hexButton.configuration ?? UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(item.colorHEX, attributes: AttributeContainer([
            .font: UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium),
            .foregroundColor: textColor,
        ]))
        let copyIcon = UIImage(systemName: "doc.on.doc",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
        config.image = copyIcon?.withTintColor(textColor.withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        hexButton.configuration = config
        hexButton.accessibilityLabel = "HEX \(item.colorHEX)"
        hexButton.accessibilityHint = NSLocalizedString("detail_tap_to_copy", comment: "")
    }

    /// 植物色：科属 + 拉丁名；传统色：拼音 · 色系
    private static func subtitle(for item: any ColorDisplayable) -> String {
        if let plant = item as? ColorModel {
            let family = [plant.plantFamily, plant.plantGenus].filter { !$0.isEmpty }.joined(separator: " ")
            return [family, plant.plantLatin].filter { !$0.isEmpty }.joined(separator: "\n")
        }
        if let color = item as? TraditionalColorModel {
            return [color.pinyin, color.colorSeries?.title].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
        }
        return ""
    }

    @objc private func showInfo() {
        Feedback.lightPrepare()
        onShowInfo?()
    }

    @objc private func copyHex() {
        guard let item = displayItem else { return }
        ColorClipboard.copy(item.colorHEX, from: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onShowInfo = nil
    }
}
