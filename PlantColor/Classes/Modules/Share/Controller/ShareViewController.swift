//
//  ShareViewController.swift
//  PlantColor
//
//  Created by QY on 2022/5/7.
//

import UIKit
import EachNavigationBar
import SnapKit
import Photos

class ShareViewController: ViewController {

    let colorModel: ColorModel

    init(colorModel: ColorModel) {
        self.colorModel = colorModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var editItems: [ShareEditModel] = ShareViewModel.editItems()
    
    private lazy var editView: ShareEditPageView = {
        let editView = ShareEditPageView(colorModel: colorModel,
                                         items: editItems)
        editView.didSelectEditType = { [weak self] in
            self?.preview.items = $0
            self?.screenshotView.items = $0
        }
        return editView
    }()
    
    private lazy var operationView: ShareOperationView = {
        guard let operationView = R.nib.shareOperationView.firstView(owner: nil) else {
            fatalError("Failed to load ShareOperationView from nib")
        }
        operationView.shareDidClick = { [weak self] in
            self?.shareDidClick()
        }
        
        operationView.saveDidClick = { [weak self] in
            self?.saveDidClick()
        }
        return operationView
    }()
    
    private lazy var preview: SharePreview = {
        let preview = SharePreview(colorModel: colorModel,
                                   items: editItems,
                                   isScreenshot: false)
        return preview
    }()
    
    private lazy var screenshotView: SharePreview = {
        let screenshotView = SharePreview(colorModel: colorModel,
                                          items: editItems,
                                          isScreenshot: true)
        return screenshotView
    }()

    override func makeUI() {
        super.makeUI()
        view.backgroundColor = .white
        view.addSubview(editView)
        view.addSubview(preview)
        view.addSubview(operationView)
        view.addSubview(screenshotView)
        setUpNav()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preview.snp.makeConstraints {
            $0.top.equalTo(navigation.bar.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(editView.snp.top)
        }
        
        editView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(self.operationView.snp.top).offset(-10)
            $0.height.equalTo(ShareEditPageView.height)
        }
        
        operationView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-CGFloat.safeAreaBottom)
            $0.height.equalTo(ShareOperationView.height)
        }
        
        screenshotView.snp.makeConstraints {
            $0.width.height.left.right.equalToSuperview()
            $0.top.equalTo(view.snp.bottom).offset(CGFloat.screenWidth)
        }
    }

    private func setUpNav() {

        navigation.bar.backgroundColor = .main
        navigation.item.title = NSLocalizedString("share_title", comment: "")
    }
    
    private func shareDidClick() {
        
        guard let image = screenshotView.containerView?.asImage() else { return }
        let vc = UIActivityViewController(activityItems: [image],
                                          applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    private func saveDidClick() {
        guard let image = screenshotView.containerView?.asImage() else { return }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    if let self = self {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                case .denied, .restricted:
                    self?.view.showErrorHUD(NSLocalizedString("permission_photo_denied", comment: ""))
                case .notDetermined:
                    self?.view.showErrorHUD(NSLocalizedString("permission_undetermined", comment: ""))
                @unknown default:
                    self?.view.showErrorHUD(NSLocalizedString("permission_unknown", comment: ""))
                }
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            view.showErrorHUD(String(format: NSLocalizedString("share_save_error", comment: ""), error.localizedDescription))
        } else {
            view.showSuccessHUD(NSLocalizedString("share_save_success_detail", comment: ""))
        }
    }
}
