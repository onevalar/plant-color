//
//  NavigationController.swift
//  HelloSVU_Swift
//
//  Created by Insect on 2017/5/23.
//  Copyright © 2017年 Insect. All rights reserved.
//

import EachNavigationBar
import FDFullscreenPopGesture
import QYUINavigationBarExtension
import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 转场动画
        updateMotionPreference()
        NotificationCenter.default.addObserver(self, selector: #selector(accessibilityMotionChanged),
                                               name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
        // Keep Hero's enabled state and navigation delegate consistent. Clearing only the
        // transition delegate makes the next accessibility refresh register Hero as its
        // own previous delegate, recursively forwarding navigation callbacks.
        // 全屏滑动返回
        fd_fullscreenPopGestureRecognizer.isEnabled = true
        // 导航栏背景和文字设置
        setUpNavigation()
    }

    func updateMotionPreference(reduceMotion: Bool = UIAccessibility.isReduceMotionEnabled) {
        hero.isEnabled = !reduceMotion
    }

    @objc private func accessibilityMotionChanged() { updateMotionPreference() }

    private func setUpNavigation() {
        
        navigation.configuration.isShadowHidden = true
        navigation.configuration.isEnabled = true
        navigation.configuration.titleTextAttributes = [.foregroundColor: UIColor.navBarTitle]
        navigation.configuration.prefersLargeTitles = true
        navigation.configuration.largeTitle.displayMode = .always
        navigation.configuration.backItem = UINavigationController.Configuration.BackItem(style: .image(.sf(systemSymbol: .chevronBackward)),
                                                                                          tintColor: nil)
    }

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        topViewController
    }

    override var shouldAutorotate: Bool {
        topViewController?.shouldAutorotate ?? true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        AppLogger.shared.debug("\(type(of: self)): deinit")
    }
}

// MARK: - 返回点击事件

extension NavigationController {
    @objc private func backButtonDidClick() {
        popViewController(animated: true)
    }
}
