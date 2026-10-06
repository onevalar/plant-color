//
//  UIViewControllerAlert.swift
//  PlantColor
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func showAlertMessage(_ message: String) {

        let alert = UIAlertController(title: NSLocalizedString("alert_title", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""), style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    public func showAlertMessage(_ message: String, completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: NSLocalizedString("alert_title", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""), style: .cancel) { [weak self] _ in
            completion?()
            self?.dismiss(animated: true,
                          completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    public func showAlertConfirm(_ message: String, completion: ((Int) -> Void)? = nil) {

        let alert = UIAlertController(title: NSLocalizedString("alert_title", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .cancel) { _ in
            completion?(0)
        }
        let confirm = UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""), style: .destructive) { _ in
            completion?(1)
        }
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }

    public func showAlertConfirm(_ message: String, completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: NSLocalizedString("alert_title", comment: ""),
                                      message: message,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .cancel)
        let confirm = UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""), style: .destructive) { _ in
            completion?()
        }
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    public func showWidgetScriptField(title: String? = nil,
                                      message: String? = nil,
                                      textFieldConfig: ((UITextField) -> Void)? = nil,
                                      confirm:((String) -> Void)?, clean: (() -> Void)?) {

        let alertController = UIAlertController(title:title,
                                               message:message,
                                               preferredStyle: .alert)

        alertController.addTextField(configurationHandler: textFieldConfig)

        let confirmAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""),
                                         style: .default) { [weak self] _ in

           guard let text = alertController.textFields?.first?.text,
                 !text.isEmpty
           else {
               self?.view.showErrorHUD(NSLocalizedString("alert_input_empty", comment: ""))
               return
           }
           confirm?(text)
        }

        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""),
                                        style: .default)
        alertController.addAction(cancelAction)
        let cleanAction = UIAlertAction(title: NSLocalizedString("common_clear", comment: ""),
                                         style: .default) { _ in
            clean?()
        }
        alertController.addAction(cleanAction)
        present(alertController,
               animated: true,
               completion: nil)
   }


    // MARK: - 显示带一个 textField 的 UIAlertController
    public func showAlertTextField(title: String? = nil,
                                   message: String? = nil,
                                   textFieldConfig: ((UITextField) -> Void)? = nil,
                                   confirm:((String) -> Void)?) {

        let alertController = UIAlertController(title:title,
                                                message:message,
                                                preferredStyle: .alert)

        alertController.addTextField(configurationHandler: textFieldConfig)

        let confirmAction = UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""),
                                          style: .default) { [weak self] _ in

            guard let text = alertController.textFields?.first?.text,
                  !text.isEmpty
            else {
                self?.view.showErrorHUD(NSLocalizedString("alert_input_empty", comment: ""))
                return
            }
            confirm?(text)
        }

        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""),
                                         style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController,
                animated: true,
                completion: nil)
    }

}
