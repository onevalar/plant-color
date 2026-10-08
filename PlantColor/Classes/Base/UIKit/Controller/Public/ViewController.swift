//
//  BaseViewController.swift
//  Mobilephone
//
//  Created by Mobilephone on 2021/7/5.
//

import UIKit
import SFSafeSymbols

class ViewController: UIViewController {

    // MARK: - LifeCycle
    override func viewDidLoad() {

        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        makeUI()
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    // MARK: - override
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    // MARK: - deinit
    deinit {

        AppLogger.shared.debug("\(type(of: self)): Deinited")
    }

    // MARK: - didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        AppLogger.shared.warning("\(type(of: self)): Received Memory Warning")
    }

    // MARK: - init
    func makeUI() {
        view.backgroundColor = .systemBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addCloseButtonIfNeeded()
    }

    /// 作为弹出页的第一页（没有返回按钮）时，补一个"关闭"，保证任何页面都能退出。
    /// 页面自己已经设置了左右按钮（如"完成"）就不再添加。
    private func addCloseButtonIfNeeded() {
        guard let navigationController,
              navigationController.viewControllers.first === self,
              navigationController.presentingViewController != nil,
              navigationItem.leftBarButtonItem == nil,
              (navigationItem.rightBarButtonItems ?? []).isEmpty else { return }
        let close = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        })
        close.accessibilityLabel = NSLocalizedString("common_close", comment: "")
        navigationItem.rightBarButtonItem = close
    }

    @objc func rightBarButtonItemDidClick() {
        dismiss(animated: true)
    }
}
