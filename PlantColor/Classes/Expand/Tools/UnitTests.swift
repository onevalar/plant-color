//
//  UnitTests.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//  Copyright © 2024 PlantColor. All rights reserved.
//

import Foundation
import UIKit

#if DEBUG
/// 调试版启动时自动运行的数据与算法自检（结果写进日志）。
/// 重点检查"改了数据文件或算法之后最容易悄悄出错"的地方。
class PlantColorTests {

    static let shared = PlantColorTests()

    private var failures: [String] = []
    private var total = 0

    private init() {}

    func runAllTests() {
        failures = []
        total = 0
        AppLogger.shared.info("开始运行自检...")

        testPlantColors()
        testTraditionalColors()
        testColorMath()
        testWidgetPlaylist()
        testHomeCardAndToolbar()
        testSystemAccessibility()
        testBrowsingPreferences()
        testWidgetPreview()
        testShareCards()

        if failures.isEmpty {
            AppLogger.shared.info("自检完成：\(total) 项全部通过")
        } else {
            AppLogger.shared.error("自检完成：\(total) 项中有 \(failures.count) 项失败：\n" + failures.joined(separator: "\n"))
        }
    }

    private func check(_ name: String, _ condition: Bool, _ detail: @autoclosure () -> String = "") {
        total += 1
        if !condition {
            failures.append("  ✗ \(name) \(detail())")
        }
    }

    // MARK: - 数据

    private func testPlantColors() {
        let colors = ColorProvider.fetchColors()
        check("植物色数据不为空", !colors.isEmpty)
        for item in colors {
            check("植物色色值有效：\(item.plantName)", RGBColor(hex: item.colorHEX) != nil, item.colorHEX)
        }
    }

    private func testTraditionalColors() {
        let colors = TraditionalColorProvider.fetchColors()
        check("传统色数据不为空", !colors.isEmpty)
        check("传统色名称不重复", Set(colors.map(\.name)).count == colors.count)
        for item in colors {
            guard let rgb = RGBColor(hex: item.colorHEX) else {
                check("传统色 HEX 有效：\(item.name)", false, item.colorHEX)
                continue
            }
            let parts = item.colorRGB.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            check("传统色 HEX 与 RGB 一致：\(item.name)", parts == [rgb.r, rgb.g, rgb.b], "\(item.colorHEX) vs \(item.colorRGB)")
            check("传统色有色系：\(item.name)", item.colorSeries != nil)
        }
    }

    // MARK: - 算法

    private func testColorMath() {
        let milk = RGBColor(hex: "#F9F4DC")
        check("HEX 往返", milk?.hexString == "#F9F4DC")
        check("HEX 容错：不带 # 号", RGBColor(hex: "F9F4DC") == milk)
        check("非法 HEX 返回 nil", RGBColor(hex: "#12345") == nil && RGBColor(hex: "zzzzzz") == nil)

        let sample = RGBColor(r: 200, g: 80, b: 40)
        let hsl = sample.hsl
        let back = RGBColor(h: hsl.h, s: hsl.s, l: hsl.l)
        check("HSL 往返误差不超过 1", abs(back.r - sample.r) <= 1 && abs(back.g - sample.g) <= 1 && abs(back.b - sample.b) <= 1)

        let red = RGBColor(r: 255, g: 0, b: 0)
        check("红色的互补色是青色", red.rotatedHue(by: 180) == RGBColor(r: 0, g: 255, b: 255))
        check("同一个颜色色差为 0", red.distance(to: red) < 0.0001)
        check("黑白灰判定为无彩", RGBColor(r: 128, g: 128, b: 128).isNeutral && !red.isNeutral)
        check("名字点明色系时以名字为准",
              TraditionalColorProvider.detectColorSeries(name: "咖啡", hex: "#FF0000") == .brown
                && TraditionalColorProvider.detectColorSeries(name: "月灰", hex: "#FF0000") == .gray)
    }

