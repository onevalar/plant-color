//
//  ShareEditListContainerView.swift
//  PlantColor
//
//  Created by QY on 2022/5/7.
//

import UIKit
import JXCategoryView

class ShareEditListContainerView: View {

    let item: ShareEditModel

    let colorModel: ColorModel

    var didSelectItemAt: ((Int) -> Void)?

    init(frame: CGRect,
         item: ShareEditModel,
         colorModel: ColorModel) {
        self.item = item
        self.colorModel = colorModel
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LazyLoad
    private lazy var collectionView: CollectionView = {

        let collectionView = CollectionView(frame: bounds,
                                            collectionViewLayout: ShareEditListContainerFlowLayout())
        collectionView.register(R.nib.shareEditListContainerCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }

    override func makeUI() {
        super.makeUI()
        addSubview(collectionView)
        collectionView.scrollToItem(at: IndexPath(row: item.selectedIndex,
                                                  section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ShareEditListContainerView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shareEditListContainerCell.identifier,
                                                      for: indexPath,
                                                      cellType: ShareEditListContainerCell.self)
        cell.colorModel = colorModel
        cell.isOnSelected = item.selectedIndex == indexPath.row
        cell.item = item.items[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ShareEditListContainerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == item.selectedIndex {
            return
        }
        didSelectItemAt?(indexPath.row)
    }
}

// MARK: - JXCategoryListContentViewDelegate
extension ShareEditListContainerView: JXCategoryListContentViewDelegate {
    func listView() -> UIView! {
        self
    }
}
