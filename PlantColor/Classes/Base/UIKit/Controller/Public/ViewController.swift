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

        print("\(type(of: self)): Deinited")
    }

    // MARK: - didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        print("\(type(of: self)): Received Memory Warning")
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
}
