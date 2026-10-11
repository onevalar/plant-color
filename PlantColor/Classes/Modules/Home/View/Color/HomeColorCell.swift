import UIKit

/// 图案独立居中；名称由固定在安全区底部的 HomeActionBar 显示。
final class HomeColorCell: UICollectionViewCell {
    var onShowInfo: (() -> Void)?
    private let artView = UIImageView()
    private let artArea = UIView()
    var displayItem: (any ColorDisplayable)? {
        didSet {
            if let item = displayItem { apply(item.palette) }
            setNeedsLayout()
        }
    }
    func apply(_ palette: BotanicalPalette) { artView.tintColor = palette.artwork.uiColor }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let item = displayItem else { return }
        let fitted = BotanicalArtwork.fitted(name: item.imageName, in: artArea.bounds.size)
        artView.image = fitted.image
        artView.bounds = CGRect(origin: .zero, size: fitted.size)
        artView.center = CGPoint(x: artArea.bounds.midX, y: artArea.bounds.midY)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        artView.contentMode = .scaleAspectFit
        artView.isAccessibilityElement = false
        artArea.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(artArea)
        artArea.addSubview(artView)
        let guide = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            artArea.topAnchor.constraint(equalTo: guide.topAnchor, constant: 84),
            artArea.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -126),
            artArea.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            artArea.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
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

/// Choose the least changed complete composition which approaches 28% visual occupancy.
/// Fits the actual available space, including small phones and landscape, without cropping.
enum BotanicalArtwork {
    private struct Variant: Decodable {
        let name: String
        let width: Double
        let height: Double
        let footprint: Double
    }
    private static let layouts: [String: [Variant]] = {
        guard let data = NSDataAsset(name: "BotanicalArtLayouts")?.data,
              let result = try? JSONDecoder().decode([String: [Variant]].self, from: data) else { return [:] }
        return result
    }()
    static func fitted(name: String, in area: CGSize) -> (image: UIImage?, size: CGSize) {
        guard area.width > 0, area.height > 0 else { return (nil, .zero) }
        guard let variants = layouts[name], !variants.isEmpty else {
            guard let image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate) else { return (nil, .zero) }
            let scale = min(area.width / image.size.width, area.height / image.size.height)
            return (image, CGSize(width: image.size.width*scale, height: image.size.height*scale))
        }
        let areaSize = Double(area.width*area.height)
        let candidates = variants.map { variant -> (Variant, Double, Double) in
            let target = sqrt(0.28*areaSize/(variant.footprint*variant.width*variant.height))
            // No more than 1.5x source pixels on the current screen: don't trade sharpness for size.
            let scale = min(target, Double(area.width)/variant.width, Double(area.height)/variant.height,
                            1.5 / Double(UIScreen.main.scale))
            let occupancy = variant.footprint*variant.width*variant.height*scale*scale/areaSize
            return (variant, scale, occupancy)
        }
        let chosen = candidates.first { $0.2 >= 0.28*0.98 } ?? candidates.max { $0.2 < $1.2 }!
        return (UIImage(named: chosen.0.name)?.withRenderingMode(.alwaysTemplate),
                CGSize(width: chosen.0.width*chosen.1, height: chosen.0.height*chosen.1))
    }
}
