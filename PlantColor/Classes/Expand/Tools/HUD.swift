//
//  HUD.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

/// 项目使用的 HUD 封装
extension UIView {

    @discardableResult
    public func showSuccessHUD(_ text: String,
                               completion: (() -> Void)? = nil) -> MBHUDWrapper<MBHUDWrapper<UIView>> {
        commonHUD(text,
                  completion: completion)
            .setCustomView(wjView(.success))
    }

    @discardableResult
    public func showErrorHUD(_ text: String,
                             completion: (() -> Void)? = nil) -> MBHUDWrapper<MBHUDWrapper<UIView>> {
        commonHUD(text,
                  completion: completion)
            .setCustomView(wjView(.error))
    }

    @discardableResult
    public func showLoadingHUD(_ text: String? = nil) -> MBHUDWrapper<MBHUDWrapper<UIView>> {
        mbHUD.show().setMode().setText(text)
    }

    public func hideHUD() {
        mbHUD.exist.hide()
    }

    @discardableResult
    public func showHorizontalBarHUD(_ text: String? = nil) -> MBHUDWrapper<MBHUDWrapper<UIView>> {

        mbHUD
            .show()
            .setProperties(mode: .determinateHorizontalBar,
                           text: text,
                           progress: 0)
    }

    @discardableResult
    public func setHUDProgress(_ value: Float = 0) -> MBHUDWrapper<MBHUDWrapper<UIView>> {
        mbHUD.exist.setProgress(value)
    }

    @discardableResult
    private func commonHUD(_ text: String,
                           completion: (() -> Void)? = nil) -> MBHUDWrapper<MBHUDWrapper<UIView>> {

        mbHUD
            .show()
            .setProperties(mode: .customView,
                           text: text,
                           completion: completion)
            .hide(hideAfterDelay: .hudAutoHideTime)
    }

    private func wjView(_ type: WJAnimationType) -> WJSuccessView {

        let view = WJSuccessView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: 40,
                                               height: 40))
        view.strokeColor = .black
        view.wj_animationType = type
        return view
    }
}
