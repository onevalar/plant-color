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
    
    public var displayItem: (any ColorDisplayable)? {
        didSet {
            collectionView.reloadData()
        }
    }
    
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
        cell.item = items[indexPath.row]
        cell.isButtonSelected = displayItem?.isCollect ?? false
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ColorMenu: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Feedback.lightPrepare()
        switch items[indexPath.row] {
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
        if let colorModel = item as? ColorModel {
            let vc = NavigationController(rootViewController: ShareViewController(colorModel: colorModel))
            parentVC?.present(vc, animated: true, completion: nil)
        } else {
            // Simple share for traditional colors
            let text = "\(item.displayName) \(item.colorHexAttributedString(type: .home).string)"
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            parentVC?.present(activityVC, animated: true, completion: nil)
        }
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
