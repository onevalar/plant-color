import UIKit
import EachNavigationBar
import Photos

final class ShareViewController: ViewController {
    let colorModel: any ColorDisplayable
    private(set) lazy var card = PlantShareCardView(item: colorModel)
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let valuesSwitch = UISwitch()
    private var styleButtons: [UIButton] = []
    private let shareButton = UIButton(type: .system)

    convenience init(item: any ColorDisplayable) { self.init(colorModel: item) }

    init(colorModel: any ColorDisplayable) {
        self.colorModel = colorModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }

    override func makeUI() {
        super.makeUI()
        view.backgroundColor = .main
        navigation.bar.backgroundColor = .main
        navigation.bar.tintColor = .settingsAccent
        navigation.item.largeTitleDisplayMode = .never
        navigation.item.title = String(format: NSLocalizedString("share_color_title", comment: ""), colorModel.displayName)
        navigation.item.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("common_done", comment: ""), style: .plain,
            target: self, action: #selector(finish))

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 18
        scrollView.addSubview(stack)
        let preferredWidth = stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigation.bar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 440), preferredWidth
        ])
        addPreview()
        addStyleControls()
        addValuesControl()
        configureButton(shareButton, title: NSLocalizedString("share_system_action", comment: ""), symbol: "square.and.arrow.up", primary: true)
        shareButton.addTarget(self, action: #selector(shareDidClick), for: .touchUpInside)
        stack.addArrangedSubview(shareButton)
        let saveButton = UIButton(type: .system)
        configureButton(saveButton, title: NSLocalizedString("share_save_action", comment: ""), symbol: "square.and.arrow.down", primary: false)
        saveButton.addTarget(self, action: #selector(saveDidClick), for: .touchUpInside)
        stack.addArrangedSubview(saveButton)
        stack.setCustomSpacing(6, after: shareButton)
        refreshStyleButtons()
    }

    private func addPreview() {
        let wrapper = UIView()
        let shadow = UIView()
        shadow.translatesAutoresizingMaskIntoConstraints = false
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.09
        shadow.layer.shadowRadius = 16
        shadow.layer.shadowOffset = CGSize(width: 0, height: 8)
        wrapper.addSubview(shadow)
        card.translatesAutoresizingMaskIntoConstraints = false
        shadow.addSubview(card)
        NSLayoutConstraint.activate([
            shadow.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10),
            shadow.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -10),
            shadow.topAnchor.constraint(equalTo: wrapper.topAnchor),
            shadow.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            shadow.heightAnchor.constraint(equalTo: shadow.widthAnchor, multiplier: 426.0 / 322.0),
            card.leadingAnchor.constraint(equalTo: shadow.leadingAnchor), card.trailingAnchor.constraint(equalTo: shadow.trailingAnchor),
            card.topAnchor.constraint(equalTo: shadow.topAnchor), card.bottomAnchor.constraint(equalTo: shadow.bottomAnchor)
        ])
        stack.addArrangedSubview(wrapper)
    }

    private func addStyleControls() {
        let row = UIStackView()
        row.spacing = 6
        row.distribution = .fillEqually
        for style in PlantShareStyle.allCases {
            let button = UIButton(type: .system)
            button.tag = style.rawValue
            button.accessibilityIdentifier = "share.style.\(style.rawValue)"
            button.addTarget(self, action: #selector(selectStyle(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            styleButtons.append(button)
            row.addArrangedSubview(button)
        }
        stack.addArrangedSubview(row)
    }

    private func addValuesControl() {
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
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        stack.addArrangedSubview(row)
    }

    private func configureButton(_ button: UIButton, title: String, symbol: String, primary: Bool) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: symbol)
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = primary ? .settingsAccent : .secondarySystemGroupedBackground
        config.baseForegroundColor = primary ? .systemBackground : .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        button.configuration = config
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: primary ? 48 : 44).isActive = true
    }

    private func refreshStyleButtons() {
        for button in styleButtons {
            guard let style = PlantShareStyle(rawValue: button.tag) else { continue }
            let selected = card.style == style
            var config = UIButton.Configuration.plain()
            config.title = style.title
            config.baseForegroundColor = .label
            config.background.backgroundColor = selected ? .secondarySystemGroupedBackground : .clear
            config.background.strokeColor = selected ? .separator : .clear
            config.background.strokeWidth = selected ? 0.5 : 0
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 6, bottom: 10, trailing: 6)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var result = attributes
                result.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 13, weight: .medium))
                return result
            }
            button.configuration = config
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.accessibilityTraits = selected ? [.button, .selected] : .button
        }
    }

    @objc private func selectStyle(_ sender: UIButton) {
        guard let style = PlantShareStyle(rawValue: sender.tag) else { return }
        card.style = style
        refreshStyleButtons()
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
