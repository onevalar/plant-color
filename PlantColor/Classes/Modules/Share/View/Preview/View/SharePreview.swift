//
//  SharePreview.swift
//  PlantColor
//
//  Created by insect on 2022/5/9.
//

import UIKit
import SnapKit
import SwiftUI

class SharePreview: View {

    var items: [ShareEditModel] = [] {
        didSet {
            reloadView()
        }
    }
    
    var ratio: ShareEditType = .ratio_device
    
    var orientation: ShareEditType = .orientation_portrait
    
    var style: ShareEditType = .style_empty
    
    var isScreenshot: Bool = false
    
    let colorModel: ColorModel
    
    public var containerView: View?
    
    private var titleLabel: Label?
    
    private var iconImage: UIImageView?
    
    init(colorModel: ColorModel,
         items: [ShareEditModel],
         isScreenshot: Bool) {
        self.colorModel = colorModel
        self.items = items
        self.isScreenshot = isScreenshot
        super.init(frame: .zero)
        updateProperty()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeUI() {
        super.makeUI()
        backgroundColor = .main
        reloadView()
    }
    
    private func reloadView() {
        
        updateProperty()
        createContainerView()
        createTitleLabel()
        createImageView()
    }
    
    private func updateProperty() {
        for item in items {
            let type = item.items[item.selectedIndex]
            switch item.category {
            case .ratio:
                ratio = type
            case .orientation:
                orientation = type
            case .style:
                style = type
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sideLength: CGFloat = .screenWidth * (isScreenshot ? 1.0 : ratio.screenScale)
        let ratioLength = sideLength * ratio.aspectRatio
        switch orientation {
            
        case .orientation_portrait:
            
            containerView?.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.width.equalTo(sideLength)
                $0.height.equalTo(ratioLength)
            }
            
            switch style {
            case .style_onlyText:
                titleLabel?.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().offset(-ratioLength * 0.2)
                }
            case .style_onlyImage:
                iconImage?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.width.equalToSuperview().multipliedBy(0.7)
                    } else {
                        $0.width.equalToSuperview().multipliedBy(0.8)
                    }
                    $0.height.equalTo(self.iconImage!.snp.width).multipliedBy(0.8)
                    $0.centerX.centerY.equalToSuperview()
                }
            case .style_image_text_bottom:
                iconImage?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.width.equalToSuperview().multipliedBy(0.7)
                        $0.top.equalToSuperview().offset(ratioLength * 0.15)
                    } else {
                        $0.width.equalToSuperview().multipliedBy(0.8)
                        $0.centerY.equalToSuperview()
                    }
                    $0.height.equalTo(self.iconImage!.snp.width).multipliedBy(0.8)
                    $0.centerX.equalToSuperview()
                }
                
                titleLabel?.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.top.equalTo(self.iconImage!.snp.bottom)
                }
            case .style_text_image_bottom_right:
                
                titleLabel?.snp.makeConstraints {
                    $0.left.equalToSuperview().offset(sideLength * 0.1)
                    $0.top.equalToSuperview().offset(ratioLength * 0.15)
                }
                
                iconImage?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.width.equalToSuperview().multipliedBy(0.7)
                        $0.top.equalTo(self.titleLabel!.snp.bottom)
                    } else {
                        $0.width.equalToSuperview().multipliedBy(0.8)
                        $0.centerY.equalToSuperview()
                    }
                    $0.height.equalTo(self.iconImage!.snp.width).multipliedBy(0.8)
                    $0.centerX.equalToSuperview()
                }
            default:
                break
            }
        case .orientation__landscape:
            
            containerView?.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.width.equalTo(ratioLength)
                $0.height.equalTo(sideLength)
            }
            
            switch style {
            case .style_onlyText:
                titleLabel?.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().offset(-sideLength * 0.15)
                }
            case .style_onlyImage:
                iconImage?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.width.equalToSuperview().multipliedBy(0.7)
                    } else {
                        $0.width.equalToSuperview().multipliedBy(0.4)
                    }
                    $0.height.equalTo(self.iconImage!.snp.width).multipliedBy(0.8)
                    $0.centerX.centerY.equalToSuperview()
                }
            case .style_image_text_bottom:
                
                titleLabel?.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    if ratio == .ratio_square {
                        $0.top.equalTo(self.iconImage!.snp.bottom)
                    } else {
                        $0.bottom.equalToSuperview().offset(-sideLength * 0.1)
                    }
                }
                
                iconImage?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.width.equalToSuperview().multipliedBy(0.7)
                        $0.top.equalToSuperview().offset(ratioLength * 0.15)
                    } else {
                        $0.width.equalToSuperview().multipliedBy(0.4)
                        $0.bottom.equalTo(self.titleLabel!.snp.top)
                    }
                    $0.height.equalTo(self.iconImage!.snp.width).multipliedBy(0.8)
                    $0.centerX.equalToSuperview()
                }
            case .style_text_image_bottom_right:
                
                titleLabel?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.top.equalToSuperview().offset(sideLength * 0.15)
                    } else {
                        $0.top.equalToSuperview().offset(sideLength * 0.1)
                    }
                    $0.left.equalToSuperview().offset(ratioLength * 0.1)
                }
                
                iconImage?.snp.makeConstraints {
                    if ratio == .ratio_square {
                        $0.width.equalToSuperview().multipliedBy(0.7)
                        $0.top.equalTo(self.titleLabel!.snp.bottom)
                    } else {
                        $0.width.equalToSuperview().multipliedBy(0.4)
                        $0.top.equalTo(self.titleLabel!.snp.bottom)
                    }
                    $0.height.equalTo(self.iconImage!.snp.width).multipliedBy(0.8)
                    $0.centerX.equalToSuperview()
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    private func createContainerView() {
        
        containerView?.removeFromSuperview()
        containerView = View(frame: .zero)
        if !isScreenshot {
            containerView?.cornerRadius = 5
        }
        containerView?.backgroundColor = colorModel.color
        if let containerView = containerView {
            addSubview(containerView)
        }
    }
    
    private func createTitleLabel() {
        
        titleLabel?.removeFromSuperview()
        
        if style == .style_empty || style == .style_onlyImage {
            return
        }
        titleLabel = Label()
        titleLabel?.textColor = colorModel.textUIColor
        titleLabel?.text = colorModel.plantName
        titleLabel?.font = UIFont.fzktjwgb10(size: (isScreenshot ? 1 : ratio.screenScale) * 46)
        
        if let titleLabel = titleLabel {
            containerView?.addSubview(titleLabel)
        }
    }
    
    private func createImageView() {
        
        iconImage?.removeFromSuperview()
        
        if style == .style_empty || style == .style_onlyText {
            return
        }
        
        iconImage = UIImageView()
        iconImage?.image = UIImage(named: colorModel.imageName)
        if let iconImage = iconImage {
            containerView?.addSubview(iconImage)
        }
    }
}
