//
//  HomeChrome.swift
//  PlantColor
//
//  首页四角的玻璃按钮与底部固定文字：设置、搜索在顶部，收藏、分享在底部。
//  中央名称及简述可点击打开可展开的详情面板。
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
    private let glass = GlassEffectView()

    init(symbol: String, selectedSymbol: String? = nil, label: String, diameter: CGFloat = 48) {
        button = GlassIconButton(symbol: symbol, selectedSymbol: selectedSymbol, accessibilityLabel: label)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
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

    func apply(_ palette: BotanicalPalette) {
        overrideUserInterfaceStyle = palette.interfaceStyle
        glass.botanicalSurface = palette.glass.uiColor
        button.iconColor = palette.icon.uiColor
        // Filled heart communicates selection without unchecked red on colored glass.
        button.selectedIconColor = palette.icon.uiColor
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
    /// 是否显示"植物色 / 传统色"切换。只有一种颜色时不需要
    var showsModeSwitch = true {
        didSet { segmented.isHidden = !showsModeSwitch }
    }

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
    func apply(_ palette: BotanicalPalette) {
        settings.apply(palette)
        search.apply(palette)
        overrideUserInterfaceStyle = palette.interfaceStyle
    }

    @objc private func modeChanged() {
        Feedback.lightPrepare()
        onModeChange?(HomeColorMode(rawValue: segmented.selectedSegmentIndex) ?? .botanical)
    }

    @objc private func settingsTapped() { Feedback.lightPrepare(); onSettings?() }
    @objc private func searchTapped() { Feedback.lightPrepare(); onSearch?() }
}

/// 底部两角放置收藏、分享，中央固定显示色名与简述。
final class HomeActionBar: UIView {

    var onInfo: (() -> Void)?
    var onShare: (() -> Void)?

    private let favorite = GlassCircleButton(symbol: "heart", selectedSymbol: "heart.fill",
                                             label: NSLocalizedString("color_add_favorite", comment: ""), diameter: 48)
    private let share = GlassCircleButton(symbol: "square.and.arrow.up",
                                          label: NSLocalizedString("common_share", comment: ""), diameter: 48)
    private let infoButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let summaryLabel = UILabel()
    private var favoriteToken: NotificationToken?

    var item: (any ColorDisplayable)? {
        didSet {
            observeFavorite()
            refresh()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        nameLabel.font = .wenKai(size: 32)
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.65
        summaryLabel.font = .wenKai(size: 12)
        summaryLabel.textAlignment = .center
        summaryLabel.numberOfLines = 2
        summaryLabel.adjustsFontSizeToFitWidth = true
        summaryLabel.minimumScaleFactor = 0.85
        let words = UIStackView(arrangedSubviews: [nameLabel, summaryLabel])
        words.axis = .vertical
        words.spacing = 3
        words.isUserInteractionEnabled = false
        words.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addSubview(words)
        infoButton.accessibilityHint = NSLocalizedString("home_info_hint", comment: "")
        let stack = UIStackView(arrangedSubviews: [favorite, infoButton, share])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 82),
            stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoButton.heightAnchor.constraint(equalTo: heightAnchor),
            words.centerYAnchor.constraint(equalTo: infoButton.centerYAnchor),
            words.leadingAnchor.constraint(equalTo: infoButton.leadingAnchor),
            words.trailingAnchor.constraint(equalTo: infoButton.trailingAnchor),
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
        if let palette = item?.palette { apply(palette) }
        let collected = item?.isCollect ?? false
        favorite.button.isSelected = collected
        favorite.button.accessibilityLabel = NSLocalizedString(collected ? "color_remove_favorite" : "color_add_favorite", comment: "")

        nameLabel.text = item?.displayName
        summaryLabel.text = item?.homeSummary
        infoButton.accessibilityLabel = [item?.displayName, item?.homeSummary].compactMap { $0 }.joined(separator: "，")

    }

    func apply(_ palette: BotanicalPalette) {
        favorite.apply(palette)
        share.apply(palette)
        nameLabel.textColor = palette.name.uiColor
        summaryLabel.textColor = palette.summary.uiColor
        overrideUserInterfaceStyle = palette.interfaceStyle
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
