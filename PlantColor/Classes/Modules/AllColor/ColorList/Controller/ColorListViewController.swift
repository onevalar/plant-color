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

class ColorListViewController: ColorListBaseViewController {
    // MARK: - LazyLoad

    lazy var tableView: TableView = {
        let tableView = TableView(frame: view.bounds,
                                  style: .insetGrouped)
        return tableView
    }()

    override func makeUI() {
        super.makeUI()

        setUpEmptyDataSet()
        view.addSubview(tableView)
        tableView.rowHeight = ColorListCell.height
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.colorListCell)
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 15
        tableView.contentInset = UIEdgeInsets(top: -25, left: 0, bottom: 0, right: 0)
        loadingNewData()
        tableView.reloadData()
        tableView.addSubview(colorSeriesFilterView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.snp.remakeConstraints {
            $0.top.equalTo(filterMenu.snp.bottom)
            $0.right.left.bottom.equalToSuperview()
        }
    }

    override func loadingDataFinished() {
        tableView.reloadData()
    }

    override func gridDidClick() {
        super.gridDidClick()

        let vc = ColorGridViewController(type: type, searchKey: searchKey)
        vc.isGrid = isGrid
        hero.replaceViewController(with: vc)
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
        items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorListCell.identifier,
                                                 for: indexPath,
                                                 cellType: ColorListCell.self)
        cell.item = items[indexPath.section]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ColorListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushToDetail(index: indexPath.section)
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
