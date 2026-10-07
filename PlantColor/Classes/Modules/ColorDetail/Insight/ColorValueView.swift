//
//  ColorValueView.swift
//  PlantColor
//
//  详情页里的色值卡片：HEX / RGB / CMYK 各占一行，点哪行复制哪行。
//

import UIKit

final class ColorValueView: UIView {

    private let rows: [(title: String, value: String)]

    init(item: any ColorDisplayable) {
        let cmyk = item.colorCMYK.replacingOccurrences(of: ",", with: ", ")
        rows = [("HEX", item.colorHEX),
                ("RGB", item.colorRGB.replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: ",", with: ", ")),
                ("CMYK", cmyk)]
        super.init(frame: .zero)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for (index, row) in rows.enumerated() {
            let control = ValueRow(title: row.title, value: row.value)
            control.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
            control.tag = index
            stack.addArrangedSubview(control)
            if index < rows.count - 1 {
                let line = UIView()
                line.backgroundColor = UIColor.black.withAlphaComponent(0.06)
                line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                stack.addArrangedSubview(line)
            }
        }
        backgroundColor = UIColor.black.withAlphaComponent(0.04)
        layer.cornerRadius = 12
        clipsToBounds = true
    }

    @objc private func rowTapped(_ sender: UIControl) {
        ColorClipboard.copy(rows[sender.tag].value, from: self)
    }
}

private final class ValueRow: UIControl {

    init(title: String, value: String) {
        super.init(frame: .zero)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .gray
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = .darkText

        let icon = UIImageView(image: UIImage(systemName: "doc.on.doc"))
        icon.tintColor = .lightGray
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.widthAnchor.constraint(equalToConstant: 18).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, icon])
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.5 : 1 }
    }
}
