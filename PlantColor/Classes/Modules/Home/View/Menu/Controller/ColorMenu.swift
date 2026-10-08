//
//  ColorMenu.swift
//  PlantColor
//
//  Created by insect on 2022/2/8.
//

import UIKit
import RealmSwift

class ColorMenu: View {
    
    private let items: [MenuType] = [.collect, .search, .share, .setting]
    private var favoriteToken: NotificationToken?
    
    public var displayItem: (any ColorDisplayable)? {
        didSet {
            favoriteToken?.invalidate()
            favoriteToken = nil
            collectionView.reloadData()
            guard let object = displayItem as? Object, object.realm != nil, !object.isInvalidated else { return }
            favoriteToken = object.observe { [weak self] change in
                if case .change(_, let properties) = change,
                   properties.contains(where: { $0.name == "isCollect" }) {
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    deinit { favoriteToken?.invalidate() }
    
    private lazy var collectionView: CollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = CollectionView(frame: bounds,
                                            collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(R.nib.colorMenuCell)
        return collectionView
    }()
    
    override func makeUI() {
        super.makeUI()
        addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}

// MARK: - UICollectionViewDataSource
extension ColorMenu: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorMenuCell.identifier,
                                                      for: indexPath,
                                                      cellType: ColorMenuCell.self)
        cell.displayItem = displayItem
        let action = items[indexPath.row]
        cell.item = action
        cell.isButtonSelected = action == .collect && (displayItem?.isCollect ?? false)
        cell.onActivate = { [weak self] in self?.performMenuAction(action) }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ColorMenu: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performMenuAction(items[indexPath.row])
    }

    private func performMenuAction(_ action: MenuType) {
        Feedback.lightPrepare()
        switch action {
        case .collect:
            collectClick()
        case .setting:
            settingClick()
        case .share:
            shareClick()
        case .search:
            searchClick()
        }
    }
    
    private func collectClick() {

        guard let item = displayItem else { return }
        item.toggleCollect()
        collectionView.reloadData()
    }
    
    private func settingClick() {
        let vc = NavigationController(rootViewController: SettingViewController())
        parentVC?.present(vc,
                          animated: true,
                          completion: nil)
    }
    
    private func shareClick() {

        guard let item = displayItem else { return }
        let vc = NavigationController(rootViewController: ShareViewController(item: item))
        parentVC?.present(vc, animated: true, completion: nil)
    }
    
    private func searchClick() {

        let vc = NavigationController(rootViewController: ColorListViewController(type: .all))
        parentVC?.present(vc,
                          animated: true,
                          completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ColorMenu: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: width, height: width)
    }
}
