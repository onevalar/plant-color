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
        hero.isEnabled = true
        transitioningDelegate = nil
        // 全屏滑动返回
        fd_fullscreenPopGestureRecognizer.isEnabled = true
        // 导航栏背景和文字设置
        setUpNavigation()
    }

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
        print("\(type(of: self)): deinit")
    }
}

// MARK: - 返回点击事件

extension NavigationController {
    @objc private func backButtonDidClick() {
        popViewController(animated: true)
    }
}
