//
//  TraditionalColorDetailViewController.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit
import EachNavigationBar
import BonMot

/// Placeholder detail view controller for traditional colors.
/// Full implementation in Phase 6.
class TraditionalColorDetailViewController: ViewController {

    private let model: TraditionalColorModel

    init(model: TraditionalColorModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()
        navigation.item.title = model.name
        navigation.bar.backgroundColor = .white
        view.backgroundColor = .white

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Color swatch
        let swatchView = UIView()
        swatchView.backgroundColor = model.color
        swatchView.layer.cornerRadius = 12
        swatchView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(swatchView)

        // Name label
        let nameLabel = UILabel()
        nameLabel.text = model.name
        nameLabel.font = UIFont.fzktjwgb10(size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
        nameLabel.textColor = model.textUIColor
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        swatchView.addSubview(nameLabel)

        // Pinyin label
        let pinyinLabel = UILabel()
        pinyinLabel.text = model.pinyin
        pinyinLabel.font = .systemFont(ofSize: 14)
        pinyinLabel.textColor = model.textUIColor.withAlphaComponent(0.7)
        pinyinLabel.textAlignment = .center
        pinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        swatchView.addSubview(pinyinLabel)

        // Color values
        let rgbLabel = UILabel()
        rgbLabel.attributedText = model.colorRGBAttributedString(type: .list)
        rgbLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rgbLabel)

        let cmykLabel = UILabel()
        cmykLabel.attributedText = model.colorCMYKAttributedString(type: .list)
        cmykLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cmykLabel)

        let hexLabel = UILabel()
        hexLabel.attributedText = model.colorHexAttributedString(type: .list)
        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hexLabel)

        // Content sections
        let sectionsStack = UIStackView()
        sectionsStack.axis = .vertical
        sectionsStack.spacing = 16
        sectionsStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionsStack)

        let sections: [(String, String)] = [
            (model.colorOriginTitle, model.colorOriginDetail),
            (model.colorStoryTitle, model.colorStoryDetail),
            (model.culturalCustomsTitle, model.culturalCustomsDetail),
            (model.artApplicationTitle, model.artApplicationDetail),
            (model.symbolismTitle, model.symbolismDetail),
            (model.dyeingCraftTitle, model.dyeingCraftDetail),
            (model.colorDistinctionTitle, model.colorDistinctionDetail),
        ]

        for (title, detail) in sections where !detail.isEmpty {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            titleLabel.textColor = .darkText

            let detailLabel = UILabel()
            detailLabel.text = detail
            detailLabel.font = .systemFont(ofSize: 14)
            detailLabel.textColor = .darkGray
            detailLabel.numberOfLines = 0

            let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
            stack.axis = .vertical
            stack.spacing = 6
            sectionsStack.addArrangedSubview(stack)
        }

        NSLayoutConstraint.activate([
            swatchView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            swatchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            swatchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            swatchView.heightAnchor.constraint(equalToConstant: 180),

            nameLabel.centerXAnchor.constraint(equalTo: swatchView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: swatchView.centerYAnchor, constant: -12),

            pinyinLabel.centerXAnchor.constraint(equalTo: swatchView.centerXAnchor),
            pinyinLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            rgbLabel.topAnchor.constraint(equalTo: swatchView.bottomAnchor, constant: 20),
            rgbLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            cmykLabel.topAnchor.constraint(equalTo: rgbLabel.bottomAnchor, constant: 8),
            cmykLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            hexLabel.topAnchor.constraint(equalTo: cmykLabel.bottomAnchor, constant: 8),
            hexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            sectionsStack.topAnchor.constraint(equalTo: hexLabel.bottomAnchor, constant: 24),
            sectionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sectionsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }
}
