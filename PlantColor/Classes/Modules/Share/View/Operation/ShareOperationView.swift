//
//  ShareOperationView.swift
//  PlantColor
//
//  Created by insect on 2022/5/9.
//

import UIKit

class ShareOperationView: UIView {

    static let height = 44
    
    var shareDidClick: (() -> Void)?
    
    var saveDidClick: (() -> Void)?
    
    @IBOutlet private weak var shareButton: UIButton! {
        didSet {
            shareButton.cornerRadius = 5
        }
    }
    @IBOutlet private weak var saveButton: UIButton! {
        didSet {
            saveButton.cornerRadius = 5
        }
    }
    
    @IBAction private func shareButtonDidClick() {
        shareDidClick?()
    }
    
    @IBAction private func saveButtonDidClick() {
        saveDidClick?()
    }
}
