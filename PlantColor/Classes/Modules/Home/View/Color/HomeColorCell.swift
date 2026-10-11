import UIKit

/// 图案独立居中；名称由固定在安全区底部的 HomeActionBar 显示。
final class HomeColorCell: UICollectionViewCell {
    var onShowInfo: (() -> Void)?
    private let artView = UIImageView()
    var displayItem: (any ColorDisplayable)? {
        didSet {
            artView.image = displayItem.flatMap { UIImage(named: $0.imageName) }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        artView.contentMode = .scaleAspectFit
        artView.isAccessibilityElement = false
        artView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(artView)
        let guide = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            artView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 84),
            artView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -126),
            artView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            artView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
        ])
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInfo)))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTransition(progress: CGFloat) {
        let distance = min(abs(progress), 1)
        artView.alpha = max(0, 1 - distance * 1.7)
        let scale = 1 - 0.06 * distance
        artView.transform = UIAccessibility.isReduceMotionEnabled ? .identity : CGAffineTransform(scaleX: scale, y: scale)
    }

    @objc private func showInfo() { Feedback.lightPrepare(); onShowInfo?() }

    override func prepareForReuse() {
        super.prepareForReuse()
        onShowInfo = nil
        artView.image = nil
        setTransition(progress: 0)
    }
}
