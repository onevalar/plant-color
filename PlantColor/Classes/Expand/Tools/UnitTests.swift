//
//  UnitTests.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//  Copyright © 2024 PlantColor. All rights reserved.
//

import Foundation

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
}
#endif
