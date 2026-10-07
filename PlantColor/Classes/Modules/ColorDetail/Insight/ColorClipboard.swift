//
//  ColorClipboard.swift
//  PlantColor
//
//  点一下复制色值。
//

import UIKit

enum ColorClipboard {

    static func copy(_ text: String, from view: UIView) {
        UIPasteboard.general.string = text
        Feedback.lightPrepare()
        let host: UIView = view.window ?? view
        host.showSuccessHUD(String(format: NSLocalizedString("common_copied", comment: ""), text))
    }
}
