//
//  ShareEditListContainerFlowLayout.swift
//  PlantColor
//
//  Created by QY on 2022/5/7.
//

import UIKit

class ShareEditListContainerFlowLayout: UICollectionViewFlowLayout {

    /// 间距
    private let kMargin: CGFloat = floor(.leftAndRightMargin * 0.2)
    /// 每行最大列数
    private let kMaxCol: CGFloat = 4
    /// cell 宽度
    private var kItemW: CGFloat {
        floor(((collectionView?.width ?? 0) - (kMaxCol - 1) * kMargin - CGFloat.leftAndRightMargin * 2) / kMaxCol)
    }
    private var kItemH: CGFloat {
        kItemW * 1.17
    }

    override func prepare() {
        super.prepare()

        sectionInset = UIEdgeInsets(top: 0,
                                    left: .leftAndRightMargin,
                                    bottom: 0,
                                    right: .leftAndRightMargin)
        scrollDirection = .horizontal
        itemSize = CGSize(width: kItemW, height: kItemH)
        minimumLineSpacing = kMargin
        minimumInteritemSpacing = kMargin
    }
}
