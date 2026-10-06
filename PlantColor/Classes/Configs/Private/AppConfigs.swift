//
//  AppConfigs.swift
//  Scanking
//
//  Created by Scanking on 2021/7/5.
//

import UIKit

extension String {
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }

    static var umAppKey: String {
        // 从配置文件读取，如果没有则使用默认值
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let appKey = config["UMAppKey"] as? String {
            return appKey
        }
        // 默认值，建议在生产环境中使用配置文件
        return "627df8eb30a4f67780d89c39"
    }
    
    static var umChannel: String {
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let channel = config["UMChannel"] as? String {
            return channel
        }
        return "App Store"
    }
    
    static var appID: String {
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let appID = config["AppID"] as? String {
            return appID
        }
        return "1624250860"
    }

    /// 默认用户 id 为以后多用户做准备
    static var userId: String {
        "slave"
    }
}
