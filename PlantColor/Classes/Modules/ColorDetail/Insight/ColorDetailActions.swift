//
//  ColorDetailActions.swift
//  PlantColor
//
//  详情页右上角的"收藏"和"分享"按钮。
//

import UIKit

enum ColorDetailActions {

    static func barItems(for item: any ColorDisplayable,
                         from viewController: UIViewController) -> [UIBarButtonItem] {

        let heart = UIButton(type: .system)
        heart.frame.size = CGSize(width: 44, height: 44)
        func updateHeart(_ button: UIButton) {
            let name = item.isCollect ? "heart.fill" : "heart"
            button.setImage(UIImage(systemName: name), for: .normal)
            button.accessibilityLabel = NSLocalizedString(item.isCollect ? "color_remove_favorite" : "color_add_favorite", comment: "")
            button.tintColor = item.isCollect ? .systemRed : nil
        }
        heart.addAction(UIAction { [weak heart] _ in
            guard let heart else { return }
            Feedback.lightPrepare()
            item.toggleCollect()
            updateHeart(heart)
        }, for: .touchUpInside)
        updateHeart(heart)

        let share = UIButton(type: .system)
        share.frame.size = CGSize(width: 44, height: 44)
        share.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        share.accessibilityLabel = NSLocalizedString("common_share", comment: "")
        share.addAction(UIAction { [weak viewController] _ in
            viewController?.navigationController?.pushViewController(ShareViewController(item: item),
                                                                     animated: true)
        }, for: .touchUpInside)
        return [UIBarButtonItem(customView: share), UIBarButtonItem(customView: heart)]
    }
}

/// 详情页底部：色值卡片（点击复制）+ 配色推荐
final class ColorInsightFooterView: UIView {

    /// 点了配色推荐里的某个颜色
    var didSelectItem: ((any ColorDisplayable) -> Void)?

    static let horizontalMargin: CGFloat = 15

    /// horizontalMargin：左右留白。放进已经有边距的容器时传 0
    init(item: any ColorDisplayable, horizontalMargin: CGFloat = ColorInsightFooterView.horizontalMargin) {
        super.init(frame: .zero)

        let values = ColorValueView(item: item)
        let harmony = ColorHarmonyView(item: item)
        harmony.didSelect = { [weak self] swatch in
            guard let resolved = ColorCatalog.shared.resolve(swatch) else { return }
            self?.didSelectItem?(resolved)
        }

        let hint = UILabel()
        hint.text = NSLocalizedString("detail_tap_to_copy", comment: "")
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = .tertiaryLabel

        let stack = UIStackView(arrangedSubviews: [values, hint, harmony])
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(26, after: hint)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalMargin),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalMargin),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 按指定宽度计算需要的高度（用于 tableFooterView）
    func height(fitting width: CGFloat) -> CGFloat {
        systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                                withHorizontalFittingPriority: .required,
                                verticalFittingPriority: .fittingSizeLevel).height
    }
}
