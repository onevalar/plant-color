//
//  ColorMenu.swift
//  PlantColor
//
//  Created by QY on 2022/4/25.
//

import UIKit

class ColorFilterMenu: UIView {

    public static var height: CGFloat = 40

    public var listDidClick: (() -> Void)?
    public var gridDidClick: (() -> Void)?
    public var colorSeriesDidClick: (() -> Void)?

    @IBOutlet private weak var listButton: UIButton!
    @IBOutlet private weak var gridButton: UIButton!
    @IBOutlet private weak var colorSeriesButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .main
        listButton.accessibilityLabel = NSLocalizedString("color_view_list", comment: "")
        gridButton.accessibilityLabel = NSLocalizedString("color_view_grid", comment: "")
        colorSeriesButton.setTitle(NSLocalizedString("color_filter_series", comment: ""), for: .normal)
    }

    @IBAction private func listButtonDidClick(sender: UIButton) {
        listDidClick?()
    }

    @IBAction private func gridButtonDidClick(sender: UIButton) {
        gridDidClick?()
    }

    @IBAction private func colorSeriesButtonDidClick() {
        colorSeriesDidClick?()
    }
    
    public var isGrid: Bool? {
        didSet {
            guard let isGrid = isGrid else { return }
            listButton.isSelected = !isGrid
            gridButton.isSelected = isGrid
        }
    }
}
