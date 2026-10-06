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

        guard let url = URL(string: url), let currentVc = UIApplication.keyWindow?.rootViewController else { return }
        let vc = SFSafariViewController(url: url)
        currentVc.dismiss(animated: true)
        currentVc.present(vc,animated: true,completion: nil)
    }
    
    static func commentMyApp() {
        let urlStr = "https://itunes.apple.com/us/app/itunes-u/id\(String.appID)?action=write-review&mt=8"
        guard let url = URL(string: urlStr) else {
            print("Invalid URL: \(urlStr)")
            return
        }
        UIApplication.shared.open(url)
    }
    
    static func shareMyApp(name: String) {
            let title = name
            guard let urlToShare = URL(string: "http://itunes.apple.com/us/app/id\(String.appID)") else {
                print("Invalid share URL")
                return
            }
            let activityVc = UIActivityViewController(activityItems: [title, urlToShare], applicationActivities: nil)
            guard let currentVc = UIApplication.keyWindow?.rootViewController else { return }
            currentVc.dismiss(animated: true)
            currentVc.present(activityVc, animated: true, completion: nil)
        }
    
}
