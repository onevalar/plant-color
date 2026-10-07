//
//  ColorHarmonyView.swift
//  PlantColor
//
//  详情页底部的"配色推荐"：相近色、跨类对照、互补色、邻近色。
//

import UIKit

final class ColorHarmonyView: UIView {

    /// 点了某个推荐色
    var didSelect: ((ColorSwatch) -> Void)?

    init(item: any ColorDisplayable, catalog: ColorCatalog = .shared) {
        super.init(frame: .zero)
        guard let swatch = catalog.swatch(for: item) else { return }

        let otherKind: ColorKind = swatch.kind == .plant ? .traditional : .plant
        let otherTitle = String(format: NSLocalizedString("harmony_similar_in_kind", comment: ""), otherKind.title)
        let sections: [(String, [ColorSwatch])] = [
            (NSLocalizedString("harmony_similar", comment: ""), catalog.similar(to: swatch, kind: swatch.kind)),
            (otherTitle, catalog.similar(to: swatch, kind: otherKind)),
            (NSLocalizedString("harmony_complementary", comment: ""), catalog.complementary(of: swatch)),
            (NSLocalizedString("harmony_analogous", comment: ""), catalog.analogous(of: swatch)),
        ].filter { !$0.1.isEmpty }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let header = UILabel()
        header.text = NSLocalizedString("harmony_title", comment: "")
        header.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textColor = .darkText
        stack.addArrangedSubview(header)

        for (title, swatches) in sections {
            stack.addArrangedSubview(makeRow(title: title, swatches: swatches))
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeRow(title: String, swatches: [ColorSwatch]) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .gray

        let chips = UIStackView()
        chips.axis = .horizontal
        chips.spacing = 12
        chips.alignment = .top
        for swatch in swatches {
            let chip = ColorChip(swatch: swatch)
            chip.addAction { [weak self] in self?.didSelect?(swatch) }
            chips.addArrangedSubview(chip)
        }

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceHorizontal = true
        chips.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(chips)
        NSLayoutConstraint.activate([
            chips.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            chips.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            chips.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            chips.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            chips.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
            scroll.heightAnchor.constraint(equalToConstant: ColorChip.height),
        ])

        let column = UIStackView(arrangedSubviews: [titleLabel, scroll])
        column.axis = .vertical
        column.spacing = 8
        return column
    }
}

/// 一个可点击的色块：色块 + 名字 + HEX
private final class ColorChip: UIControl {

    static let height: CGFloat = 96

    private var handler: (() -> Void)?

    init(swatch: ColorSwatch) {
        super.init(frame: .zero)

        let color = UIView()
        color.backgroundColor = UIColor(red: CGFloat(swatch.rgb.r) / 255,
                                        green: CGFloat(swatch.rgb.g) / 255,
                                        blue: CGFloat(swatch.rgb.b) / 255,
                                        alpha: 1)
        color.layer.cornerRadius = 10
        color.layer.borderWidth = 0.5
        color.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        color.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let name = UILabel()
        name.text = swatch.name
        name.font = .systemFont(ofSize: 12, weight: .medium)
        name.textColor = .darkText
        name.textAlignment = .center
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.7

        let hex = UILabel()
        hex.text = swatch.hex
        hex.font = .systemFont(ofSize: 10)
        hex.textColor = .gray
        hex.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [color, name, hex])
        stack.axis = .vertical
        stack.spacing = 3
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            widthAnchor.constraint(equalToConstant: 72),
        ])
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addAction(_ handler: @escaping () -> Void) {
        self.handler = handler
    }

    @objc private func tapped() {
        handler?()
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.5 : 1 }
    }
}
