import UIKit

enum PlantShareStyle: Int, CaseIterable {
    case original, pureColor, introduction

    var title: String {
        switch self {
        case .original: return NSLocalizedString("share_card_original", comment: "")
        case .pureColor: return NSLocalizedString("share_card_pure", comment: "")
        case .introduction: return NSLocalizedString("share_card_introduction", comment: "")
        }
    }
}

/// 海报比例（长边 ÷ 短边）
enum PlantShareRatio: Int, CaseIterable {
    case standard, square, wide, device

    var aspect: CGFloat {
        switch self {
        case .standard: return 426.0 / 322.0
        case .square: return 1
        case .wide: return 16.0 / 9.0
        case .device:
            let size = UIScreen.main.bounds.size
            return max(size.width, size.height) / max(min(size.width, size.height), 1)
        }
    }

    var title: String {
        switch self {
        case .standard: return NSLocalizedString("share_ratio_standard", comment: "")
        case .square: return NSLocalizedString("share_edit_square", comment: "")
        case .wide: return "16:9"
        case .device: return NSLocalizedString("share_edit_device_size", comment: "")
        }
    }
}

enum PlantShareOrientation: Int {
    case portrait, landscape
}

/// 预览和导出共用同一套绘制坐标，与屏幕大小、窗口大小无关。
/// 内部以"短边 = 322"为基准，所有位置按比例计算，所以任何比例和方向都能完整排版。
final class PlantShareCardView: UIView {
    /// 短边的基准长度（pt）；导出时 3 倍，即短边 966 像素
    static let baseShortSide: CGFloat = 322

    let name: String
    let hex: String
    let introduction: String
    let pronunciation: String
    let artwork: UIImage?
    private let color: UIColor
    private let ink: UIColor

    var style: PlantShareStyle = .original { didSet { refresh() } }
    var ratio: PlantShareRatio = .standard { didSet { refresh() } }
    var orientation: PlantShareOrientation = .portrait { didSet { refresh() } }
    var showsValues = true { didSet { refresh() } }

    /// 当前比例和方向对应的画布尺寸
    var canvasSize: CGSize {
        let long = (Self.baseShortSide * ratio.aspect).rounded()
        return orientation == .portrait
            ? CGSize(width: Self.baseShortSide, height: long)
            : CGSize(width: long, height: Self.baseShortSide)
    }

    init(item: any ColorDisplayable) {
        name = item.displayName
        hex = item.colorHEX
        introduction = item.displayAbstract.string.trimmingCharacters(in: .whitespacesAndNewlines)
        pronunciation = ((item as? TraditionalColorModel)?.pinyin
            ?? item.displayName.applyingTransform(.toLatin, reverse: false)
            ?? item.displayName).uppercased()
        artwork = item.imageName.isEmpty ? nil : UIImage(named: item.imageName)?.withTintColor(item.palette.artwork.uiColor, renderingMode: .alwaysOriginal)
        color = item.color
        ink = item.textUIColor
        super.init(frame: .zero)
        backgroundColor = color
        isOpaque = true
        clipsToBounds = true
        layer.cornerRadius = 4
        layer.cornerCurve = .continuous
        contentMode = .redraw
        isAccessibilityElement = true
        accessibilityTraits = .image
        refresh()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func refresh() {
        accessibilityLabel = "\(name), \(style.title)"
        accessibilityValue = [showsValues ? hex : nil,
                              style == .introduction ? introduction : nil].compactMap { $0 }.joined(separator: ", ")
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), bounds.width > 0, bounds.height > 0 else { return }
        let canvas = canvasSize
        context.saveGState()
        context.scaleBy(x: bounds.width / canvas.width, y: bounds.height / canvas.height)
        drawCard(canvas: canvas)
        context.restoreGState()
    }

