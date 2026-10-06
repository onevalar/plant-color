//
//  ShareViewModel.swift
//  PlantColor
//
//  Created by insect on 2022/5/9.
//

import Foundation

class ShareViewModel {
    static func editItems() -> [ShareEditModel] {
        [ShareEditModel(title: NSLocalizedString("share_ratio", comment: ""),
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
                        items: [.style_empty,
                                .style_onlyText,
                                .style_onlyImage,
                                .style_image_text_bottom,
                                .style_text_image_bottom_right])]
    }
}
