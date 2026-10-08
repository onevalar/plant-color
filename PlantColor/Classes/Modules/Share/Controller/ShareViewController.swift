import UIKit
import Photos

/// 分享色卡：预览居中 + 底部玻璃控制面板（样式 / 比例 / 方向 / 色值），横屏时面板移到右侧。
final class ShareViewController: ViewController {
    let colorModel: any ColorDisplayable
    private(set) lazy var card = PlantShareCardView(item: colorModel)

    private let previewArea = UILayoutGuide()
    private let tray = GlassEffectView()
    private let trayScroll = UIScrollView()
    private let trayStack = UIStackView()
    private let styleControl = UISegmentedControl()
    private let ratioControl = UISegmentedControl()
    private let orientationControl = UISegmentedControl()
    private let valuesSwitch = UISwitch()
    private let shareButton = UIButton(type: .system)

    private var aspectConstraint: NSLayoutConstraint?
    private var portraitLayout: [NSLayoutConstraint] = []
    private var landscapeLayout: [NSLayoutConstraint] = []
    private var isWideLayout: Bool?

    convenience init(item: any ColorDisplayable) { self.init(colorModel: item) }

    init(colorModel: any ColorDisplayable) {
        self.colorModel = colorModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }

    override func makeUI() {
        super.makeUI()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = String(format: NSLocalizedString("share_color_title", comment: ""), colorModel.displayName)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("common_done", comment: ""), style: .plain,
            target: self, action: #selector(finish))

        view.addLayoutGuide(previewArea)
        addPreview()
        addTray()
        buildLayoutSets()
        applyCanvas(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let wide = view.bounds.width > view.bounds.height * 1.15
        guard wide != isWideLayout else { return }
        isWideLayout = wide
        NSLayoutConstraint.deactivate(wide ? portraitLayout : landscapeLayout)
        NSLayoutConstraint.activate(wide ? landscapeLayout : portraitLayout)
    }

    // MARK: - 预览

    private func addPreview() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 10
        // 阴影放在外层，圆角裁剪不会把阴影切掉
        let shadow = UIView()
        shadow.translatesAutoresizingMaskIntoConstraints = false
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.14
        shadow.layer.shadowRadius = 18
        shadow.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.addSubview(shadow)
        shadow.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: shadow.topAnchor), card.bottomAnchor.constraint(equalTo: shadow.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: shadow.leadingAnchor), card.trailingAnchor.constraint(equalTo: shadow.trailingAnchor),
            shadow.centerXAnchor.constraint(equalTo: previewArea.centerXAnchor),
            shadow.centerYAnchor.constraint(equalTo: previewArea.centerYAnchor),
            shadow.widthAnchor.constraint(lessThanOrEqualTo: previewArea.widthAnchor),
            shadow.heightAnchor.constraint(lessThanOrEqualTo: previewArea.heightAnchor),
        ])
        // 尽量撑满预览区；比例由 aspectConstraint 固定，所以最终是"完整放进去的最大尺寸"
        let fillWidth = shadow.widthAnchor.constraint(equalTo: previewArea.widthAnchor)
        fillWidth.priority = .defaultHigh
        let fillHeight = shadow.heightAnchor.constraint(equalTo: previewArea.heightAnchor)
        fillHeight.priority = UILayoutPriority(749)
        NSLayoutConstraint.activate([fillWidth, fillHeight])
        previewHolder = shadow
    }

    private var previewHolder: UIView?

    /// 比例或方向变化后，更新预览的宽高比
    private func applyCanvas(animated: Bool) {
        guard let holder = previewHolder else { return }
        let size = card.canvasSize
        aspectConstraint?.isActive = false
        let constraint = holder.widthAnchor.constraint(equalTo: holder.heightAnchor, multiplier: size.width / size.height)
        constraint.isActive = true
        aspectConstraint = constraint
        card.setNeedsDisplay()
        guard animated, !UIAccessibility.isReduceMotionEnabled else { return }
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: - 控制面板

    private func addTray() {
        tray.cornerRadius = 28
        tray.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tray)

        trayScroll.translatesAutoresizingMaskIntoConstraints = false
        trayScroll.alwaysBounceVertical = false
        tray.addSubview(trayScroll)

        trayStack.axis = .vertical
        trayStack.spacing = 14
        trayStack.translatesAutoresizingMaskIntoConstraints = false
        trayScroll.addSubview(trayStack)

        configure(styleControl, titles: PlantShareStyle.allCases.map(\.title), id: "share.style", selected: card.style.rawValue,
                  action: #selector(styleChanged))
        configure(ratioControl, titles: PlantShareRatio.allCases.map(\.title), id: "share.ratio", selected: card.ratio.rawValue,
                  action: #selector(ratioChanged))
        configure(orientationControl,
                  titles: [NSLocalizedString("share_edit_portrait", comment: ""), NSLocalizedString("share_edit_landscape", comment: "")],
                  id: "share.orientation", selected: card.orientation.rawValue, action: #selector(orientationChanged))

        trayStack.addArrangedSubview(row(caption: "share_style", control: styleControl))
        trayStack.addArrangedSubview(row(caption: "share_ratio", control: ratioControl))
        trayStack.addArrangedSubview(row(caption: "share_orientation", control: orientationControl))
        trayStack.addArrangedSubview(valuesRow())

        configureButton(shareButton, title: NSLocalizedString("share_system_action", comment: ""), symbol: "square.and.arrow.up", primary: true)
        shareButton.addTarget(self, action: #selector(shareDidClick), for: .touchUpInside)
        let saveButton = UIButton(type: .system)
        configureButton(saveButton, title: NSLocalizedString("share_save_action", comment: ""), symbol: "square.and.arrow.down", primary: false)
        saveButton.addTarget(self, action: #selector(saveDidClick), for: .touchUpInside)
        let actions = UIStackView(arrangedSubviews: [saveButton, shareButton])
        actions.spacing = 10
        actions.distribution = .fillEqually
        trayStack.addArrangedSubview(actions)

        let contentHeight = trayScroll.heightAnchor.constraint(equalTo: trayStack.heightAnchor, constant: 32)
        contentHeight.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            trayScroll.topAnchor.constraint(equalTo: tray.topAnchor), trayScroll.bottomAnchor.constraint(equalTo: tray.bottomAnchor),
            trayScroll.leadingAnchor.constraint(equalTo: tray.leadingAnchor), trayScroll.trailingAnchor.constraint(equalTo: tray.trailingAnchor),
            trayStack.topAnchor.constraint(equalTo: trayScroll.contentLayoutGuide.topAnchor, constant: 16),
            trayStack.bottomAnchor.constraint(equalTo: trayScroll.contentLayoutGuide.bottomAnchor, constant: -16),
            trayStack.leadingAnchor.constraint(equalTo: trayScroll.frameLayoutGuide.leadingAnchor, constant: 18),
            trayStack.trailingAnchor.constraint(equalTo: trayScroll.frameLayoutGuide.trailingAnchor, constant: -18),
            contentHeight,
        ])
    }

    private func configure(_ control: UISegmentedControl, titles: [String], id: String, selected: Int, action: Selector) {
        control.removeAllSegments()
        for (index, title) in titles.enumerated() { control.insertSegment(withTitle: title, at: index, animated: false) }
        control.selectedSegmentIndex = selected
        control.accessibilityIdentifier = id
        control.addTarget(self, action: action, for: .valueChanged)
        control.heightAnchor.constraint(greaterThanOrEqualToConstant: DS.minTap - 4).isActive = true
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        control.setTitleTextAttributes([.font: font], for: .normal)
        control.setTitleTextAttributes([.font: font], for: .selected)
    }

    private func row(caption key: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = NSLocalizedString(key, comment: "")
        label.font = .preferredFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.isAccessibilityElement = false
        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func valuesRow() -> UIView {
        let label = UILabel()
        label.text = NSLocalizedString("share_show_values", comment: "")
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.isAccessibilityElement = false
        valuesSwitch.isOn = card.showsValues
        valuesSwitch.onTintColor = .settingsAccent
        valuesSwitch.accessibilityLabel = label.text
        valuesSwitch.accessibilityIdentifier = "share.showValues"
        valuesSwitch.addTarget(self, action: #selector(valuesChanged), for: .valueChanged)
        let row = UIStackView(arrangedSubviews: [label, valuesSwitch])
        row.alignment = .center
        row.spacing = 12
        return row
    }

    private func configureButton(_ button: UIButton, title: String, symbol: String, primary: Bool) {
        var config = primary ? UIButton.Configuration.filled() : UIButton.Configuration.tinted()
        config.title = title
        config.image = UIImage(systemName: symbol)
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .settingsAccent
        config.baseForegroundColor = primary ? .systemBackground : .settingsAccent
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        button.configuration = config
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }

    /// 竖屏：面板在底部；横屏（宽屏）：面板在右侧，预览在左侧
    private func buildLayoutSets() {
        let safe = view.safeAreaLayoutGuide
        let top = safe.topAnchor
        let maxTrayHeight = tray.heightAnchor.constraint(lessThanOrEqualTo: safe.heightAnchor, multiplier: 0.58)
        portraitLayout = [
            tray.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            tray.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            tray.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8),
            maxTrayHeight,
            previewArea.topAnchor.constraint(equalTo: top, constant: 8),
            previewArea.bottomAnchor.constraint(equalTo: tray.topAnchor, constant: -14),
            previewArea.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 28),
            previewArea.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -28),
        ]
        landscapeLayout = [
            tray.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            tray.topAnchor.constraint(equalTo: top, constant: 8),
            tray.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8),
            tray.widthAnchor.constraint(equalToConstant: 320),
            previewArea.topAnchor.constraint(equalTo: top, constant: 8),
            previewArea.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -8),
            previewArea.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            previewArea.trailingAnchor.constraint(equalTo: tray.leadingAnchor, constant: -16),
        ]
    }

    // MARK: - 操作

    @objc private func styleChanged() {
        card.style = PlantShareStyle(rawValue: styleControl.selectedSegmentIndex) ?? .original
    }

    @objc private func ratioChanged() {
        card.ratio = PlantShareRatio(rawValue: ratioControl.selectedSegmentIndex) ?? .standard
        applyCanvas(animated: true)
    }

    @objc private func orientationChanged() {
        card.orientation = PlantShareOrientation(rawValue: orientationControl.selectedSegmentIndex) ?? .portrait
        applyCanvas(animated: true)
    }

    @objc private func valuesChanged() { card.showsValues = valuesSwitch.isOn }

    @objc private func finish() {
        if navigationController?.viewControllers.first !== self {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// iPad requires an anchored popover; creating this controller does not share or save anything.
    func makeActivityController() -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [card.exportImage()], applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = shareButton
        controller.popoverPresentationController?.sourceRect = shareButton.bounds
        return controller
    }

    @objc private func shareDidClick() { present(makeActivityController(), animated: true) }

    @objc private func saveDidClick() {
        let image = card.exportImage()
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                case .denied, .restricted:
                    self.view.showErrorHUD(NSLocalizedString("permission_photo_denied", comment: ""))
                case .notDetermined:
                    self.view.showErrorHUD(NSLocalizedString("permission_undetermined", comment: ""))
                @unknown default:
                    self.view.showErrorHUD(NSLocalizedString("permission_unknown", comment: ""))
                }
            }
        }
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            view.showErrorHUD(String(format: NSLocalizedString("share_save_error", comment: ""), error.localizedDescription))
        } else {
            view.showSuccessHUD(NSLocalizedString("share_save_success_detail", comment: ""))
        }
    }
}
