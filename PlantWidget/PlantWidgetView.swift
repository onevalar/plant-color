//
//  PlantWidgetView.swift
//  PlantWidgetExtension
//
//  小、中、大三种尺寸共用一份界面，按组件大小自适应排版。
//

import SwiftUI
import WidgetKit

struct PlantWidgetView: View {

    @Environment(\.widgetFamily) private var family

    var plant: PlantModel

    private var textColor: Color {
        Color(hex: plant.textColor)
    }

    var body: some View {
        content
            .foregroundColor(textColor)
            .widgetBackground(Color(hex: plant.colorHEX))
            .widgetURL(plant.deepLink)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            medium
        case .systemLarge:
            large
        default:
            small
        }
    }

    // MARK: - 小

    private var small: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                nameText(size: plant.name.count > 2 ? 24 : 32)
                Spacer(minLength: 0)
                figure(size: 34)
            }
            Spacer(minLength: 4)
            detail(fontSize: 11, lineLimit: 3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - 中

    private var medium: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                nameText(size: plant.name.count > 3 ? 30 : 40)
                figure(size: 44)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            detail(fontSize: 13, lineLimit: 5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 大

    private var large: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                nameText(size: plant.name.count > 3 ? 40 : 52)
                Spacer(minLength: 0)
                figure(size: 72)
            }
            Spacer(minLength: 0)
            detail(fontSize: 16, lineLimit: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - 零件

    private func nameText(size: CGFloat) -> some View {
        Text(plant.name)
            .font(.system(size: size, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }

    /// 配图：设置里打开"显示图案"，且这个颜色有图时才显示
    @ViewBuilder
    private func figure(size: CGFloat) -> some View {
        if plant.showFigure, !plant.imageName.isEmpty {
            Image(plant.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }

    /// 自定义文字优先，否则显示色值（可在设置里关闭）
    @ViewBuilder
    private func detail(fontSize: CGFloat, lineLimit: Int) -> some View {
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

    private func valueRow(_ title: String, _ value: String, fontSize: CGFloat) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: fontSize, weight: .medium))
                .opacity(0.6)
                .frame(width: fontSize * 3.4, alignment: .leading)
            Text(value)
                .font(.system(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

extension View {

    /// iOS 17 起小组件背景必须用 containerBackground；更早的系统用普通背景并自己留边距
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(color)
        }
    }
}
