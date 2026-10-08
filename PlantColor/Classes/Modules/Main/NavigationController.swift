//
//  NavigationController.swift
//  PlantColor
//
//  使用系统原生导航：自带返回按钮、侧滑返回、大标题，在新系统上自动是 Liquid Glass 样式。
//  （原先用第三方"每个页面一条假导航栏"的方案，在新系统上返回按钮会丢失、顶部留白很大。）
//

import UIKit

final class NavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .settingsAccent

        if #unavailable(iOS 26.0) {
            // 旧系统：背景透明，滚动时才出现细线，接近新系统观感
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
        // 导航栏被隐藏（首页）时，侧滑返回手势默认会失效，这里手动保留
        interactivePopGestureRecognizer?.delegate = self
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    override var childForStatusBarStyle: UIViewController? { topViewController }
    override var childForStatusBarHidden: UIViewController? { topViewController }
    override var shouldAutorotate: Bool { topViewController?.shouldAutorotate ?? true }

    deinit {
        AppLogger.shared.debug("\(type(of: self)): deinit")
    }
}
