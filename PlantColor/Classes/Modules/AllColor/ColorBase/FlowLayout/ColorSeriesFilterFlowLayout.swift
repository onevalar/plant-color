//
//  ColorSeriesFlowLayout.swift
//  PlantColor
//
//  Created by QY on 2022/4/27.
//

import UIKit

class ColorSeriesFilterFlowLayout: UICollectionViewFlowLayout {

    /// 间距
    private let kMargin: CGFloat = 30
    /// 每行最大列数
    private let kMaxCol: CGFloat = 3
    /// cell 宽度
    private var kItemW: CGFloat {
        floor(((collectionView?.width ?? 0) - (kMaxCol - 1) * kMargin - CGFloat.leftAndRightMargin * 2) / kMaxCol)
    }
    private var kItemH: CGFloat = 20

    override func prepare() {
        super.prepare()

        sectionInset = UIEdgeInsets(top: 0,
                                    left: .leftAndRightMargin,
                                    bottom: 0,
                                    right: .leftAndRightMargin)
        scrollDirection = .vertical
        itemSize = CGSize(width: kItemW, height: kItemH)
        minimumLineSpacing = kMargin * 0.5
        minimumInteritemSpacing = kMargin
    }
}
