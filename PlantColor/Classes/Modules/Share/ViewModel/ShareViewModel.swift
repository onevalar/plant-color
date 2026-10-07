//
//  ShareViewModel.swift
//  PlantColor
//
//  Created by insect on 2022/5/9.
//

import Foundation

class ShareViewModel {
    /// hasImage：这个颜色有没有配图。没有配图（传统色）时，只提供不依赖图片的样式
    static func editItems(hasImage: Bool = true) -> [ShareEditModel] {
        let styles: [ShareEditType] = hasImage
            ? [.style_empty,
               .style_onlyText,
               .style_onlyImage,
               .style_image_text_bottom,
               .style_text_image_bottom_right]
            : [.style_empty,
               .style_onlyText,
               .style_text_values]

        return [ShareEditModel(title: NSLocalizedString("share_ratio", comment: ""),
                        icon: R.image.rate.name,
                        category: .ratio,
                        items: [.ratio_device,
                                .ratio_square,
                                .ratio_16_9,
                                .ratio_4_3]),

         ShareEditModel(title: NSLocalizedString("share_orientation", comment: ""),
                        icon: R.image.orientation.name,
                        category: .orientation,
                        items: [.orientation_portrait,
                                .orientation__landscape]),

         ShareEditModel(title: NSLocalizedString("share_style", comment: ""),
                        icon: R.image.modality.name,
                        category: .style,
                        items: styles)]
    }
}
