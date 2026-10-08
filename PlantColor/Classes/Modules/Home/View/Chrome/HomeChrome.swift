//
//  HomeChrome.swift
//  PlantColor
//
//  首页悬浮在色块之上的"玻璃层"：顶部（设置 · 植物/传统 · 搜索）和底部（收藏 · 简介 · 分享）。
//  分工的依据：设置、搜索属于整个 App，放顶部两侧；收藏、简介、分享只针对当前这个颜色，放底部。
//

import UIKit
import RealmSwift

enum HomeColorMode: Int {
    case botanical = 0
    case traditional = 1
}

/// 圆形玻璃按钮
final class GlassCircleButton: UIView {

    let button: GlassIconButton

    init(symbol: String, selectedSymbol: String? = nil, label: String, diameter: CGFloat = 48) {
        button = GlassIconButton(symbol: symbol, selectedSymbol: selectedSymbol, accessibilityLabel: label)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let glass = GlassEffectView()
        glass.cornerRadius = diameter / 2
        glass.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)
        addSubview(button)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),
            glass.topAnchor.constraint(equalTo: topAnchor), glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor), glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor), button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor), button.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 顶部：设置 · 植物色/传统色 · 搜索
final class HomeTopBar: UIView {

    var onSettings: (() -> Void)?
    var onSearch: (() -> Void)?
    var onModeChange: ((HomeColorMode) -> Void)?

    private let settings = GlassCircleButton(symbol: "gearshape", label: NSLocalizedString("setting_title", comment: ""))
    private let search = GlassCircleButton(symbol: "magnifyingglass", label: NSLocalizedString("common_search", comment: ""))
    private let segmented = UISegmentedControl(items: [NSLocalizedString("color_kind_plant", comment: ""),
                                                       NSLocalizedString("color_kind_traditional", comment: "")])

    override init(frame: CGRect) {
        super.init(frame: frame)
        segmented.selectedSegmentIndex = 0
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        segmented.accessibilityLabel = NSLocalizedString("home_mode_label", comment: "")
        let font = UIFont.systemFont(ofSize: 15, weight: .medium)
        segmented.setTitleTextAttributes([.font: font], for: .normal)
        segmented.setTitleTextAttributes([.font: font], for: .selected)
        [settings, segmented, search].forEach(addSubview)
        settings.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            settings.leadingAnchor.constraint(equalTo: leadingAnchor),
            settings.centerYAnchor.constraint(equalTo: centerYAnchor),
            search.trailingAnchor.constraint(equalTo: trailingAnchor),
            search.centerYAnchor.constraint(equalTo: centerYAnchor),
            segmented.centerXAnchor.constraint(equalTo: centerXAnchor),
            segmented.centerYAnchor.constraint(equalTo: centerYAnchor),
            segmented.widthAnchor.constraint(equalToConstant: 164),
            segmented.heightAnchor.constraint(equalToConstant: 40),
        ])
        settings.button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        search.button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(_ mode: HomeColorMode) {
        segmented.selectedSegmentIndex = mode.rawValue
    }

    /// ink：当前色块上文字的颜色
    func apply(ink: UIColor, style: UIUserInterfaceStyle) {
        settings.button.iconColor = ink
        search.button.iconColor = ink
        overrideUserInterfaceStyle = style
    }

    @objc private func modeChanged() {
        Feedback.lightPrepare()
        onModeChange?(HomeColorMode(rawValue: segmented.selectedSegmentIndex) ?? .botanical)
    }

    @objc private func settingsTapped() { Feedback.lightPrepare(); onSettings?() }
    @objc private func searchTapped() { Feedback.lightPrepare(); onSearch?() }
}

/// 底部：收藏 · 简介（主操作）· 分享
final class HomeActionBar: UIView {

    var onInfo: (() -> Void)?
    var onShare: (() -> Void)?

    private let favorite = GlassCircleButton(symbol: "heart", selectedSymbol: "heart.fill",
                                             label: NSLocalizedString("color_add_favorite", comment: ""), diameter: 56)
    private let share = GlassCircleButton(symbol: "square.and.arrow.up",
                                          label: NSLocalizedString("common_share", comment: ""), diameter: 56)
    private let infoButton = UIButton(type: .system)
    private var favoriteToken: NotificationToken?

    var item: (any ColorDisplayable)? {
        didSet {
            observeFavorite()
            refresh()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let infoGlass = GlassEffectView()
        infoGlass.cornerRadius = 28
        infoGlass.translatesAutoresizingMaskIntoConstraints = false
        let infoHolder = UIView()
        infoHolder.translatesAutoresizingMaskIntoConstraints = false
        infoHolder.addSubview(infoGlass)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoHolder.addSubview(infoButton)
        NSLayoutConstraint.activate([
            infoGlass.topAnchor.constraint(equalTo: infoHolder.topAnchor), infoGlass.bottomAnchor.constraint(equalTo: infoHolder.bottomAnchor),
            infoGlass.leadingAnchor.constraint(equalTo: infoHolder.leadingAnchor), infoGlass.trailingAnchor.constraint(equalTo: infoHolder.trailingAnchor),
            infoButton.topAnchor.constraint(equalTo: infoHolder.topAnchor), infoButton.bottomAnchor.constraint(equalTo: infoHolder.bottomAnchor),
            infoButton.leadingAnchor.constraint(equalTo: infoHolder.leadingAnchor), infoButton.trailingAnchor.constraint(equalTo: infoHolder.trailingAnchor),
            infoHolder.heightAnchor.constraint(equalToConstant: 56),
        ])
        infoButton.accessibilityHint = NSLocalizedString("home_info_hint", comment: "")

        let stack = UIStackView(arrangedSubviews: [favorite, infoHolder, share])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoHolder.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
        ])

        favorite.button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        share.button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { favoriteToken?.invalidate() }

    /// 图标和文字颜色跟随当前色块
    private func refresh() {
        let ink = item?.textUIColor ?? .label
        favorite.button.iconColor = ink
        favorite.button.selectedIconColor = .systemRed
        share.button.iconColor = ink
        let collected = item?.isCollect ?? false
        favorite.button.isSelected = collected
        favorite.button.accessibilityLabel = NSLocalizedString(collected ? "color_remove_favorite" : "color_add_favorite", comment: "")

        var config = UIButton.Configuration.plain()
        config.title = NSLocalizedString("home_show_info", comment: "")
        config.image = UIImage(systemName: "chevron.up")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseForegroundColor = ink
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var result = attributes
            result.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return result
        }
        infoButton.configuration = config
    }

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

    @objc private func favoriteTapped() {
        guard let item else { return }
        Feedback.lightPrepare()
        item.toggleCollect()
        refresh()
    }

    @objc private func infoTapped() { Feedback.lightPrepare(); onInfo?() }
    @objc private func shareTapped() { Feedback.lightPrepare(); onShare?() }
}
