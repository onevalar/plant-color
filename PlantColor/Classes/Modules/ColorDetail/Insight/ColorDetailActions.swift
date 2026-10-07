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

        let heart = UIBarButtonItem()

        func heartAction() -> UIAction {
            let name = item.isCollect ? "heart.fill" : "heart"
            return UIAction(image: UIImage(systemName: name)) { [weak heart] _ in
                Feedback.lightPrepare()
                item.toggleCollect()
                heart?.primaryAction = heartAction()
                heart?.tintColor = item.isCollect ? .systemRed : nil
            }
        }
        heart.primaryAction = heartAction()
        heart.tintColor = item.isCollect ? .systemRed : nil

        let share = UIBarButtonItem(primaryAction: UIAction(image: UIImage(systemName: "square.and.arrow.up")) { [weak viewController] _ in
            viewController?.navigationController?.pushViewController(ShareViewController(item: item),
                                                                     animated: true)
        })
        return [share, heart]
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
        hint.textColor = .lightGray

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
