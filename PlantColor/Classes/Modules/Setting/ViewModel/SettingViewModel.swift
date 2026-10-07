//
//  SettingViewModel.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/6.
//


import Foundation
import SafariServices

struct SettingViewModel {
 
    // MARK: - 致谢
    static func acknowledgement() {
        openURL("https://www.craft.do/s/vau7kVSN9bv37P")
    }

    // MARK: - 联系反馈
    static func contactFeedback() {
        openURL("https://www.craft.do/s/dkkHe8klvvYa1M")
    }
    
    
    static private func openURL(_ url: String) {

        guard let url = URL(string: url), let currentVc = topViewController() else { return }
        let vc = SFSafariViewController(url: url)
        currentVc.present(vc,animated: true,completion: nil)
    }

    /// 当前最上层的页面。设置页本身就是弹出来的，
    /// 直接在它上面继续弹出，不能再去关掉它
    static private func topViewController() -> UIViewController? {
        var top = UIApplication.keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
    
    static func commentMyApp() {
        let urlStr = "https://itunes.apple.com/us/app/itunes-u/id\(String.appID)?action=write-review&mt=8"
        guard let url = URL(string: urlStr) else {
            AppLogger.shared.error("Invalid URL: \(urlStr)")
            return
        }
        UIApplication.shared.open(url)
    }
    
    static func shareMyApp(name: String) {
            let title = name
            guard let urlToShare = URL(string: "http://itunes.apple.com/us/app/id\(String.appID)") else {
                AppLogger.shared.error("Invalid share URL")
                return
            }
            let activityVc = UIActivityViewController(activityItems: [title, urlToShare], applicationActivities: nil)
            guard let currentVc = topViewController() else { return }
            currentVc.present(activityVc, animated: true, completion: nil)
        }
    
}
