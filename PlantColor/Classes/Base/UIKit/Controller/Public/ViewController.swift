//
//  BaseViewController.swift
//  Mobilephone
//
//  Created by Mobilephone on 2021/7/5.
//

import UIKit
import EachNavigationBar
import SFSafeSymbols

class ViewController: UIViewController {

    // MARK: - LifeCycle
    override func viewDidLoad() {

        super.viewDidLoad()
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

        view.backgroundColor = .white
        
        navigation.item.rightBarButtonItem = UIBarButtonItem(image: .sf(systemSymbol: .multiply),
                                                             style: .plain,
                                                             target: self,
                                                             action: #selector(rightBarButtonItemDidClick))
    }
    
    @objc func rightBarButtonItemDidClick() {
        dismiss(animated: true)
    }

    /// Opt-in compatibility for auxiliary screens using the legacy per-screen bar.
    /// Expose real controls instead of the hidden system navigation bar on iOS 26.
    func exposeAuxiliaryNavigationControls() {
        guard let navigationController, navigationController.viewControllers.first !== self else { return }
        let back = UIButton(type: .system)
        back.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        back.accessibilityLabel = NSLocalizedString("common_back", comment: "")
        back.frame.size = CGSize(width: 44, height: 44)
        navigation.bar.backBarButtonItem = BackBarButtonItem(style: .custom(back), tintColor: navigation.bar.tintColor)
        let actions = navigation.item.rightBarButtonItems?.compactMap(\.customView) ?? []
        view.accessibilityElements = [back] + actions + view.subviews.filter { $0 !== navigation.bar }
    }
}
