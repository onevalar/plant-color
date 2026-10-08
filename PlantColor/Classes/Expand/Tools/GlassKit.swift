//
//  GlassKit.swift
//  PlantColor
//
//  Liquid Glass 风格的统一规范：间距、圆角、尺寸，以及悬浮在内容之上的玻璃按钮。
//  所有新页面都从这里取尺寸，避免每个页面各定各的。
//

import UIKit

/// 设计规范（单位：pt）
enum DS {

    /// 页面左右边距
    static let margin: CGFloat = 20
    /// 相邻元素的常用间距
    static let spacing: CGFloat = 12
    /// 玻璃卡片圆角
    static let cardRadius: CGFloat = 24
    /// 浮动工具条的高度（圆角取一半，即胶囊形）
    static let barHeight: CGFloat = 60
    /// 工具条离屏幕底部（安全区之上）的距离
    static let barBottomGap: CGFloat = 14
    /// 最小可点区域
    static let minTap: CGFloat = 44
}

/// 悬浮玻璃上的图标按钮：固定可点区域，图标用 SF Symbol，按压时有缩放反馈。
final class GlassIconButton: UIButton {

    var symbolName: String = "" {
        didSet { applyImage() }
    }

    /// 选中状态用的图标（如收藏后的实心爱心）
    var selectedSymbolName: String? {
        didSet { applyImage() }
    }

    var iconColor: UIColor = .label {
        didSet { applyImage() }
    }

    /// 选中时的图标颜色，nil 表示和普通状态一样
    var selectedIconColor: UIColor? {
        didSet { applyImage() }
    }

    override var isSelected: Bool {
        didSet { applyImage() }
    }

    override var isHighlighted: Bool {
        didSet {
            guard !UIAccessibility.isReduceMotionEnabled else { return }
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.88, y: 0.88) : .identity
            }
        }
    }

    init(symbol: String, selectedSymbol: String? = nil, accessibilityLabel: String) {
        super.init(frame: .zero)
        symbolName = symbol
        selectedSymbolName = selectedSymbol
        self.accessibilityLabel = accessibilityLabel
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(greaterThanOrEqualToConstant: DS.minTap).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: DS.minTap).isActive = true
        applyImage()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyImage() {
        let name = (isSelected ? selectedSymbolName : nil) ?? symbolName
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let color = (isSelected ? selectedIconColor : nil) ?? iconColor
        setImage(UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal), for: .normal)
    }
}