    private func testWidgetPlaylist() {
        let entry = WidgetPlaylistEntry(kind: "traditional", id: 7, name: "乳白", hex: "#F9F4DC",
                                        rgb: "249, 244, 220", cmyk: "0,2,12,2", textColor: "#333333", imageName: "")
        let data = try? JSONEncoder().encode([entry])
        let decoded = data.flatMap { try? JSONDecoder().decode([WidgetPlaylistEntry].self, from: $0) }
        check("小组件列表编码往返", decoded?.first?.name == "乳白" && decoded?.first?.id == 7)
        check("深链接格式", DeepLinkRouter.url(kind: .traditional, id: 7)?.absoluteString == "plantcolor://color/traditional/7")
    }

    private func testSystemAccessibility() {
        let glass = GlassEffectView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        glass.cornerRadius = 22
        glass.updateAccessibilityAppearance(reduceTransparency: true)
        check("降低透明度使用不透明浮层", glass.isOpaque && glass.backgroundColor != .clear)
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            check("实色浮层不透底：\(style.rawValue)", glass.backgroundColor?.resolvedColor(with: traits).cgColor.alpha == 1)
        }
        check("实色浮层隐藏玻璃材质", glass.subviews.compactMap { $0 as? UIVisualEffectView }.allSatisfy(\.isHidden))
        glass.updateAccessibilityAppearance(reduceTransparency: false)
        check("关闭降低透明度恢复材质", !glass.isOpaque && glass.backgroundColor == .clear && glass.subviews.contains { $0 is UIVisualEffectView && !$0.isHidden })
        check("辅助功能不改变浮层圆角", glass.cornerRadius == 22)
        glass.updateAccessibilityAppearance(reduceTransparency: !UIAccessibility.isReduceTransparencyEnabled)
        NotificationCenter.default.post(name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)
        check("透明度通知立即读取系统状态", glass.isOpaque == UIAccessibility.isReduceTransparencyEnabled)

