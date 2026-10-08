//
//  HomeVerticalCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit
import UIColor_Hex_Swift

class HomeVerticalCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(accessibilityMotionChanged),
                                               name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
        updateMotionPreference()
    }

    func updateMotionPreference(reduceMotion: Bool = UIAccessibility.isReduceMotionEnabled) {
        collectionView.bounces = !reduceMotion
    }

    @objc private func accessibilityMotionChanged() { updateMotionPreference() }

    deinit { NotificationCenter.default.removeObserver(self) }
    
    var didEndScroll: ((Int) -> Void)?
    
    var index: Int = 0 {
        didSet {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                        at: .right,
                                        animated: false)
        }
    }
    
    var displayItem: (any ColorDisplayable)? {
        didSet {
            collectionView.reloadData()
            collectionView.backgroundColor = displayItem?.color
        }
    }

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(R.nib.colorHueCell)
            collectionView.register(R.nib.colorIntroCell)
        }
    }
    
    @IBOutlet private weak var flowLayout: UICollectionViewFlowLayout! {
        didSet {
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeVerticalCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorHueCell.identifier,
                                                          for: indexPath,
                                                          cellType: ColorHueCell.self)
            cell.item = displayItem
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorIntroCell.identifier,
                                                          for: indexPath,
                                                          cellType: ColorIntroCell.self)
            cell.item = displayItem
            return cell
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeVerticalCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        bounds.size
    }
}

// MARK: - UIScrollViewDelegate
extension HomeVerticalCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        callBackIndex()
    }
    
    func callBackIndex() {
        didEndScroll?(Int(collectionView.contentOffset.x / width))
    }
}
