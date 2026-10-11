//
//  ColorLibraryViewController.swift
//  PlantColor
//
//  色库与收藏：同一个页面，列表 / 网格两种排布随时切换，不再每次换一个新页面。
//  使用系统原生的大标题、搜索栏和筛选菜单。
//

import UIKit
import RealmSwift

final class ColorLibraryViewController: ViewController, UICollectionViewDelegate, UISearchResultsUpdating {

    private struct ItemKey: Hashable {
        let kind: ColorKind
        let id: Int
    }

    let type: ColorListType
    private var searchKey: String?
    private var colorSeries: ColorSeries?
    private var sourceFilter: ColorKind?
    private var items: [any ColorDisplayable] = []
    private var isGrid = false

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Int, ItemKey>!
    private let emptyLabel = UILabel()
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var filterItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), menu: makeFilterMenu())
    private lazy var layoutItem = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(toggleLayout))

    init(type: ColorListType, sourceFilter: ColorKind? = nil) {
        self.type = type
        self.sourceFilter = sourceFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = type == .collect ? NSLocalizedString("favorites_title", comment: "") : type.title
        navigationItem.largeTitleDisplayMode = .always

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.adjustsFontForContentSizeCategory = true
        emptyLabel.textColor = .secondaryLabel
        collectionView.backgroundView = emptyLabel

        configureDataSource()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("color_search_placeholder", comment: "")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        navigationItem.rightBarButtonItems = [layoutItem, filterItem]
        updateBarItems()
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 从详情页回来时，收藏状态可能变了
        reload()
    }

    // MARK: - 排布

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
            guard let self else { return nil }
            return self.isGrid ? self.gridSection(environment) : self.listSection(environment)
        }
    }

    private func listSection(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = .clear
        config.showsSeparators = true
        if type == .collect {
            // 向左滑动即可取消收藏
            config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self, let item = self.item(at: indexPath), item.isCollect else { return nil }
                let remove = UIContextualAction(style: .destructive,
                                                title: NSLocalizedString("color_remove_favorite", comment: "")) { _, _, done in
                    self.toggleFavorite(item)
                    done(true)
                }
                remove.image = UIImage(systemName: "heart.slash")
                return UISwipeActionsConfiguration(actions: [remove])
            }
        }
        return NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
    }

    private func gridSection(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let width = environment.container.effectiveContentSize.width
        let columns = max(2, min(6, Int(width / 150)))
        let spacing: CGFloat = 12
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(1 / CGFloat(columns) * 1.08)),
            subitem: item, count: columns)
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: DS.margin, bottom: 24, trailing: DS.margin)
        return section
    }

    @objc private func toggleLayout() {
        isGrid.toggle()
        updateBarItems()
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        let change = {
            self.collectionView.setCollectionViewLayout(self.makeLayout(), animated: false)
            self.dataSource.applySnapshotUsingReloadData(snapshot)
        }
        if UIAccessibility.isReduceMotionEnabled {
            change()
        } else {
            UIView.transition(with: collectionView, duration: 0.25, options: .transitionCrossDissolve, animations: change)
        }
    }

    private func updateBarItems() {
        layoutItem.image = UIImage(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
        layoutItem.accessibilityLabel = NSLocalizedString(isGrid ? "library_show_list" : "library_show_grid", comment: "")
        let filtering = sourceFilter != nil || colorSeries != nil
        filterItem.image = UIImage(systemName: filtering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        filterItem.menu = makeFilterMenu()
        filterItem.accessibilityLabel = NSLocalizedString("common_filter", comment: "")
    }

    // MARK: - 筛选

    private func makeFilterMenu() -> UIMenu {
        func sourceAction(_ title: String, _ kind: ColorKind?) -> UIAction {
            UIAction(title: title, state: sourceFilter == kind ? .on : .off) { [weak self] _ in
                self?.sourceFilter = kind
                self?.filtersChanged()
            }
        }
        let source = UIMenu(title: NSLocalizedString("filter_source", comment: ""), options: .displayInline, children: [
            sourceAction(NSLocalizedString("color_series_all", comment: ""), nil),
            sourceAction(NSLocalizedString("color_kind_plant", comment: ""), .plant),
            sourceAction(NSLocalizedString("color_kind_traditional", comment: ""), .traditional),
        ])
        // 只有植物色时，"来源"筛选没有意义
        let sections: [UIMenuElement] = FeatureFlags.traditionalColorsEnabled ? [source] : []

        let order: [ColorSeries] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .brown, .gray]
        var seriesActions = [UIAction(title: NSLocalizedString("color_series_all", comment: ""), state: colorSeries == nil ? .on : .off) { [weak self] _ in
            self?.colorSeries = nil
            self?.filtersChanged()
        }]
        for series in order {
            let dot = UIImage(systemName: "circle.fill")?.withTintColor(series.color, renderingMode: .alwaysOriginal)
            seriesActions.append(UIAction(title: series.title, image: dot, state: colorSeries == series ? .on : .off) { [weak self] _ in
                self?.colorSeries = series
                self?.filtersChanged()
            })
        }
        let seriesMenu = UIMenu(title: NSLocalizedString("filter_series", comment: ""), children: seriesActions)
        return UIMenu(children: sections + [seriesMenu])
    }

    private func filtersChanged() {
        updateBarItems()
        reload()
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces)
        let key = (text?.isEmpty ?? true) ? nil : text
        guard key != searchKey else { return }
        searchKey = key
        reload()
    }

    // MARK: - 数据

    private func configureDataSource() {
        let listCell = UICollectionView.CellRegistration<UICollectionViewListCell, ItemKey> { [weak self] cell, _, key in
            guard let self, let item = self.item(for: key) else { return }
            var content = UIListContentConfiguration.subtitleCell()
            content.text = item.displayName
            content.textProperties.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont.wenKai(size: 20))
            content.secondaryText = FeatureFlags.traditionalColorsEnabled ? "\(item.colorHEX) · \(item.colorKind.title)" : item.colorHEX
            content.secondaryTextProperties.color = .secondaryLabel
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .footnote)
            content.image = Self.swatchImage(color: item.color)
            content.imageProperties.maximumSize = CGSize(width: 48, height: 48)
            content.imageProperties.reservedLayoutSize = CGSize(width: 48, height: 48)
            content.imageToTextPadding = 14
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
            cell.accessibilityLabel = item.displayName + ", " + item.colorHEX
            cell.accessibilityValue = item.isCollect ? NSLocalizedString("setting_my_collection", comment: "") : nil
            cell.accessibilityCustomActions = self.colorAccessibilityActions(for: item)
        }
        let gridCell = UICollectionView.CellRegistration<ColorTileCell, ItemKey> { [weak self] cell, _, key in
            guard let self, let item = self.item(for: key) else { return }
            cell.configure(item: item)
            cell.accessibilityCustomActions = self.colorAccessibilityActions(for: item)
        }
        dataSource = UICollectionViewDiffableDataSource<Int, ItemKey>(collectionView: collectionView) { [weak self] view, indexPath, key in
            guard let self else { return nil }
            return self.isGrid
                ? view.dequeueConfiguredReusableCell(using: gridCell, for: indexPath, item: key)
                : view.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: key)
        }
    }

    private static var swatchCache: [UInt: UIImage] = [:]
    private static func swatchImage(color: UIColor) -> UIImage {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let key = UInt(r * 255) << 16 | UInt(g * 255) << 8 | UInt(b * 255)
        if let cached = swatchCache[key] { return cached }
        let size = CGSize(width: 48, height: 48)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            let rect = CGRect(origin: .zero, size: size)
            color.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 14).fill()
            UIColor.separator.setStroke()
            let outline = UIBezierPath(roundedRect: rect.insetBy(dx: 0.25, dy: 0.25), cornerRadius: 14)
            outline.lineWidth = 0.5
            outline.stroke()
        }
        swatchCache[key] = image
        return image
    }

    private func item(for key: ItemKey) -> (any ColorDisplayable)? {
        items.first { $0.colorKind == key.kind && $0.id == key.id }
    }

    private func item(at indexPath: IndexPath) -> (any ColorDisplayable)? {
        guard let key = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return item(for: key)
    }

    private func reload() {
        items = loadPlantItems() + loadTraditionalItems()
        var snapshot = NSDiffableDataSourceSnapshot<Int, ItemKey>()
        snapshot.appendSections([0])
        snapshot.appendItems(items.map { ItemKey(kind: $0.colorKind, id: $0.id) })
        // 内容（如收藏状态）变化也要刷新已有的格子
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: !UIAccessibility.isReduceMotionEnabled && view.window != nil)
        updateEmptyState()
        if #available(iOS 26.0, *), type == .collect {
            navigationItem.subtitle = String(format: NSLocalizedString("favorites_count", comment: ""), items.count)
        }
    }

    private func updateEmptyState() {
        guard items.isEmpty else { emptyLabel.text = nil; return }
        let searching = searchKey != nil || sourceFilter != nil || colorSeries != nil
        emptyLabel.text = NSLocalizedString(searching ? "library_no_results" : (type == .collect ? "all_color_empty_hint" : "library_no_results"), comment: "")
    }

    private func loadPlantItems() -> [any ColorDisplayable] {
        guard sourceFilter != .traditional else { return [] }
        do {
            let result: [ColorModel] = try ColorModel.re.objects().where { [weak self] element in
                guard let self else { return element.id > 0 }
                var query: Query<Bool> = element.id > 0
                if let key = self.searchKey {
                    query = query && (
                        element.plantName.contains(key, options: .caseInsensitive)
                        || element.plantFamily.contains(key, options: .caseInsensitive)
                        || element.plantGenus.contains(key, options: .caseInsensitive)
                        || element.plantAlias.contains(key, options: .caseInsensitive)
                        || element.colorHEX.contains(key, options: .caseInsensitive)
                        || element.plantAbstract.contains(key, options: .caseInsensitive)
                    )
                }
                if let series = self.colorSeries { query = query && element.colorSeries == series }
                if self.type == .collect { query = query && element.isCollect == true }
                return query
            }.toArray
            return result
        } catch {
            AppLogger.shared.error("加载植物颜色失败: \(error.localizedDescription)")
            return []
        }
    }

    private func loadTraditionalItems() -> [any ColorDisplayable] {
        guard FeatureFlags.traditionalColorsEnabled, sourceFilter != .plant else { return [] }
        do {
            let result: [TraditionalColorModel] = try TraditionalColorModel.re.objects().where { [weak self] element in
                guard let self else { return element.id > 0 }
                var query: Query<Bool> = element.id > 0
                if let key = self.searchKey {
                    query = query && (
                        element.name.contains(key, options: .caseInsensitive)
                        || element.pinyin.contains(key, options: .caseInsensitive)
                        || element.colorHEX.contains(key, options: .caseInsensitive)
                    )
                }
                if let series = self.colorSeries { query = query && element.colorSeries == series }
                if self.type == .collect { query = query && element.isCollect == true }
                return query
            }.toArray
            return result
        } catch {
            AppLogger.shared.error("加载传统颜色失败: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - 操作

    private func colorActions(for item: any ColorDisplayable) -> UIMenu {
        let copy = UIAction(title: NSLocalizedString("color_copy_hex", comment: ""), image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
            self.map { ColorClipboard.copy(item.colorHEX, from: $0.view) }
        }
        let favorite = UIAction(title: NSLocalizedString(item.isCollect ? "color_remove_favorite" : "color_add_favorite", comment: ""),
                                image: UIImage(systemName: item.isCollect ? "heart.slash" : "heart")) { [weak self] _ in
            self?.toggleFavorite(item)
        }
        return UIMenu(title: item.displayName, children: [copy, favorite])
    }

    private func colorAccessibilityActions(for item: any ColorDisplayable) -> [UIAccessibilityCustomAction] {
        [
            UIAccessibilityCustomAction(name: NSLocalizedString("color_copy_hex", comment: "")) { [weak self] _ in
                guard let self else { return false }
                ColorClipboard.copy(item.colorHEX, from: self.view)
                return true
            },
            UIAccessibilityCustomAction(name: NSLocalizedString(item.isCollect ? "color_remove_favorite" : "color_add_favorite", comment: "")) { [weak self] _ in
                self?.toggleFavorite(item)
                return true
            },
        ]
    }

    private func toggleFavorite(_ item: any ColorDisplayable) {
        item.toggleCollect()
        reload()
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = item(at: indexPath) else { return }
        navigationController?.pushViewController(item.makeDetailViewController(), animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = item(at: indexPath) else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in self?.colorActions(for: item) }
    }
}

/// 网格里的色块：色名左上、HEX 左下、植物小图案右下
final class ColorTileCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let hexLabel = UILabel()
    private let artView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor

        nameLabel.font = UIFont.wenKai(size: 20)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.6
        hexLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        artView.contentMode = .scaleAspectFit
        artView.isAccessibilityElement = false

        [artView, nameLabel, hexLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            hexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            hexLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            artView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            artView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            artView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.55),
            artView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.55),
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: any ColorDisplayable) {
        contentView.backgroundColor = item.color
        nameLabel.text = item.displayName
        nameLabel.textColor = item.textUIColor
        hexLabel.text = item.colorHEX
        hexLabel.textColor = item.textUIColor.withAlphaComponent(0.75)
        artView.image = item.imageName.isEmpty ? nil : UIImage(named: "\(item.imageName)_mini")
        accessibilityLabel = item.displayName + ", " + item.colorHEX
        accessibilityValue = item.isCollect ? NSLocalizedString("setting_my_collection", comment: "") : nil
    }
}
