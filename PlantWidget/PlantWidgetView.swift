//
//  PlantWidgetView.swift
//  PlantWidgetExtension
//
//  小、中、大三种尺寸共用一份界面，按组件大小自适应排版。
//

import SwiftUI
import WidgetKit

struct PlantWidgetView: SwiftUI.View {

    enum PreviewMode { case original, tinted }

    @Environment(\.widgetFamily) private var family

    var plant: PlantModel
    /// The app previews the same content without using WidgetKit's container outside an extension.
    var previewMode: PreviewMode? = nil
    var imageBundle: Bundle = .main

    private var palette: BotanicalPalette {
        .make(background: RGBColor(hex: plant.colorHEX) ?? RGBColor(r: 255, g: 255, b: 255))
    }

    private var textColor: Color {
        previewMode == .tinted ? Color(UIColor.settingsPreviewAccent) : Color(hex: palette.summary.hexString)
    }

    @ViewBuilder var body: some SwiftUI.View {
        if let previewMode {
            medium
                .foregroundColor(textColor)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(previewMode == .tinted ? Color(UIColor.secondarySystemBackground) : Color(hex: plant.colorHEX))
        } else {
            content
                .foregroundColor(textColor)
                .widgetBackground(Color(hex: plant.colorHEX))
                .widgetURL(plant.deepLink)
        }
    }

    @ViewBuilder
    private var content: some SwiftUI.View {
        switch family {
        case .systemMedium:
            medium
        case .systemLarge:
            large
        default:
            small
        }
    }

    // 三种尺寸统一版式：图案居中完整显示 → 色名 → 色值，与 App 首页保持一致

    // MARK: - 小

    private var small: some SwiftUI.View {
        VStack(spacing: 6) {
            if hasFigure {
                figure.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer(minLength: 0)
            }
            nameText(size: plant.name.count > 2 ? 26 : 34)
            compactDetail(fontSize: 12)
            if !hasFigure { Spacer(minLength: 0) }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 中

    private var medium: some SwiftUI.View {
        HStack(alignment: .center, spacing: 16) {
            VStack(spacing: 6) {
                if hasFigure {
                    figure.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Spacer(minLength: 0)
                }
                nameText(size: plant.name.count > 3 ? 30 : 40)
                if !hasFigure { Spacer(minLength: 0) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            detail(fontSize: 13, lineLimit: 5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 大

    private var large: some SwiftUI.View {
        VStack(spacing: 14) {
            if hasFigure {
                figure.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer(minLength: 0)
            }
            nameText(size: plant.name.count > 3 ? 44 : 56)
            detail(fontSize: 16, lineLimit: 8)
            if !hasFigure { Spacer(minLength: 0) }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 零件

    private func nameText(size: CGFloat) -> some SwiftUI.View {
        Text(plant.name)
            .font(.system(size: size, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }

    private var hasFigure: Bool { plant.showFigure && !plant.imageName.isEmpty }

    /// 配图：设置里打开"显示图案"，且这个颜色有图时才显示；等比缩放、居中、完整显示
    private var figure: some SwiftUI.View {
        Image(plant.imageName, bundle: imageBundle)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(previewMode == .tinted ? textColor : Color(hex: palette.artwork.hexString))
    }

    /// 小尺寸只放一行：自定义文字，或 HEX
    @ViewBuilder
    private func compactDetail(fontSize: CGFloat) -> some SwiftUI.View {
        if !plant.customContent.isEmpty {
            Text(plant.customContent)
                .font(.system(size: fontSize + 1))
                .lineLimit(2)
        } else if plant.showTone {
            Text(plant.colorHEX)
                .font(.system(size: fontSize, weight: .medium))
        }
    }

    /// 自定义文字优先，否则显示色值（可在设置里关闭）
    @ViewBuilder
    private func detail(fontSize: CGFloat, lineLimit: Int) -> some SwiftUI.View {
        if !plant.customContent.isEmpty {
            Text(plant.customContent)
                .font(.system(size: fontSize + 2))
                .lineLimit(lineLimit)
                .fixedSize(horizontal: false, vertical: true)
        } else if plant.showTone {
            VStack(alignment: .leading, spacing: fontSize * 0.3) {
                valueRow("HEX", plant.colorHEX, fontSize: fontSize)
                valueRow("RGB", plant.displayRGB, fontSize: fontSize)
                valueRow("CMYK", plant.displayCMYK, fontSize: fontSize)
            }
        }
    }

    private func valueRow(_ title: String, _ value: String, fontSize: CGFloat) -> some SwiftUI.View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: fontSize, weight: .medium))
                .frame(width: fontSize * 3.4, alignment: .leading)
            Text(value)
                .font(.system(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

private extension UIColor {
    static var settingsPreviewAccent: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 160 / 255, green: 185 / 255, blue: 167 / 255, alpha: 1)
                : UIColor(red: 61 / 255, green: 86 / 255, blue: 72 / 255, alpha: 1)
        }
    }
}

extension SwiftUI.View {

    /// iOS 17 起小组件背景必须用 containerBackground；更早的系统用普通背景并自己留边距
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some SwiftUI.View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(color)
        }
    }
}
