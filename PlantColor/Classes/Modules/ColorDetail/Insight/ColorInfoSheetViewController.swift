//
//  ColorInfoSheetViewController.swift
//  PlantColor
//
//  首页点色块弹出的半屏简介：简介文字 + 色值（点击复制）+ 进入完整详情。
//

import UIKit

final class ColorInfoSheetViewController: UIViewController {

    private let item: any ColorDisplayable
    private let onOpenDetail: () -> Void

    init(item: any ColorDisplayable, onOpenDetail: @escaping () -> Void) {
        self.item = item
        self.onOpenDetail = onOpenDetail
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #unavailable(iOS 26.0) {
            view.backgroundColor = .systemBackground
        }

        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let swatch = UIView()
        swatch.backgroundColor = item.color
        swatch.layer.cornerRadius = 14
        swatch.layer.borderWidth = 0.5
        swatch.layer.borderColor = UIColor.separator.cgColor
        swatch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([swatch.widthAnchor.constraint(equalToConstant: 28),
                                     swatch.heightAnchor.constraint(equalToConstant: 28)])

        let title = UILabel()
        title.text = item.displayName
        title.font = UIFont.fzktjwgb10(size: 30)
        title.textColor = .label
        title.accessibilityTraits = .header

        let header = UIStackView(arrangedSubviews: [swatch, title, UIView()])
        header.axis = .horizontal
        header.spacing = 12
        header.alignment = .center

        let abstract = UILabel()
        abstract.numberOfLines = 0
        let text = NSMutableAttributedString(attributedString: item.displayAbstract)
        text.addAttribute(.foregroundColor, value: UIColor.secondaryLabel,
                          range: NSRange(location: 0, length: text.length))
        abstract.attributedText = text

        let values = ColorValueView(item: item)

        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.title = NSLocalizedString("home_open_detail", comment: "")
        buttonConfig.cornerStyle = .capsule
        buttonConfig.baseBackgroundColor = item.color
        buttonConfig.baseForegroundColor = item.textUIColor
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        let openButton = UIButton(configuration: buttonConfig)
        openButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.dismiss(animated: true) { self.onOpenDetail() }
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [header, abstract, values, openButton])
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: DS.margin),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -DS.margin),
        ])
    }
}
