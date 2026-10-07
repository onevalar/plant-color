//
//  ColorHueCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit

class ColorHueCell: UICollectionViewCell {

    var showHUEDidClick: (() -> Void)?

    private var isShowHUE: Bool = false

    @IBOutlet private weak var imageTrailingConstraint: NSLayoutConstraint! {
        didSet {
            imageTrailingConstraint.constant = -(CGFloat.screenWidth) * 0.5
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var hexLabel: UILabel!
    @IBOutlet private weak var rgbLabel: UILabel!
    @IBOutlet private weak var cmykLabel: UILabel!
    @IBOutlet private weak var showHueButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.fzktjwgb10(size: 46)
        }
    }
    @IBOutlet private weak var colorMenu: ColorMenu!
    @IBOutlet private weak var hueContentView: UIView! {
        didSet {
            hueContentView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(hideHUEDidClick)))
        }
    }
    @IBOutlet private weak var menuBottomConstraint: NSLayoutConstraint! {
        didSet {
            menuBottomConstraint.constant = .safeAreaBottom + 20
        }
    }
    
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint! {
        didSet {
            titleTopConstraint.constant = .safeAreaTop + 70
        }
    }
    
    public var item: (any ColorDisplayable)? {
        didSet {

            guard let item = item else { return }
            showHueButton.setImage(.sf(systemSymbol: .cameraFilters).withTintColor(item.textUIColor),
                                   for: .normal)
            if item.imageName.isEmpty {
                imageView.image = nil
                imageView.isHidden = true
            } else {
                imageView.image = UIImage(named: item.imageName)
                imageView.isHidden = false
            }
            titleLabel.text = item.displayName
            titleLabel.textColor = item.textUIColor
            rgbLabel.attributedText = item.colorRGBAttributedString(type: .home)
            cmykLabel.attributedText = item.colorCMYKAttributedString(type: .home)
            hexLabel.attributedText = item.colorHexAttributedString(type: .home)
            colorMenu.displayItem = item

            isShowHUE = false
            hueContentView.alpha = 0
            showHueButton.alpha = 1
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // 点一下色值就复制
        for label in [hexLabel, rgbLabel, cmykLabel] {
            label?.isUserInteractionEnabled = true
            label?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(valueLabelDidClick(_:))))
        }
    }

    @objc private func valueLabelDidClick(_ gesture: UITapGestureRecognizer) {
        // 色值只有在"色彩详情"展开时才可见，隐藏时不响应点击
        guard isShowHUE, let item = item, let label = gesture.view else { return }
        let text: String
        switch label {
        case hexLabel: text = item.colorHEX
        case rgbLabel: text = item.colorRGB.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ", ")
        default: text = item.colorCMYK.replacingOccurrences(of: ",", with: ", ")
        }
        ColorClipboard.copy(text, from: self)
    }

    @objc private func hideHUEDidClick() {
        isShowHUE = false
        Feedback.lightPrepare()
        UIView.animate(withDuration: 0.25) {
            self.hueContentView.alpha = 0
            self.showHueButton.alpha = 1
        }
    }

    @IBAction private func showHUEButotnDidClick() {
        isShowHUE = true
        Feedback.lightPrepare()
        UIView.animate(withDuration: 0.25) {
            self.hueContentView.alpha = 1
            self.showHueButton.alpha = 0
        }
    }
}
