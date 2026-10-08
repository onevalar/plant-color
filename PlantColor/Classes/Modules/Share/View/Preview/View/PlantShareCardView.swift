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

/// Preview and export share drawing coordinates, independent of the screen or an offscreen window.
final class PlantShareCardView: UIView {
    static let canvasSize = CGSize(width: 322, height: 426)
    let name: String
    let hex: String
    let introduction: String
    let pronunciation: String
    let artwork: UIImage?
    private let color: UIColor
    private let ink: UIColor
    var style: PlantShareStyle = .original { didSet { refresh() } }
    var showsValues = true { didSet { refresh() } }

    init(item: any ColorDisplayable) {
        name = item.displayName
        hex = item.colorHEX
        introduction = item.displayAbstract.string.trimmingCharacters(in: .whitespacesAndNewlines)
        pronunciation = ((item as? TraditionalColorModel)?.pinyin
            ?? item.displayName.applyingTransform(.toLatin, reverse: false)
            ?? item.displayName).uppercased()
        artwork = item.imageName.isEmpty ? nil : UIImage(named: item.imageName)
        color = item.color
        ink = item.textUIColor
        super.init(frame: .zero)
        backgroundColor = color
        isOpaque = true
        clipsToBounds = true
        layer.cornerRadius = 4
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
        context.saveGState()
        context.scaleBy(x: bounds.width / Self.canvasSize.width, y: bounds.height / Self.canvasSize.height)
        drawCard()
        context.restoreGState()
    }

    /// Fixed 966 × 1278 opaque image, identical across phone, iPad and window sizes.
    func exportImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = true
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: Self.canvasSize, format: format).image { _ in drawCard() }
    }

    private func drawCard() {
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: Self.canvasSize))
        if style != .pureColor {
            drawText(name, rect: CGRect(x: 25, y: 30, width: style == .introduction ? 194 : 272, height: 56),
                     font: .fzktjwgb10(size: 40), color: ink)
            drawText(pronunciation, rect: CGRect(x: 27, y: 99, width: style == .introduction ? 180 : 268, height: 20),
                     font: .systemFont(ofSize: 10, weight: .medium), color: ink.withAlphaComponent(0.78), tracking: 1)
            if style == .original {
                drawArtwork(in: CGRect(x: 124, y: 94, width: 300, height: 300))
            } else {
                drawArtwork(in: CGRect(x: 204, y: 14, width: 150, height: 150))
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 5
                paragraph.lineBreakMode = .byWordWrapping
                NSAttributedString(string: introduction, attributes: [
                    .font: UIFont.systemFont(ofSize: 14), .foregroundColor: ink, .paragraphStyle: paragraph
                ]).draw(with: CGRect(x: 27, y: 170, width: 268, height: 188),
                        options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine], context: nil)
            }
        }
        if showsValues {
            drawText(hex, rect: CGRect(x: 27, y: 382, width: 140, height: 20),
                     font: .monospacedSystemFont(ofSize: 12, weight: .regular), color: ink)
        }
        if style != .pureColor {
            drawText(NSLocalizedString("app_name", comment: ""), rect: CGRect(x: 177, y: 382, width: 118, height: 20),
                     font: .systemFont(ofSize: 11), color: ink.withAlphaComponent(0.78), alignment: .right)
        }
    }

    private func drawArtwork(in rect: CGRect) {
        guard let artwork, artwork.size.width > 0, artwork.size.height > 0 else { return }
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
