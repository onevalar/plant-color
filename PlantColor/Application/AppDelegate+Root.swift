//
//  AppDelegate+Root.swift
//  Scanking
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import UIKit
import Kingfisher
import AppTrackingTransparency
import AdSupport
import DefaultsKit

extension AppDelegate {
    
    // MARK: - 设置根控制器
    func initRootViewController() {

        setAllDefaultConfig()
        setUpThirdPartyConfig()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let lastBuildNumber = Defaults().get(for: AppKey.buildNumberKey),
            let buildNumber = UIApplication.buildNumber { // 本地读取过数据文件
            if buildNumber == lastBuildNumber { // 数据未更新
                window?.rootViewController = NavigationController(rootViewController: HomeViewController())
            } else { // 数据已更新
                window?.rootViewController = NavigationController(rootViewController: LoadingViewController())
            }
        } else { // 未读取过数据文件
            window?.rootViewController = NavigationController(rootViewController: LoadingViewController())
        }
        
        window?.makeKeyAndVisible()
    }
    
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] status in
                AppLogger.shared.info("IDFA权限状态: \(status.rawValue)")
                self?.setUpUMeng()
            })
        } else {
            self.setUpUMeng()
        }
    }
    
    // MARK: - 友盟
    func setUpUMeng() {
        // UMCommonSwift 暂时禁用（UMCommonSwift.swift 中 #if false），等 pod 适配后再开启
        // UMCommonSwift.initWithAppkey(appKey: .umAppKey, channel: .umChannel)
        AppLogger.shared.info("友盟初始化已跳过（暂时禁用）")
    }

    func setUpThirdPartyConfig() {
        setupKingfisher()
    }
    
    // MARK: - Kingfisher
    private func setupKingfisher() {
        // 配置Kingfisher缓存
        ImageCache.default.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024 // 300MB
        ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024 // 1GB
        AppLogger.shared.info("Kingfisher配置完成")
    }
    
    // MARK: - 设置base用户数据
    func initDefaultConfig() {
        AppLogger.shared.info("应用初始化完成")
        
        #if DEBUG
        // 在DEBUG模式下运行测试和环境检查
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 检查构建环境
            BuildScripts.shared.checkBuildEnvironment()
            BuildScripts.shared.validateProjectConfiguration()
            
            // 运行单元测试
            PlantColorTests.shared.runAllTests()
        }
        #endif
    }
}