    /// 不透明的 PNG 图：短边固定 966 像素，在手机、iPad、不同窗口下完全一致
    func exportImage() -> UIImage {
        let canvas = canvasSize
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = true
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in drawCard(canvas: canvas) }
    }

    // MARK: - 绘制

    private func drawCard(canvas: CGSize) {
        let w = canvas.width, h = canvas.height
        let s = min(w, h) / Self.baseShortSide          // 字号随画布缩放
        let landscape = w > h
        let margin = 0.078 * min(w, h)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: canvas))

        if style != .pureColor {
            let textWidth = style == .introduction ? (landscape ? w * 0.5 : w * 0.6) : w - margin * 2
            drawText(name, rect: CGRect(x: margin, y: margin * 1.2, width: textWidth, height: 58 * s),
                     font: .wenKai(size: 40 * s), color: ink)
            drawText(pronunciation, rect: CGRect(x: margin + 2 * s, y: margin * 1.2 + 68 * s, width: textWidth, height: 20 * s),
                     font: .systemFont(ofSize: 10 * s, weight: .medium), color: ink, tracking: 1)

            let footer = h - margin - 20 * s              // 底部信息行的顶部
            let titleBottom = margin * 1.2 + 96 * s       // 标题块的底部
            if style == .original {
                // 图案在标题与底部信息之间居中，等比缩放，保证完整显示
                let area: CGRect = landscape
                    ? CGRect(x: w * 0.36, y: margin, width: w * 0.6 - margin * 0.4, height: footer - margin - 8 * s)
                    : CGRect(x: margin, y: titleBottom + 8 * s, width: w - margin * 2, height: footer - titleBottom - 24 * s)
                drawArtwork(in: area)
            } else {
                let artSide = landscape ? min(h - margin * 2 - 36 * s, w * 0.36) : min(w * 0.46, 150 * s)
                let artRect = landscape
                    ? CGRect(x: w - margin - artSide, y: margin, width: artSide, height: artSide)
                    : CGRect(x: w - margin - artSide, y: margin * 0.6, width: artSide, height: artSide)
                drawArtwork(in: artRect)
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 5 * s
                paragraph.lineBreakMode = .byWordWrapping
                let textTop = landscape ? titleBottom + 8 * s : max(titleBottom + 8 * s, artRect.maxY + 12 * s)
                let textWidth = landscape ? w - margin * 2 - artSide - 20 * s : w - margin * 2
                NSAttributedString(string: introduction, attributes: [
                    .font: UIFont.systemFont(ofSize: 14 * s), .foregroundColor: ink, .paragraphStyle: paragraph
                ]).draw(with: CGRect(x: margin, y: textTop, width: textWidth, height: max(footer - textTop - 12 * s, 0)),
                        options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil)
            }
        }
        let footerY = h - margin - 20 * s
        if showsValues {
            drawText(hex, rect: CGRect(x: margin, y: footerY, width: w * 0.5, height: 20 * s),
                     font: .monospacedSystemFont(ofSize: 12 * s, weight: .regular), color: ink)
        }
        if style != .pureColor {
            drawText(NSLocalizedString("app_name", comment: ""),
                     rect: CGRect(x: w - margin - w * 0.4, y: footerY, width: w * 0.4, height: 20 * s),
                     font: .systemFont(ofSize: 11 * s), color: ink, alignment: .right)
        }
    }

    private func drawArtwork(in rect: CGRect) {
        guard let artwork, artwork.size.width > 0, artwork.size.height > 0, rect.width > 0, rect.height > 0 else { return }
        let scale = min(rect.width / artwork.size.width, rect.height / artwork.size.height)
        let size = CGSize(width: artwork.size.width * scale, height: artwork.size.height * scale)
        artwork.draw(in: CGRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2,
                               width: size.width, height: size.height))
    }

    private func drawText(_ text: String, rect: CGRect, font: UIFont, color: UIColor,
                          tracking: CGFloat = 0, alignment: NSTextAlignment = .left) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byTruncatingTail
        (text as NSString).draw(in: rect, withAttributes: [
            .font: font, .foregroundColor: color, .kern: tracking, .paragraphStyle: paragraph
        ])
    }
}
