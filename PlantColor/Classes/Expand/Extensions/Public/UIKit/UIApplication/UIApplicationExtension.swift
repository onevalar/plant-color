//
//  UIApplicationExtension.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

public extension UIApplication {

    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        }
        return shared.windows.filter { $0.isKeyWindow }.first
    }

    static func delegate<T: UIApplicationDelegate>() -> T? {
        shared.delegate as? T
    }

    static var rootViewController: UIViewController? {
        getRootViewController(keyWindow?.rootViewController)
    }

    static func getRootViewController(_ inViewController: UIViewController?) -> UIViewController? {

        guard let rootVc = inViewController else { return nil }

        if rootVc.isKind(of: UINavigationController.self) {
            return getRootViewController((rootVc as? UINavigationController)?.visibleViewController)
        } else if rootVc.isKind(of: UITabBarController.self) {
            return getRootViewController((rootVc as? UITabBarController)?.selectedViewController)
        } else {
            return rootVc
        }
    }

    static func open(_ url: String,
                     options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:],
                     completionHandler completion: ((Bool) -> Void)? = nil) {

        guard let url = URL(string: url)
        else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: options, completionHandler: completion)
        }
    }

    static var displayName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    static var buildNumber: String? {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    static var version: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
