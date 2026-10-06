//
//  ColorGridFlowLayout.swift
//  PlantColor
//
//  Created by QY on 2022/4/25.
//

import UIKit

class ColorGridFlowLayout: UICollectionViewFlowLayout {

    /// 间距
    private let kMargin: CGFloat = floor(.leftAndRightMargin * 0.5)
    /// 每行最大列数
    private let kMaxCol: CGFloat = 3
    /// cell 宽度
    private var kItemW: CGFloat {
        floor(((collectionView?.width ?? 0) - (kMaxCol - 1) * kMargin - CGFloat.leftAndRightMargin * 2) / kMaxCol)
    }
    private var kItemH: CGFloat {
        kItemW
    }

    override func prepare() {
        super.prepare()

        sectionInset = UIEdgeInsets(top: 0,
                                    left: .leftAndRightMargin,
                                    bottom: 0,
                                    right: .leftAndRightMargin)
        scrollDirection = .vertical
        itemSize = CGSize(width: kItemW, height: kItemH)
        minimumLineSpacing = kMargin
        minimumInteritemSpacing = kMargin
    }
}

