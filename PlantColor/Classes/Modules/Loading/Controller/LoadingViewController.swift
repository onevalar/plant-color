//
//  LoadingViewController.swift
//  PlantColor
//
//  Created by insect on 2022/2/9.
//

import CleanJSON
import DefaultsKit
import UIKit
import RealmSwift

class LoadingViewController: ViewController {

    override func makeUI() {
        super.makeUI()

        view.showLoadingHUD(NSLocalizedString("loading_updating_data", comment: ""))

        let plantItems: [ColorModel] = ColorProvider.fetchColors()
        let traditionalItems: [TraditionalColorModel] = TraditionalColorProvider.fetchColors()

        DispatchQueue.global(qos: .userInitiated).async {
            // Load plant colors
            for item in plantItems {
                let object = try? ColorModel.re.objects().where {
                    $0.id == item.id
                }
                item.isCollect = object?.first?.isCollect ?? false
                item.re.add(update: .all)
            }

            // Load traditional colors
            for item in traditionalItems {
                let object = try? TraditionalColorModel.re.objects().where {
                    $0.id == item.id
                }
                item.isCollect = object?.first?.isCollect ?? false
                item.re.add(update: .all)
            }

            DispatchQueue.main.async {
                Defaults().set(UIApplication.buildNumber ?? "", for: AppKey.buildNumberKey)
                UIApplication.keyWindow?.rootViewController = NavigationController(rootViewController: HomeViewController())
            }
        }
    }
}
