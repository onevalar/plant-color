//
//  ColorCollectViewController.swift
//  PlantColor
//
//  Created by insect on 2022/2/10.
//

import Hero
import UIKit
import EmptyDataSetExtension
import BonMot
import EachNavigationBar

class ColorListViewController: ColorListBaseViewController {
    override var showsCatalogFilters: Bool { type != .collect }
    // MARK: - LazyLoad

    lazy var tableView: TableView = {
        let tableView = TableView(frame: view.bounds,
                                  style: type == .collect ? .plain : .insetGrouped)
        return tableView
    }()
    private lazy var favoritesHeader = FavoritesHeader(frame: .zero)
    private let favoritesBackButton = UIButton(type: .system)
    private let favoritesEditButton = UIButton(type: .system)
    private func itemIndex(for indexPath: IndexPath) -> Int { type == .collect ? indexPath.row : indexPath.section }

    override func makeUI() {
        super.makeUI()

        setUpEmptyDataSet()
        view.addSubview(tableView)
        tableView.rowHeight = ColorListCell.height
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .main
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.colorListCell)
        tableView.register(FavoriteColorCell.self, forCellReuseIdentifier: "FavoriteColorCell")
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 15
        tableView.contentInset = UIEdgeInsets(top: -25, left: 0, bottom: 0, right: 0)
        if type == .collect {
            navigation.item.title = NSLocalizedString("favorites_title", comment: "")
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 81
            tableView.sectionHeaderHeight = 0
            tableView.separatorStyle = .singleLine
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            tableView.contentInset = .zero
            tableView.tableHeaderView = favoritesHeader
            tableView.sectionHeaderTopPadding = 0
            configureFavoritesNavigation()
        } else {
            tableView.addSubview(colorSeriesFilterView)
        }
        loadingNewData { [weak self] in self?.loadingDataFinished() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == .collect { loadingNewData { [weak self] in self?.loadingDataFinished() } }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.snp.remakeConstraints {
            if type == .collect { $0.top.equalToSuperview().offset(navigation.bar.bottom) }
            else { $0.top.equalTo(filterMenu.snp.bottom) }
            $0.right.left.bottom.equalToSuperview()
        }
        if type == .collect {
            let width = tableView.bounds.width
            let size = favoritesHeader.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            if favoritesHeader.frame.width != width || abs(favoritesHeader.frame.height - size.height) > 0.5 {
                favoritesHeader.frame = CGRect(x: 0, y: 0, width: width, height: size.height)
                tableView.tableHeaderView = favoritesHeader
            }
        }
    }

    override func loadingDataFinished() {
        if type == .collect {
            favoritesHeader.update(count: items.count)
            if items.isEmpty { tableView.setEditing(false, animated: false) }
            updateEditButton()
            view.setNeedsLayout()
        }
        tableView.reloadData()
    }

    private func updateEditButton() {
        favoritesEditButton.setTitle(NSLocalizedString(tableView.isEditing ? "common_done" : "common_edit", comment: ""), for: .normal)
        favoritesEditButton.isEnabled = !items.isEmpty
        favoritesEditButton.sizeToFit()
        favoritesEditButton.frame.size = CGSize(width: max(44, favoritesEditButton.bounds.width), height: 44)
    }

    private func configureFavoritesNavigation() {
        favoritesBackButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        favoritesBackButton.accessibilityLabel = NSLocalizedString("common_back", comment: "")
        favoritesBackButton.frame.size = CGSize(width: 44, height: 44)
        navigation.bar.backBarButtonItem = BackBarButtonItem(style: .custom(favoritesBackButton), tintColor: .settingsAccent)
        favoritesEditButton.addTarget(self, action: #selector(editFavorites), for: .touchUpInside)
        favoritesEditButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        favoritesEditButton.titleLabel?.adjustsFontForContentSizeCategory = true
        favoritesEditButton.tintColor = .settingsAccent
        navigation.item.rightBarButtonItem = UIBarButtonItem(customView: favoritesEditButton)
        // iOS 26 does not enumerate the controls of this legacy per-screen bar.
        // Expose its actual buttons in order, retaining the existing back action.
        view.accessibilityElements = [favoritesBackButton, favoritesEditButton, tableView]
    }

    @objc private func editFavorites() {
        tableView.setEditing(!tableView.isEditing, animated: !UIAccessibility.isReduceMotionEnabled)
        updateEditButton()
    }

    override func gridDidClick() {
        super.gridDidClick()

        let vc = ColorGridViewController(type: type, searchKey: searchKey, colorSeries: colorSeries, sourceFilter: sourceFilter)
        vc.isGrid = isGrid
        if UIAccessibility.isReduceMotionEnabled, let navigationController {
            navigationController.setViewControllers(Array(navigationController.viewControllers.dropLast()) + [vc], animated: false)
        } else {
            hero.replaceViewController(with: vc)
        }
    }
    
    private func setUpEmptyDataSet() {
        
        let title = NSLocalizedString("all_color_empty_hint", comment: "").styled(with: .font(UIFont.fzktjwgb10(size: 18) ?? .systemFont(ofSize: 18)),
            .color(.lightGray))
        tableView.emptyDataSet.setConfigAndRun(EmptyDataSetConfig(title: title
                                                                  ,image: R.image.collection_placeholder()))
    }
}

// MARK: - UITableViewDataSource

extension ColorListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        type == .collect ? 1 : items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        type == .collect ? items.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .collect {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteColorCell", for: indexPath) as! FavoriteColorCell
            cell.configure(item: items[itemIndex(for: indexPath)])
            cell.accessibilityCustomActions = colorAccessibilityActions(for: items[itemIndex(for: indexPath)])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorListCell.identifier,
                                                 for: indexPath,
                                                 cellType: ColorListCell.self)
        cell.item = items[itemIndex(for: indexPath)]
        cell.accessibilityCustomActions = colorAccessibilityActions(for: items[itemIndex(for: indexPath)])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { type == .collect }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        NSLocalizedString("color_remove_favorite", comment: "")
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let index = itemIndex(for: indexPath)
        guard type == .collect, editingStyle == .delete, items.indices.contains(index) else { return }
        let item = items[index]
        if item.isCollect { item.toggleCollect() }
        // UIKit finishes its delete-confirmation state after this callback.
        // Refresh afterward so deleting the last row can reliably leave editing.
        loadingNewData { [weak self] in
            DispatchQueue.main.async { self?.loadingDataFinished() }
        }
    }
}

// MARK: - UITableViewDelegate

extension ColorListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard items.indices.contains(itemIndex(for: indexPath)) else { return nil }
        let item = items[itemIndex(for: indexPath)]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in self?.colorActions(for: item) }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else { return }
        pushToDetail(index: itemIndex(for: indexPath))
    }
}

// MARK: - HeroViewControllerDelegate

extension ColorListViewController: HeroViewControllerDelegate {
    func heroWillStartAnimatingTo(viewController: UIViewController) {
        if let _ = viewController as? ColorGridViewController {
            tableView.hero.modifiers = [.ignoreSubviewModifiers]
        } else if viewController is ColorDetailViewController {
        } else {
            tableView.hero.modifiers = [.cascade]
        }
    }

    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        if let _ = viewController as? ColorGridViewController {
            tableView.hero.modifiers = [.ignoreSubviewModifiers]
        } else {
            tableView.hero.modifiers = [.cascade]
        }
    }
}
