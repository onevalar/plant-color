import UIKit

/// 简介与全文是同一张植物色面板；系统滚动手势负责在两个高度间展开、收拢。
final class ColorInfoSheetViewController: UIViewController, UISheetPresentationControllerDelegate {
    private let item: any ColorDisplayable
    private let scroll = UIScrollView()
    private let abstract = UILabel()
    private let details = UIStackView()
    private let expandButton = UIButton(type: .system)
    private var compactIdentifier: UISheetPresentationController.Detent.Identifier = .medium

    init(item: any ColorDisplayable) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                compactIdentifier = .init("plantSummary")
                sheet.detents = [.custom(identifier: compactIdentifier) { context in
                    min(490, context.maximumDetentValue * 0.60)
                }, .large()]
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.selectedDetentIdentifier = compactIdentifier
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.delegate = self
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 不依赖系统 sheet 的透明材质：展开后也必须保持当前植物色。
        view.backgroundColor = item.color
        scroll.backgroundColor = item.color
        let ink = item.textUIColor
        scroll.indicatorStyle = (RGBColor(hex: item.colorHEX)?.lab.l ?? 60) > 60 ? .black : .white
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let swatch = UIView()
        swatch.backgroundColor = item.color
        swatch.layer.cornerRadius = 14
        swatch.layer.borderWidth = 1
        swatch.layer.borderColor = ink.withAlphaComponent(0.2).cgColor
        swatch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([swatch.widthAnchor.constraint(equalToConstant: 28),
                                     swatch.heightAnchor.constraint(equalToConstant: 28)])
        let title = UILabel()
        title.text = item.displayName
        title.font = .wenKai(size: 32)
        title.textColor = item.palette.name.uiColor
        title.accessibilityTraits = .header
        let header = UIStackView(arrangedSubviews: [swatch, title, UIView()])
        header.spacing = 12
        header.alignment = .center

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        abstract.attributedText = NSAttributedString(string: item.displayAbstract.string, attributes: [
            .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .wenKai(size: 16)),
            .foregroundColor: ink,
            .paragraphStyle: paragraph,
        ])
        abstract.adjustsFontForContentSizeCategory = true
        abstract.lineBreakMode = .byTruncatingTail
        abstract.numberOfLines = 5

        expandButton.addTarget(self, action: #selector(toggleExpanded), for: .touchUpInside)
        expandButton.accessibilityIdentifier = "plant.detail.expand"
        details.axis = .vertical
        details.spacing = 18
        let blocks: [DetailBlock]
        if let plant = item as? ColorModel {
            blocks = ColorDetailContent.blocks(for: plant)
        } else if let color = item as? TraditionalColorModel {
            blocks = ColorDetailContent.blocks(for: color)
        } else {
            blocks = []
        }
        let renderer = ColorDetailBlockView(ink: ink)
        for block in blocks { details.addArrangedSubview(renderer.makeView(for: block)) }
        details.isHidden = true

        let stack = UIStackView(arrangedSubviews: [header, abstract, ColorValueView(item: item), expandButton, details])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -32),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: DS.margin),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -DS.margin),
        ])
        applyExpandedState()
    }

    @objc private func toggleExpanded() {
        guard let sheet = sheetPresentationController else { return }
        let expand = sheet.selectedDetentIdentifier != .large
        if !expand { scroll.setContentOffset(.zero, animated: false) }
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = expand ? .large : self.compactIdentifier
            self.applyExpandedState()
        }
    }

    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        applyExpandedState()
    }

    private func applyExpandedState() {
        let expanded = sheetPresentationController?.selectedDetentIdentifier == .large
        abstract.numberOfLines = expanded ? 0 : 5
        details.isHidden = !expanded
        if !expanded { scroll.setContentOffset(.zero, animated: false) }
        var config = UIButton.Configuration.plain()
        config.title = NSLocalizedString(expanded ? "home_collapse_detail" : "home_open_detail", comment: "")
        config.image = UIImage(systemName: expanded ? "chevron.down" : "chevron.up")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = item.textUIColor
        config.background.backgroundColor = item.palette.glass.uiColor
        config.background.cornerRadius = 24
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 18)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var result = attributes
            result.font = .wenKai(size: 17)
            return result
        }
        expandButton.configuration = config
    }
}
