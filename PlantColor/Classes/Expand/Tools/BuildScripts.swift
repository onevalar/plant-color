//
//  BuildScripts.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//  Copyright © 2024 PlantColor. All rights reserved.
//

import Foundation

/// 构建脚本优化工具
class BuildScripts {
    
    static let shared = BuildScripts()
    
    private init() {}
    
    /// 检查构建环境
    func checkBuildEnvironment() {
        AppLogger.shared.info("检查构建环境...")
        
        // 检查Xcode版本
        if let xcodeVersion = getXcodeVersion() {
            AppLogger.shared.info("Xcode版本: \(xcodeVersion)")
        }
        
        // 检查iOS SDK版本
        if let sdkVersion = getSDKVersion() {
            AppLogger.shared.info("iOS SDK版本: \(sdkVersion)")
        }
        
        // 检查CocoaPods版本
        if let podVersion = getCocoaPodsVersion() {
            AppLogger.shared.info("CocoaPods版本: \(podVersion)")
        }
        
        // 检查Swift版本
        if let swiftVersion = getSwiftVersion() {
            AppLogger.shared.info("Swift版本: \(swiftVersion)")
        }
    }
    
    private func getXcodeVersion() -> String? { return nil }
    private func getSDKVersion() -> String? { return nil }
    private func getCocoaPodsVersion() -> String? { return nil }
    private func getSwiftVersion() -> String? { return nil }
    
    /// 验证项目配置
    func validateProjectConfiguration() {
        AppLogger.shared.info("验证项目配置...")
        
        // 检查必要的文件是否存在
        let requiredFiles = [
            "PlantColor/Resources/PlantColor.json",
            "PlantColor/Resources/AppConfig.plist",
            "PlantColor/Info.plist"
        ]
        
        for filePath in requiredFiles {
            if FileManager.default.fileExists(atPath: filePath) {
                AppLogger.shared.info("✅ \(filePath) 存在")
            } else {
                AppLogger.shared.error("❌ \(filePath) 不存在")
            }
        }
        
        // 检查Pods是否正确安装
        if FileManager.default.fileExists(atPath: "Pods") {
            AppLogger.shared.info("✅ Pods目录存在")
        } else {
            AppLogger.shared.error("❌ Pods目录不存在，请运行 'pod install'")
        }
        
        // 检查workspace文件
        if FileManager.default.fileExists(atPath: "PlantColor.xcworkspace") {
            AppLogger.shared.info("✅ PlantColor.xcworkspace 存在")
        } else {
            AppLogger.shared.error("❌ PlantColor.xcworkspace 不存在")
        }
    }
    
    /// 清理构建缓存
    func cleanBuildCache() {
        AppLogger.shared.info("清理构建缓存...")
        
        let cachePaths = [
            "~/Library/Developer/Xcode/DerivedData",
            "~/Library/Caches/com.apple.dt.Xcode"
        ]
        
        for cachePath in cachePaths {
            let expandedPath = (cachePath as NSString).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expandedPath) {
                do {
                    try FileManager.default.removeItem(atPath: expandedPath)
                    AppLogger.shared.info("✅ 清理缓存: \(cachePath)")
                } catch {
                    AppLogger.shared.error("❌ 清理缓存失败: \(error.localizedDescription)")
                }
            }
        }
    }
} 