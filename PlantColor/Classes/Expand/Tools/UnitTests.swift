//
//  UnitTests.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//  Copyright © 2024 PlantColor. All rights reserved.
//

import Foundation
import CleanJSON

#if DEBUG
/// 简单的单元测试框架
class PlantColorTests {
    
    static let shared = PlantColorTests()
    private var testResults: [String: Bool] = [:]
    
    private init() {}
    
    /// 运行所有测试
    func runAllTests() {
        AppLogger.shared.info("开始运行单元测试...")
        
        testColorProvider()
        testConfigLoading()
        testDataParsing()
        
        let passedTests = testResults.values.filter { $0 }.count
        let totalTests = testResults.count
        
        AppLogger.shared.info("测试完成: \(passedTests)/\(totalTests) 通过")
        
        if passedTests == totalTests {
            AppLogger.shared.info("所有测试通过!")
        } else {
            AppLogger.shared.warning("有 \(totalTests - passedTests) 个测试失败")
        }
    }
    
    /// 测试ColorProvider
    private func testColorProvider() {
        let testName = "ColorProvider测试"
        do {
            let colors = ColorProvider.fetchColors()
            if !colors.isEmpty {
                testResults[testName] = true
                AppLogger.shared.info("\(testName): 通过 - 成功加载\(colors.count)个颜色")
            } else {
                testResults[testName] = false
                AppLogger.shared.error("\(testName): 失败 - 没有加载到颜色数据")
            }
        } catch {
            testResults[testName] = false
            AppLogger.shared.error("\(testName): 失败 - \(error.localizedDescription)")
        }
    }
    
    /// 测试配置加载
    private func testConfigLoading() {
        let testName = "配置加载测试"
        do {
            let appKey = String.umAppKey
            let channel = String.umChannel
            let appID = String.appID
            
            if !appKey.isEmpty && !channel.isEmpty && !appID.isEmpty {
                testResults[testName] = true
                AppLogger.shared.info("\(testName): 通过 - 配置加载成功")
            } else {
                testResults[testName] = false
                AppLogger.shared.error("\(testName): 失败 - 配置加载失败")
            }
        } catch {
            testResults[testName] = false
            AppLogger.shared.error("\(testName): 失败 - \(error.localizedDescription)")
        }
    }
    
    /// 测试数据解析
    private func testDataParsing() {
        let testName = "数据解析测试"
        do {
            guard let jsonPath = Bundle.main.path(forResource: "PlantColor", ofType: "json"),
                  let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
                testResults[testName] = false
                AppLogger.shared.error("\(testName): 失败 - 无法找到数据文件")
                return
            }
            
            let colors: [ColorModel] = try CleanJSONDecoder().decode([ColorModel].self, from: jsonData)
            if !colors.isEmpty {
                testResults[testName] = true
                AppLogger.shared.info("\(testName): 通过 - 成功解析\(colors.count)个颜色模型")
            } else {
                testResults[testName] = false
                AppLogger.shared.error("\(testName): 失败 - 解析结果为空")
            }
        } catch {
            testResults[testName] = false
            AppLogger.shared.error("\(testName): 失败 - \(error.localizedDescription)")
        }
    }
}
#endif 