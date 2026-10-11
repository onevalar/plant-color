import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = HomePreferences.shared.appearance.style
        if ColorImporter.needsImport {
            window.rootViewController = NavigationController(rootViewController: LoadingViewController())
        } else {
            window.rootViewController = NavigationController(rootViewController: HomeViewController())
        }
        self.window = window
        window.makeKeyAndVisible()

        // 冷启动时的小组件链接也要保留；数据未就绪时由路由器等待导入完成。
        for context in connectionOptions.urlContexts {
            DeepLinkRouter.shared.handle(context.url)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.requestIDFA()
        DeepLinkRouter.shared.flushPending()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            DeepLinkRouter.shared.handle(context.url)
        }
    }
}
