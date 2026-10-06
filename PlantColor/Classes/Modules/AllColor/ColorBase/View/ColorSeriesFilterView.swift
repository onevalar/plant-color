//
//  ColorSeriesFilterView.swift
//  PlantColor
//
//  Created by QY on 2022/4/27.
//

import UIKit

class ColorSeriesFilterView: View {
    static var height: CGFloat = 110

    var didClickColorSeries: ((ColorSeries) -> Void)?

    private var items: [ColorSeries] = [.red,
                                        .orange,
                                        .yellow,
                                        .green,
                                        .blue,
                                        .indigo,
                                        .purple,
                                        .brown,
                                        .gray]

    // MARK: - LazyLoad

    private lazy var collectionView: CollectionView = {

        let collectionView = CollectionView(frame: bounds,
                                            collectionViewLayout: ColorSeriesFilterFlowLayout())
        collectionView.register(R.nib.colorSeriesFilterCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    override func makeUI() {
        super.makeUI()

        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
        backgroundColor = .white
        addSubview(collectionView)
        collectionView.reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}

// MARK: - UICollectionViewDataSource

extension ColorSeriesFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorSeriesFilterCell.identifier,
                                                      for: indexPath,
                                                      cellType: ColorSeriesFilterCell.self)
        cell.item = items[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ColorSeriesFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didClickColorSeries?(items[indexPath.row])
    }
}
