//
//  ColorGridViewController.swift
//  PlantColor
//
//  Created by QY on 2022/4/25.
//

import Hero
import UIKit

class ColorGridViewController: ColorListBaseViewController {
    lazy var collectionView: CollectionView = {
        let collectionView = CollectionView(frame: view.bounds,
                                            collectionViewLayout: ColorGridFlowLayout())
        return collectionView
    }()

    override func makeUI() {
        super.makeUI()

        view.addSubview(collectionView)
        collectionView.register(R.nib.colorGridCell)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .main
        collectionView.dataSource = self
        collectionView.delegate = self
        loadingNewData()
        collectionView.reloadData()
        collectionView.addSubview(colorSeriesFilterView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.snp.remakeConstraints {
            $0.top.equalTo(filterMenu.snp.bottom)
            $0.right.left.bottom.equalToSuperview()
        }
    }

    override func loadingDataFinished() {
        collectionView.reloadData()
    }

    override func listDidClick() {
        super.listDidClick()

        let vc = ColorListViewController(type: type, searchKey: searchKey, colorSeries: colorSeries, sourceFilter: sourceFilter)
        vc.isGrid = isGrid
//        vc.tableView.contentOffset.y = collectionView.contentOffset.y + collectionView.contentInset.top
        if UIAccessibility.isReduceMotionEnabled, let navigationController {
            navigationController.setViewControllers(Array(navigationController.viewControllers.dropLast()) + [vc], animated: false)
        } else {
            hero.replaceViewController(with: vc)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ColorGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorGridCell.identifier,
                                                      for: indexPath,
                                                      cellType: ColorGridCell.self)
        cell.item = items[indexPath.row]
        cell.accessibilityCustomActions = colorAccessibilityActions(for: items[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ColorGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = items[indexPath.item]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in self?.colorActions(for: item) }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushToDetail(index: indexPath.row)
    }
}

// MARK: - HeroViewControllerDelegate

extension ColorGridViewController: HeroViewControllerDelegate {

    func heroWillStartAnimatingTo(viewController: UIViewController) {
        if let _ = viewController as? ColorDetailViewController,
           let index = collectionView.indexPathsForSelectedItems?[0],
           let cell = collectionView.cellForItem(at: index) as? ColorGridCell
        {
            let cellPos = view.convert(cell.center, from: cell)
            collectionView.hero.modifiers = [.scale(3), .translate(x: view.center.x - cellPos.x, y: view.center.y + collectionView.contentInset.top/2/3 - cellPos.y), .ignoreSubviewModifiers, .fade]
        } else {
            collectionView.hero.modifiers = [.cascade]
        }
    }

    func heroWillStartAnimatingFrom(viewController: UIViewController) {
        collectionView.hero.modifiers = [.cascade, .delay(0.2)]
    }
}
