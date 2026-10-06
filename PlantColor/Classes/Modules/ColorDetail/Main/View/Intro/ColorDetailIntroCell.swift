//
//  ColorDetailIntroCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit
import BonMot

class ColorDetailIntroCell: UITableViewCell {

    @IBOutlet private weak var label1: UILabel!
    
    public var item: ColorModel? {
        didSet {
            
            guard let item = item else { return }
            
            let result = NSMutableAttributedString()
            result.append("\(item.plantFamily) \(item.plantGenus)\n".styled(with: .font(R.font.oppoSansR(size: 12)!)))
            
            if !item.plantLatin.isEmpty {
                result.append(item.plantLatinAttributeString)
            }
            
            if !item.plantAlias.isEmpty {
                result.append("\(NSLocalizedString("plant_detail_alias", comment: ""))\(item.plantAlias)".styled(with: .font(R.font.oppoSansR(size: 12)!)))
                if !item.plantGrowHabit.isEmpty
                    || !item.plantDistribution.isEmpty
                    || !item.plantLandscapeApplication.isEmpty
                    || !item.plantFlorescence.isEmpty
                    || !item.plantFruitingPeriod.isEmpty {
                    result.append("\n".attributedString())
                }
            }
            
            if !item.plantGrowHabit.isEmpty {
                result.append("\(NSLocalizedString("plant_detail_growth_habit", comment: ""))\(item.plantGrowHabit)".styled(with: .font(R.font.oppoSansR(size: 12)!)))
                if !item.plantDistribution.isEmpty
                    || !item.plantLandscapeApplication.isEmpty
                    || !item.plantFlorescence.isEmpty
                    || !item.plantFruitingPeriod.isEmpty {
                    result.append("\n".attributedString())
                }
            }
            
            if !item.plantDistribution.isEmpty {
                result.append("\(NSLocalizedString("plant_detail_distribution", comment: ""))\(item.plantDistribution)".styled(with: .font(R.font.oppoSansR(size: 12)!)))
                if !item.plantLandscapeApplication.isEmpty
                    || !item.plantFlorescence.isEmpty
                    || !item.plantFruitingPeriod.isEmpty {
                    result.append("\n".attributedString())
                }
            }
            
            if !item.plantLandscapeApplication.isEmpty {
                result.append("\(NSLocalizedString("plant_detail_landscape_app", comment: ""))\(item.plantLandscapeApplication)".styled(with: .font(R.font.oppoSansR(size: 12)!)))
                if !item.plantFlorescence.isEmpty
                    || !item.plantFruitingPeriod.isEmpty {
                    result.append("\n".attributedString())
                }
            }
            
            if !item.plantFlorescence.isEmpty {
                result.append("\(NSLocalizedString("plant_detail_florescence", comment: ""))\(item.plantFlorescence)".styled(with: .font(R.font.oppoSansR(size: 12)!)))
                if !item.plantFruitingPeriod.isEmpty {
                    result.append("\n".attributedString())
                }
            }
            
            if !item.plantFruitingPeriod.isEmpty {
                result.append("\(NSLocalizedString("plant_detail_fruiting_period", comment: ""))\(item.plantFruitingPeriod)".styled(with: .font(R.font.oppoSansR(size: 12)!)))
            }
            
            label1.attributedText = result.styled(with: .lineSpacing(10), .alignment(.center))
        }
    }
}