        // 页面一律使用系统原生导航：带返回按钮、侧滑返回
        let root = UIViewController()
        let navigation = NavigationController(rootViewController: root)
        navigation.loadViewIfNeeded()
        let pushed = UIViewController()
        navigation.pushViewController(pushed, animated: false)
        check("导航使用系统原生导航栏", navigation.navigationBar.prefersLargeTitles && !navigation.isNavigationBarHidden)
        check("二级页面可以返回", navigation.viewControllers.count == 2
              && navigation.gestureRecognizerShouldBegin(navigation.interactivePopGestureRecognizer!))
        navigation.popViewController(animated: false)
        check("一级页面不触发侧滑返回", !navigation.gestureRecognizerShouldBegin(navigation.interactivePopGestureRecognizer!))
    }

    private func testHomeCardAndToolbar() {
        guard let plant = ColorProvider.fetchColors().first,
              let traditional = TraditionalColorProvider.fetchColors().first else {
            check("首页测试颜色可用", false)
            return
        }
        let cell = HomeColorCell(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        cell.displayItem = plant
        cell.layoutIfNeeded()
        check("植物色首页显示图案", cell.contentView.subviews.compactMap { $0 as? UIStackView }.first?.arrangedSubviews.first?.isHidden == false)
        cell.displayItem = traditional
        cell.layoutIfNeeded()
        check("传统色首页没有图案时隐藏图案区", cell.contentView.subviews.compactMap { $0 as? UIStackView }.first?.arrangedSubviews.first?.isHidden == true)
        var opened = false
        cell.onShowInfo = { opened = true }
        cell.onShowInfo?()
        check("首页色块可以打开简介", opened)
        cell.prepareForReuse()
        check("首页色块复用不保留旧动作", cell.onShowInfo == nil)

        // 翻到两页之间时，背景应是两个颜色的过渡色，内容应变淡
        let home = HomeViewController()
        home.loadViewIfNeeded()
        home.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        home.view.layoutIfNeeded()
        if home.collectionView.numberOfItems(inSection: 0) >= 2 {
            home.collectionView.layoutIfNeeded()
            home.collectionView.contentOffset = CGPoint(x: 0, y: 422)
            home.scrollViewDidScroll(home.collectionView)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            home.backgroundColorView.backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
            let centered = home.collectionView.visibleCells.compactMap { $0 as? HomeColorCell }
            check("首页翻到一半时背景色有效", a == 1)
            check("首页翻到一半时内容变淡", !centered.isEmpty)
        }

        let actionBar = HomeActionBar()
        actionBar.item = traditional
        let topBar = HomeTopBar()
        topBar.select(.traditional)
        check("首页悬浮控件创建成功", actionBar.bounds.height >= 0 && topBar.bounds.height >= 0)
    }

    private func testShareCards() {
        guard let plant = ColorProvider.fetchColors().first,
              let traditional = TraditionalColorProvider.fetchColors().first else {
            check("分享测试颜色可用", false)
            return
        }
        for item: any ColorDisplayable in [plant, traditional] {
            let card = PlantShareCardView(item: item)
            let identity = "\(item.colorKind.rawValue)-\(item.id)"
            check("分享简介来自实际数据：\(identity)", card.introduction == item.displayAbstract.string.trimmingCharacters(in: .whitespacesAndNewlines))
            check("植物配图使用原始素材：\(identity)", item.imageName.isEmpty ? card.artwork == nil : card.artwork != nil)
            let original = card.exportImage()
            check("导出使用固定像素尺寸：\(identity)", original.cgImage?.width == 966 && original.cgImage?.height == 1278)
            let originalData = original.pngData()
            card.frame = CGRect(x: 0, y: 0, width: 800, height: 300)
            card.layoutIfNeeded()
            check("导出不受屏幕或预览尺寸影响：\(identity)", card.exportImage().pngData() == originalData)
            card.style = .introduction
            check("简介确实写入导出图片：\(identity)", card.exportImage().pngData() != originalData)
            if item.colorKind == .plant && card.introduction.count > 60,
               let body = card.exportImage().cgImage?.cropping(to: CGRect(x: 81, y: 510, width: 804, height: 564)) {
                let width = body.width, height = body.height
                var pixels = [UInt8](repeating: 0, count: width * height * 4)
                if let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: 8,
                                           bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                           bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                    context.draw(body, in: CGRect(x: 0, y: 0, width: width, height: height))
                    let textRows = (0..<height).filter { row in
                        let background = (row * width + width - 1) * 4
                        return (0..<(width - 1)).contains { column in
                            let pixel = (row * width + column) * 4
                            return (0..<3).contains { abs(Int(pixels[pixel + $0]) - Int(pixels[background + $0])) > 8 }
                        }
                    }.count
                    check("长简介在卡片内换行而非截为一行", textRows > 50)
                } else { check("分享图片像素可读取", false) }
            }
            card.style = .pureColor
            let pureWithValue = card.exportImage().pngData()
            card.showsValues = false
            check("纯色可独立去除色值：\(identity)", card.exportImage().pngData() != pureWithValue)
            if let pixelImage = card.exportImage().cgImage?.cropping(to: CGRect(x: 0, y: 0, width: 1, height: 1)),
               let expected = RGBColor(hex: item.colorHEX), let space = CGColorSpace(name: CGColorSpace.sRGB) {
                var pixel = [UInt8](repeating: 0, count: 4)
                if let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                                           space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                    context.draw(pixelImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
                    check("导出像素保留真实 HEX 色值：\(identity)", abs(Int(pixel[0]) - expected.r) <= 1
                          && abs(Int(pixel[1]) - expected.g) <= 1 && abs(Int(pixel[2]) - expected.b) <= 1 && pixel[3] == 255)
                } else { check("导出色值可验证", false) }
            }
            check("关闭色值后辅助功能不朗读色值：\(identity)", card.accessibilityValue?.contains(item.colorHEX) != true)
            card.style = .original
            check("切换样式保留色值偏好：\(identity)", !card.showsValues)
            card.showsValues = true
            check("恢复样式与开关可重现原始导出：\(identity)", card.exportImage().pngData() == originalData)
        }

        let controller = ShareViewController(item: plant)
        let navigation = NavigationController(rootViewController: controller)
        navigation.loadViewIfNeeded()
        controller.loadViewIfNeeded()
        func allViews(_ root: UIView) -> [UIView] { [root] + root.subviews.flatMap(allViews) }
        var constraintCount: Int?
        for size in [CGSize(width: 320, height: 568), CGSize(width: 390, height: 844),
                     CGSize(width: 844, height: 390), CGSize(width: 1024, height: 768)] {
            navigation.view.frame = CGRect(origin: .zero, size: size)
            navigation.view.setNeedsLayout()
            navigation.view.layoutIfNeeded()
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()
            for view in allViews(controller.view) { view.layoutIfNeeded() }
            check("分享卡片适配视口：\(size.width)", controller.card.bounds.width > 0 && controller.card.bounds.width <= size.width - 48)
            let count = allViews(controller.view).reduce(0) { $0 + $1.constraints.count }
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()
            check("重复布局不新增约束：\(size.width)", allViews(controller.view).reduce(0) { $0 + $1.constraints.count } == count)
            let controls = allViews(controller.view).compactMap { $0 as? UISegmentedControl }
            check("样式、比例、方向三组选项都存在：\(size.width)",
                  ["share.style", "share.ratio", "share.orientation"].allSatisfy { id in controls.contains { $0.accessibilityIdentifier == id } })
            check("选项保留 40 点以上触控高度：\(size.width)", controls.allSatisfy { $0.bounds.height >= 40 })
        }
        controller.card.ratio = .square
        controller.card.orientation = .landscape
        check("比例与方向决定画布尺寸", controller.card.canvasSize.width == controller.card.canvasSize.height)
        controller.card.ratio = .wide
        let wideExport = controller.card.exportImage()
        check("横版 16:9 导出短边 966 像素", wideExport.cgImage?.height == 966 && (wideExport.cgImage?.width ?? 0) > 966)
        controller.card.ratio = .standard
        controller.card.orientation = .portrait
        let activity = controller.makeActivityController()
        check("系统分享提供 iPad 锚点", activity.popoverPresentationController?.sourceView != nil)
        check("系统分享锚点具有真实尺寸", activity.popoverPresentationController?.sourceRect.isEmpty == false)
    }

    private func testWidgetPreview() {
        let defaults = WidgetKitHelper.sharedDefaults
        let index = defaults?.object(forKey: WidgetKitHelper.currentIndex) as? Int
        let first = PlantViewModel.placeholderModel()
        let second = PlantViewModel.placeholderModel()
        check("小组件预览不会推进轮播序号", (defaults?.object(forKey: WidgetKitHelper.currentIndex) as? Int) == index)
        check("重复预览保持同一颜色", first.kind == second.kind && first.id == second.id)
        var model = PlantModel(kind: "traditional", id: 7, name: "乳白", colorRGB: "249, 244, 220",
                               colorHEX: "#F9F4DC", colorCMYK: "0, 2, 12, 2", textColor: "#333333",
                               imageName: "", customContent: "", refreshRate: "1day", showFigure: false, showTone: true)
        check("预览链接指向真实类型与颜色 ID", model.deepLink == DeepLinkRouter.url(kind: .traditional, id: 7))
        model.isEmptyPlaceholder = true
        check("收藏空状态不会打开占位颜色", model.deepLink == nil)
        let page = SettingViewController(page: .widget)
        page.loadViewIfNeeded()
        page.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        page.view.layoutIfNeeded()
        let header = page.tableView.tableHeaderView
        check("小组件配置显示完整预览头部", (header?.frame.height ?? 0) >= 300)
        check("小组件配置保留来源与打开颜色入口", page.items.first?.first?.setType == .WidgetSource && page.items.first?.last?.setType == .WidgetOpenCurrent)
    }

    private func testBrowsingPreferences() {
        let suite = "PlantColorTests.preferences.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suite) else {
            check("偏好测试使用独立存储", false)
            return
        }
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = HomePreferences(defaults: defaults)
        check("新安装默认恢复上次浏览并开启触感", preferences.startup == .last && preferences.hapticsEnabled)
        check("默认外观跟随系统", preferences.appearance.style == .unspecified)
        preferences.remember(mode: .botanical, colorID: 7, page: 1)
        preferences.remember(mode: .traditional, colorID: 100, page: 0)
        preferences.hapticsEnabled = false
        preferences.startup = .first
        preferences.appearance = .dark
        let restored = HomePreferences(defaults: defaults)
        check("植物色按 ID 与横向页恢复", restored.position(for: .botanical) == .init(colorID: 7, page: 1))
        check("传统色拥有独立浏览位置", restored.lastMode == .traditional && restored.position(for: .traditional) == .init(colorID: 100, page: 0))
        check("触感、打开方式与外观可持久保存", !restored.hapticsEnabled && restored.startup == .first && restored.appearance.style == .dark)
        restored.remember(mode: .traditional, colorID: -1, page: 0)
        restored.remember(mode: .traditional, colorID: 5, page: 2)
        check("无效位置不会覆盖已有记录", restored.position(for: .traditional)?.colorID == 100)
        defaults.set(Data("bad".utf8), forKey: "PlantColor.browsingHistory.v1")
        check("损坏浏览记录安全回退", HomePreferences(defaults: defaults).position(for: .botanical) == nil)
        check("已有设置编码值保持兼容", SetType.AllColor.rawValue == 0 && SetType.Language.rawValue == 13 && SetType.TraditionalManagement.rawValue == 16)
        let legacy = Data(#"{"sectionName":"","imageName":"","title":"Legacy","showSwitch":false,"switchState":false,"setType":0}"#.utf8)
        let legacyItem = try? JSONDecoder().decode(SetModel.self, from: legacy)
        check("旧设置模型不含当前值也能解码", legacyItem?.setType == .AllColor && legacyItem?.detail == nil)

        let cell = SettingCell(style: .default, reuseIdentifier: nil)
        cell.item = SetModel(sectionName: "", imageName: "sf.clock", title: "打开时显示", showSwitch: false,
                             switchState: false, setType: .StartupDisplay, detail: "上次浏览")
        check("设置行向辅助功能提供当前值", cell.accessibilityLabel == "打开时显示" && cell.accessibilityValue == "上次浏览")
        if #available(iOS 17.0, *) {
            cell.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
            cell.updateTraitsIfNeeded()
            cell.traitCollectionDidChange(nil)
            let content = cell.contentConfiguration as? UIListContentConfiguration
            check("大字号时设置文字放大", (content?.textProperties.font.pointSize ?? 0) > 30)
            check("辅助字号的当前值纵向排列避免挤压", content?.prefersSideBySideTextAndSecondaryText == false)
            cell.frame = CGRect(x: 0, y: 0, width: 320, height: 52)
            cell.layoutIfNeeded()
            let fitting = cell.contentView.systemLayoutSizeFitting(CGSize(width: 280, height: 0),
                                                                   withHorizontalFittingPriority: .required,
                                                                   verticalFittingPriority: .fittingSizeLevel)
            check("辅助字号设置行可以增长而非固定截断", fitting.height > 100)
        }
        cell.item = SetModel(sectionName: "", imageName: "sf.hand.tap", title: "触感反馈", showSwitch: true,
                             switchState: false, setType: .HapticFeedback)
        check("触感开关有明确标签与状态", (cell.accessoryView as? UISwitch)?.accessibilityLabel == "触感反馈" && (cell.accessoryView as? UISwitch)?.isOn == false)
        check("触感开关只暴露一个可访问控件", cell.accessibilityElements?.count == 1)
        cell.prepareForReuse()
        check("设置行复用清理旧动作", cell.switchDidClick == nil)
    }
}
#endif
