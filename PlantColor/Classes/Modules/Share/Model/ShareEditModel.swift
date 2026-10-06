//
//  ShareEditModel.swift
//  PlantColor
//
//  Created by QY on 2022/5/7.
//

import Foundation

class ShareEditModel {
    
    let title: String

    let icon: String

    let category: ShareEditCategory
    
    let items: [ShareEditType]

    init(title: String,
         icon: String,
         category: ShareEditCategory,
         items: [ShareEditType]) {
        self.title = title
        self.icon = icon
        self.category = category
        self.items = items
    }

    var selectedIndex: Int = 0
}

enum ShareEditCategory {
    
    case ratio
    
    case orientation
    
    case style
}

enum ShareEditType: String {
    
    case ratio_device

    case ratio_square

    case ratio_16_9

    case ratio_4_3

    case orientation_portrait

    case orientation__landscape

    case style_empty

    case style_onlyText

    case style_onlyImage

    case style_image_text_bottom

    case style_text_image_bottom_right
}

extension ShareEditType {
    var title: String {
        switch self {
        case .ratio_device:
            return NSLocalizedString("share_edit_device_size", comment: "")
        case .ratio_square:
            return NSLocalizedString("share_edit_square", comment: "")
        case .ratio_16_9:
            return "16:9"
        case .ratio_4_3:
            return "4:3"
        case .orientation_portrait:
            return NSLocalizedString("share_edit_portrait", comment: "")
        case .orientation__landscape:
            return NSLocalizedString("share_edit_landscape", comment: "")
        case .style_empty:
            return NSLocalizedString("share_edit_solid_color", comment: "")
        case .style_onlyText:
            return NSLocalizedString("share_edit_text_only", comment: "")
        case .style_onlyImage:
            return NSLocalizedString("share_edit_image_only", comment: "")
        case .style_image_text_bottom:
            return NSLocalizedString("share_edit_style_one", comment: "")
        case .style_text_image_bottom_right:
            return NSLocalizedString("share_edit_style_two", comment: "")
        }
    }

    var image: String {
        switch self {
        case .ratio_device:
            return R.image.equipmentSize.name
        case .ratio_square:
            return R.image.square.name
        case .ratio_16_9:
            return "16_9"
        case .ratio_4_3:
            return "4_3"
        case .orientation_portrait:
            return R.image.verticalVersion.name
        case .orientation__landscape:
            return R.image.horizontalVersion.name
        case .style_empty:
            return R.image.initialColour.name
        case .style_onlyText:
            return R.image.designationStyle.name
        case .style_onlyImage:
            return R.image.graphicStyles.name
        case .style_image_text_bottom:
            return R.image.nameStyle_01.name
        case .style_text_image_bottom_right:
            return R.image.nameStyle_02.name
        }
    }
    
    var aspectRatio: CGFloat {
        switch self {
        case .ratio_device:
            return .screenHeight / .screenWidth
        case .ratio_square:
            return 1
        case .ratio_16_9:
            return 16 / 9
        case .ratio_4_3:
            return 4 / 3
        default:
            return -1
        }
    }
    
    var screenScale: CGFloat {
        switch self {
        case .ratio_device:
            return 0.33
        case .ratio_square:
            return 0.7
        case .ratio_16_9:
            return 0.4
        case .ratio_4_3:
            return 0.5
        default:
            return -1
        }
    }
}
