//
//  MBHUDExtension.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

/// Features:
/// ✅ 支持链式调用;
/// ✅ 自动复用同一个 UIView 上已经存在的 MBProgressHUD 对象;
/// ✅ 确保在主线程刷新 MBProgressHUD;
/// ✅ 自定义 customView 时，自动切换 MBProgressHUD 的 mode;

import MBProgressHUD

/// MBProgressHUD 的通用封装
public extension MBHUDWrapper where Base: UIView {

    /// 显示 HUD
    /// - Parameters:
    ///   - animated: 是否显示动画
    /// - Returns: 用于链式调用和方法限制，可不接收返回值
    @discardableResult
    func show(animated: Bool = true) -> MBHUDWrapper<MBHUDWrapper<Base>>  {

        DispatchQueue.main.async {

            if self.existHUD == nil {
                MBProgressHUD.showAdded(to: self.base,
                                        animated: animated)
            }
        }
        return MBHUDWrapper<MBHUDWrapper<Base>>(self)
    }

    /// 获取已经存在的 MBProgressHUD 对象
    var exist: MBHUDWrapper<MBHUDWrapper<Base>> {
        MBHUDWrapper<MBHUDWrapper<Base>>(self)
    }

    private var existHUD: MBProgressHUD? {

        let hud = MBProgressHUD.forView(self.base)
        if hud == nil {
            print("\(String(describing: self))中不存在 MBProgressHUD 对象")
        }
        return hud
    }
}

public extension MBHUDWrapper where Base == MBHUDWrapper<UIView> {

    @discardableResult
    func hide(animated: Bool = true,
              hideAfterDelay afterDelay: TimeInterval = 0) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {

            self.base.existHUD?.hide(animated: animated,
                                     afterDelay: afterDelay)
        }
        return self
    }

    @discardableResult
    func setBackgroundViewStyle(_ value: ProgressHUDBackgroundStyle = .solidColor) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {

            self.base.existHUD?.backgroundView.style = value.mbType
        }
        return self
    }

    @discardableResult
    func setBackgroundViewColor(_ value: UIColor = .clear) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {

            self.base.existHUD?.backgroundView.color = value
        }
        return self
    }

    @discardableResult
    func setBackgroundViewBlurEffectStyle(_ value: UIBlurEffect.Style) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {

            self.base.existHUD?.backgroundView.blurEffectStyle = value
        }
        return self
    }

    @discardableResult
    func setMode(_ value: ProgressHUDMode = .indeterminate) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.mode = value.mbType
        }
        return self
    }

    @discardableResult
    func setAnimationType(_ value: ProgressHUDAnimation = .fade) -> MBHUDWrapper<Base> {
        
        DispatchQueue.main.async {
            self.base.existHUD?.animationType = value.mbType
        }
        return self
    }

    @discardableResult
    func setText(_ value: String? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.label.text = value
        }
        return self
    }

    @discardableResult
    func setDetail(_ value: String? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.detailsLabel.text = value
        }
        return self
    }

    @discardableResult
    func setGraceTime(_ value: TimeInterval = 0) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.graceTime = value
        }
        return self
    }

    @discardableResult
    func setMinShowTime(_ value: TimeInterval = 0) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.minShowTime = value
        }
        return self
    }

    @discardableResult
    func setRemoveFromSuperViewOnHide(_ value: Bool = false) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.removeFromSuperViewOnHide = value
        }
        return self
    }

    @discardableResult
    func setContentColor(_ value: UIColor? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.contentColor = value
        }
        return self
    }

    @discardableResult
    func setMargin(_ value: CGFloat = 20) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.margin = value
        }
        return self
    }

    @discardableResult
    func setMinSize(_ value: CGSize = .zero) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.minSize = value
        }
        return self
    }

    @discardableResult
    func setIsSquare(_ value: Bool = false) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.isSquare = value
        }
        return self
    }

    @discardableResult
    func setAreDefaultMotionEffectsEnabled(_ value: Bool = false) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.areDefaultMotionEffectsEnabled = value
        }
        return self
    }

    @discardableResult
    func setProgress(_ value: Float = 0) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.progress = value
        }
        return self
    }

    @discardableResult
    func setProgressObject(_ value: Progress? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.progressObject = value
        }
        return self
    }

    @discardableResult
    func setCustomView(_ value: UIView? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.mode = .customView
            self.base.existHUD?.customView = value
        }
        return self
    }

    @discardableResult
    func setCompletion(_ value: (() -> Void)? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.completionBlock = value
        }
        return self
    }

    @discardableResult
    func setOffset(_ value: CGPoint) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            self.base.existHUD?.offset = value
        }
        return self
    }

    @discardableResult
    func label(_ value: ((UILabel?) -> ())?) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            value?(self.base.existHUD?.label)
        }
        return self
    }

    @discardableResult
    func detailsLabel(_ value: ((UILabel?) -> ())?) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            value?(self.base.existHUD?.detailsLabel)
        }
        return self
    }

    @discardableResult
    func backGroundView(_ value: ((UIView?) -> ())?) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            value?(self.base.existHUD?.backgroundView)
        }
        return self
    }

    @discardableResult
    func bezelView(_ value: ((UIView?) -> ())?) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {
            value?(self.base.existHUD?.bezelView)
        }
        return self
    }

    @discardableResult
    func setProperties(mode: ProgressHUDMode = .indeterminate,
                       animationType: ProgressHUDAnimation = .fade,
                       text: String? = nil,
                       detail: String? = nil,
                       graceTime: TimeInterval = 0,
                       minShowTime: TimeInterval = 0,
                       removeFromSuperViewOnHide: Bool = false,
                       contentColor: UIColor? = nil,
                       margin: CGFloat = 20,
                       minSize: CGSize = .zero,
                       isSquare: Bool = false,
                       areDefaultMotionEffectsEnabled: Bool = false,
                       progress: Float = 0,
                       progressObject: Progress? = nil,
                       customView: UIView? = nil,
                       backgroundViewStyle: ProgressHUDBackgroundStyle = .solidColor,
                       backgroundViewColor: UIColor = .clear,
                       completion: (() -> Void)? = nil) -> MBHUDWrapper<Base> {

        DispatchQueue.main.async {

            let hud = self.base.existHUD
            hud?.mode = mode.mbType
            hud?.animationType = animationType.mbType
            hud?.label.text = text
            hud?.detailsLabel.text = detail
            hud?.graceTime = graceTime
            hud?.minShowTime = minShowTime
            hud?.removeFromSuperViewOnHide = removeFromSuperViewOnHide
            hud?.contentColor = contentColor
            hud?.margin = margin
            hud?.minSize = minSize
            hud?.isSquare = isSquare
            hud?.areDefaultMotionEffectsEnabled = areDefaultMotionEffectsEnabled
            hud?.progress = progress
            hud?.progressObject = progressObject
            hud?.customView = customView
            hud?.backgroundView.style = backgroundViewStyle.mbType
            hud?.backgroundView.color = backgroundViewColor
            hud?.completionBlock = completion
        }
        return self
    }
}
