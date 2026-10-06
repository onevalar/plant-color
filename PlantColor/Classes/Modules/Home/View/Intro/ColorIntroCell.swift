//
//  ColorIntroCell.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit

class ColorIntroCell: UICollectionViewCell {

    @IBOutlet private weak var imageLeadingConstraint: NSLayoutConstraint! {
        didSet {
            imageLeadingConstraint.constant = -CGFloat.screenWidth * 0.5
        }
    }
    @IBOutlet private weak var detailTextView: UITextView! {
        didSet {
            detailTextView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                       action: #selector(detailButtonDidClick)))
        }
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.fzktjwgb10(size: 46)
        }
    }
    @IBOutlet private weak var colorMenu: ColorMenu! 
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint! {
        didSet {
            titleTopConstraint.constant = .safeAreaTop + 70
        }
    }
    
    @IBOutlet private weak var menuBottomConstraint: NSLayoutConstraint! {
        didSet {
            menuBottomConstraint.constant = .safeAreaBottom + 20
        }
    }
    
    @IBOutlet private weak var detailButton: UIButton!
    
    public var item: (any ColorDisplayable)? {
        didSet {

            guard let item = item else { return }
            if item.imageName.isEmpty {
                imageView.image = nil
                imageView.isHidden = true
            } else {
                imageView.image = UIImage(named: item.imageName)
                imageView.isHidden = false
            }
            detailButton.setImage(UIImage.sf(systemSymbol: .book).withTintColor(item.textUIColor),
                                  for: .normal)
            titleLabel.text = item.displayName
            titleLabel.textColor = item.textUIColor
            detailTextView.attributedText = item.displayAbstract
            detailTextView.textColor = item.textUIColor
            colorMenu.displayItem = item
        }
    }

    @IBAction private func detailButtonDidClick() {

        guard let item = item else { return }
        Feedback.lightPrepare()
        let vc = NavigationController(rootViewController: item.makeDetailViewController())
        parentVC?.present(vc, animated: true, completion: nil)
    }
}
