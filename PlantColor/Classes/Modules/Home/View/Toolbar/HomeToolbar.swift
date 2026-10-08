//
//  HomeToolbar.swift
//  PlantColor
//
//  首页底部悬浮的玻璃工具条：简介、收藏、搜索、分享、设置。
//  只有一个实例，始终对应屏幕上当前这个颜色。
//

import UIKit
import RealmSwift

final class HomeToolbar: UIView {

    var onInfo: (() -> Void)?
    var onSearch: (() -> Void)?
    var onShare: (() -> Void)?
    var onSettings: (() -> Void)?

    private let glass = GlassEffectView()
    private lazy var infoButton = GlassIconButton(symbol: "text.book.closed",
                                                  accessibilityLabel: NSLocalizedString("home_show_info", comment: ""))
    private lazy var collectButton = GlassIconButton(symbol: "heart", selectedSymbol: "heart.fill",
                                                     accessibilityLabel: NSLocalizedString("color_add_favorite", comment: ""))
    private lazy var searchButton = GlassIconButton(symbol: "magnifyingglass",
                                                    accessibilityLabel: NSLocalizedString("common_search", comment: ""))
    private lazy var shareButton = GlassIconButton(symbol: "square.and.arrow.up",
                                                   accessibilityLabel: NSLocalizedString("common_share", comment: ""))
    private lazy var settingsButton = GlassIconButton(symbol: "slider.horizontal.3",
                                                      accessibilityLabel: NSLocalizedString("setting_title", comment: ""))
    private var favoriteToken: NotificationToken?

    /// 工具条对应的颜色
    var item: (any ColorDisplayable)? {
        didSet {
            observeFavorite()
            refresh()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { favoriteToken?.invalidate() }

    private func setUp() {
        glass.cornerRadius = DS.barHeight / 2
        glass.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)

        let stack = UIStackView(arrangedSubviews: [infoButton, collectButton, searchButton, shareButton, settingsButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: DS.barHeight),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])

        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        collectButton.addTarget(self, action: #selector(collectTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
    }

    /// 图标颜色跟着当前色块的文字色走，保证深浅色块上都看得清
    private func refresh() {
        let color = item?.textUIColor ?? .label
        [infoButton, collectButton, searchButton, shareButton, settingsButton].forEach { $0.iconColor = color }
        collectButton.selectedIconColor = .systemRed
        let collected = item?.isCollect ?? false
        collectButton.isSelected = collected
        collectButton.accessibilityLabel = NSLocalizedString(collected ? "color_remove_favorite" : "color_add_favorite",
                                                             comment: "")
    }

    /// 收藏状态在别处（详情页、收藏列表）改变时，这里的爱心也要跟着变
    private func observeFavorite() {
        favoriteToken?.invalidate()
        favoriteToken = nil
        guard let object = item as? Object, object.realm != nil, !object.isInvalidated else { return }
        favoriteToken = object.observe { [weak self] change in
            if case .change(_, let properties) = change,
               properties.contains(where: { $0.name == "isCollect" }) {
                self?.refresh()
            }
        }
    }

    @objc private func infoTapped() { Feedback.lightPrepare(); onInfo?() }
    @objc private func searchTapped() { Feedback.lightPrepare(); onSearch?() }
    @objc private func shareTapped() { Feedback.lightPrepare(); onShare?() }
    @objc private func settingsTapped() { Feedback.lightPrepare(); onSettings?() }

    @objc private func collectTapped() {
        guard let item else { return }
        Feedback.lightPrepare()
        item.toggleCollect()
        refresh()
    }
}
