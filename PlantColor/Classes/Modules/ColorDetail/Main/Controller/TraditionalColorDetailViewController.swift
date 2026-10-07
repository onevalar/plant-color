//
//  TraditionalColorDetailViewController.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit
import EachNavigationBar

/// 传统色详情页：色块 + 色彩概述 + 各个知识版块（顺序和显隐由"科普页管理"决定）+ 色值（点击复制）+ 配色推荐
class TraditionalColorDetailViewController: ViewController {

    private let model: TraditionalColorModel

    private let margin = ColorInsightFooterView.horizontalMargin

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
        navigation.item.rightBarButtonItems = ColorDetailActions.barItems(for: model, from: self)
        view.backgroundColor = .white

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 20
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: margin),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -margin),
        ])

        content.addArrangedSubview(makeSwatch())
        content.addArrangedSubview(makeBodyLabel(overview))

        for (title, body) in sections() {
            content.addArrangedSubview(makeSection(title: title, body: body))
        }

        // 底部：色值 + 配色推荐（外层已经有边距，这里不再留）
        let footer = ColorInsightFooterView(item: model, horizontalMargin: 0)
        footer.didSelectItem = { [weak self] item in
            self?.navigationController?.pushViewController(item.makeDetailViewController(), animated: true)
        }
        content.addArrangedSubview(footer)
    }

    // MARK: - Content

    /// 色彩概述：有人工补充的"色彩由来"就不再重复，只在没有时按色值生成
    private var overview: String {
        ColorDescriber.summary(for: model)
    }

    /// 按"科普页管理"里设置的顺序，只保留有内容的版块
    private func sections() -> [(String, String)] {
        let order: [TraditionalColorDetailInfoType]
        if let config = try? TraditionalColorDetailConfig.re.objects().first {
            order = config.defaultNow.toArray
        } else {
            order = [.colorOrigin, .colorStory, .culturalCustoms, .artApplication, .dyeingCraft]
        }

        var result: [(String, String)] = []
        for type in order {
            guard let body = body(for: type), !body.isEmpty else { continue }
            result.append((title(for: type), body))
        }
        return result
    }

    private func title(for type: TraditionalColorDetailInfoType) -> String {
        let stored: String
        switch type {
        case .colorOrigin: stored = model.colorOriginTitle
        case .colorStory: stored = model.colorStoryTitle
        case .culturalCustoms: stored = model.culturalCustomsTitle
        case .artApplication: stored = model.artApplicationTitle
        case .symbolism: stored = model.symbolismTitle
        case .literature: stored = model.literatureTitle
        case .dyeingCraft: stored = model.dyeingCraftTitle
        case .colorDistinction: stored = model.colorDistinctionTitle
        case .intro: stored = ""
        }
        return stored.isEmpty ? type.title : stored
    }

    private func body(for type: TraditionalColorDetailInfoType) -> String? {
        switch type {
        case .intro: return nil
        case .colorOrigin: return model.colorOriginDetail
        case .colorStory: return model.colorStoryDetail
        case .culturalCustoms: return model.culturalCustomsDetail
        case .artApplication: return model.artApplicationDetail
        case .symbolism: return model.symbolismDetail
        case .literature: return model.literatureDetailString
        case .dyeingCraft: return model.dyeingCraftDetail
        case .colorDistinction:
            // 没有人工内容时，根据色值生成"和哪些颜色最像、差在哪里"
            if !model.colorDistinctionDetail.isEmpty { return model.colorDistinctionDetail }
            guard let swatch = ColorCatalog.shared.swatch(for: model) else { return nil }
            return ColorDescriber.distinction(for: swatch)
        }
    }

    // MARK: - Views

    private func makeSwatch() -> UIView {
        let swatch = UIView()
        swatch.backgroundColor = model.color
        swatch.layer.cornerRadius = 14
        swatch.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = model.name
        nameLabel.font = UIFont.fzktjwgb10(size: 40)
        nameLabel.textColor = model.textUIColor
        nameLabel.textAlignment = .center

        let detail = [model.pinyin, model.colorSeries?.title].compactMap { $0 }.joined(separator: " · ")
        let pinyinLabel = UILabel()
        pinyinLabel.text = detail
        pinyinLabel.font = .systemFont(ofSize: 13)
        pinyinLabel.textColor = model.textUIColor.withAlphaComponent(0.7)
        pinyinLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [nameLabel, pinyinLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        swatch.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: swatch.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: swatch.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: swatch.trailingAnchor, constant: -12),
        ])
        return swatch
    }

    private func makeBodyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: style,
        ])
        return label
    }

    private func makeSection(title: String, body: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .darkText

        let stack = UIStackView(arrangedSubviews: [titleLabel, makeBodyLabel(body)])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
}
