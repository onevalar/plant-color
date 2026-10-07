//
//  LoadingViewController.swift
//  PlantColor
//
//  Created by insect on 2022/2/9.
//

import UIKit

class LoadingViewController: ViewController {

    override func makeUI() {
        super.makeUI()

        view.showLoadingHUD(NSLocalizedString("loading_updating_data", comment: ""))

        ColorImporter.run {
            UIApplication.keyWindow?.rootViewController = NavigationController(rootViewController: HomeViewController())
            DeepLinkRouter.shared.flushPending()
        }
    }
}
