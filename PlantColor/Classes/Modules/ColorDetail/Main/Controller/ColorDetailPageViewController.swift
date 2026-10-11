//
//  ColorDetailPageViewController.swift
//  PlantColor
//
//  植物色、传统色共用的详情页：顶部色块（含图案与色名）→ 若干信息卡片 → 色值 → 配色推荐。
//  内容层用普通卡片，悬浮控件（导航按钮）才用玻璃，层次更清楚。
//

import UIKit

/// 详情页里的一块内容
enum DetailBlock {
    /// 一段概述文字（不带标题）
    case summary(String)
    /// 若干"名称：内容"的要点
    case facts([(title: String, value: String)])
    /// 带标题的正文；isPoetry 时用诗词的排版
    case text(title: String, body: String, isPoetry: Bool)
    /// 配图（资源名）
    case image(String)
}

class ColorDetailPageViewController: ViewController {

    let item: any ColorDisplayable
    private let blocks: [DetailBlock]
    private let subtitle: String

    init(item: any ColorDisplayable, subtitle: String, blocks: [DetailBlock]) {
        self.item = item
        self.subtitle = subtitle
        self.blocks = blocks
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()
        navigationItem.title = nil
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = ColorDetailActions.barItems(for: item, from: self)
        view.backgroundColor = item.color

        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .onDrag
        scroll.contentInsetAdjustmentBehavior = .automatic
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = DS.spacing + 4
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 8),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -40),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: DS.margin),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -DS.margin),
        ])

        content.addArrangedSubview(makeHero())
        for block in blocks {
            content.addArrangedSubview(ColorDetailBlockView(ink: item.textUIColor).makeView(for: block))
        }

        let footer = ColorInsightFooterView(item: item, horizontalMargin: 0)
        footer.didSelectItem = { [weak self] item in
            self?.navigationController?.pushViewController(item.makeDetailViewController(), animated: true)
        }
        content.addArrangedSubview(footer)
    }

    // MARK: - 顶部色块

    private func makeHero() -> UIView {
        let hasArt = !item.imageName.isEmpty
        let card = UIView()
        card.backgroundColor = item.color
        card.layer.cornerRadius = 28
        card.layer.cornerCurve = .continuous

        let name = UILabel()
        name.text = item.displayName
        name.font = UIFont.wenKai(size: hasArt ? 40 : 64)
        name.textColor = item.textUIColor
        name.textAlignment = .center
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.5
        name.accessibilityTraits = .header

        let sub = UILabel()
        sub.text = subtitle
        sub.numberOfLines = 0
        sub.textAlignment = .center
        sub.font = .preferredFont(forTextStyle: .subheadline)
        sub.adjustsFontForContentSizeCategory = true
        sub.textColor = item.textUIColor.withAlphaComponent(0.72)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        if hasArt {
            let art = UIImageView(image: UIImage(named: item.imageName))
            art.contentMode = .scaleAspectFit
            art.isAccessibilityElement = false
            art.heightAnchor.constraint(equalToConstant: 210).isActive = true
            stack.addArrangedSubview(art)
            stack.setCustomSpacing(16, after: art)
        }
        stack.addArrangedSubview(name)
        if !subtitle.isEmpty { stack.addArrangedSubview(sub) }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: hasArt ? 28 : 56),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: hasArt ? -28 : -56),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
        ])
        return card
    }

}

/// 简介面板和资料库详情共用内容排版与植物色上的文字配色。
struct ColorDetailBlockView {
    let ink: UIColor

    // MARK: - 内容卡片

    func makeView(for block: DetailBlock) -> UIView {
        switch block {
        case let .summary(text):
            return card(containing: bodyLabel(text, poetry: false))
        case let .facts(rows):
            return card(containing: factsView(rows))
        case let .text(title, body, isPoetry):
            let heading = UILabel()
            heading.text = title
            heading.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: .wenKai(size: 22))
            heading.adjustsFontForContentSizeCategory = true
            heading.textColor = ink
            heading.accessibilityTraits = .header
            let stack = UIStackView(arrangedSubviews: [heading, bodyLabel(body, poetry: isPoetry)])
            stack.axis = .vertical
            stack.spacing = 10
            return card(containing: stack)
        case let .image(name):
            return imageView(named: name)
        }
    }

    private func card(containing content: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = ink.withAlphaComponent(0.055)
        card.layer.cornerRadius = DS.cardRadius
        card.layer.cornerCurve = .continuous
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
        ])
        return card
    }

    private func bodyLabel(_ text: String, poetry: Bool) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        let style = NSMutableParagraphStyle()
        style.lineSpacing = poetry ? 8 : 5
        label.attributedText = NSAttributedString(string: text, attributes: [
            .font: UIFontMetrics(forTextStyle: .callout).scaledFont(for: .wenKai(size: 17)),
            .foregroundColor: ink.withAlphaComponent(poetry ? 0.8 : 1),
            .paragraphStyle: style,
        ])
        return label
    }

    private func factsView(_ rows: [(title: String, value: String)]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        for row in rows {
            let title = UILabel()
            title.text = row.title
            title.font = .wenKai(size: 14)
            title.adjustsFontForContentSizeCategory = true
            title.textColor = ink.withAlphaComponent(0.7)
            let value = UILabel()
            value.text = row.value
            value.numberOfLines = 0
            value.font = .wenKai(size: 17)
            value.adjustsFontForContentSizeCategory = true
            value.textColor = ink
            let pair = UIStackView(arrangedSubviews: [title, value])
            pair.axis = .vertical
            pair.spacing = 2
            stack.addArrangedSubview(pair)
        }
        return stack
    }

    private func imageView(named name: String) -> UIView {
        let holder = UIView()
        holder.layer.cornerRadius = DS.cardRadius
        holder.layer.cornerCurve = .continuous
        holder.clipsToBounds = true
        holder.backgroundColor = .clear
        guard let image = UIImage(named: name) else {
            holder.isHidden = true
            return holder
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.isAccessibilityElement = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: holder.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: holder.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: holder.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor,
                                              multiplier: image.size.height / max(image.size.width, 1)),
        ])
        return holder
    }
}
