import SwiftUI
import UIKit

/// Uses the extension's real layout and data without advancing its rotation index.
final class WidgetPreviewHeader: UIView {
    let controller = UIHostingController(rootView: PlantWidgetView(plant: PlantViewModel.placeholderModel(), previewMode: .original))
    private let stack = UIStackView()
    private let modes = UISegmentedControl(items: [NSLocalizedString("widget_preview_original", comment: ""),
                                                  NSLocalizedString("widget_preview_tinted", comment: "")])
    private var previewMode: PlantWidgetView.PreviewMode = .original
    private(set) var model = PlantViewModel.placeholderModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        let title = label("widget_preview_title", style: .title2, size: 25)
        if let serif = UIFont.systemFont(ofSize: 25).fontDescriptor.withDesign(.serif) {
            title.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont(descriptor: serif, size: 25))
        }
        stack.addArrangedSubview(title)
        let subtitle = label("widget_preview_subtitle", style: .subheadline, size: 13)
        subtitle.textColor = .secondaryLabel
        stack.addArrangedSubview(subtitle)
        stack.setCustomSpacing(20, after: subtitle)
        controller.view.backgroundColor = .clear
        controller.view.layer.cornerRadius = 26
        controller.view.clipsToBounds = true
        stack.addArrangedSubview(controller.view)
        controller.view.heightAnchor.constraint(equalToConstant: 170).isActive = true
        modes.selectedSegmentIndex = 0
        modes.selectedSegmentTintColor = .tertiarySystemBackground
        modes.addTarget(self, action: #selector(changeMode), for: .valueChanged)
        modes.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        stack.addArrangedSubview(modes)
        let hint = label("widget_preview_hint", style: .footnote, size: 13)
        hint.textColor = .secondaryLabel
        stack.addArrangedSubview(hint)
        updatePreview()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updatePreview() {
        model = PlantViewModel.placeholderModel()
        // The extension owns the original widget illustrations; use its bundled assets directly.
        let extensionBundle = Bundle.main.builtInPlugInsURL.flatMap { root in
            (try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: nil))?
                .first { $0.pathExtension == "appex" && $0.lastPathComponent.hasPrefix("PlantWidget") }
                .flatMap(Bundle.init(url:))
        }
        controller.rootView = PlantWidgetView(plant: model, previewMode: previewMode, imageBundle: extensionBundle ?? .main)
        controller.view.accessibilityLabel = String(format: NSLocalizedString("widget_preview_accessibility", comment: ""), model.name)
    }

    @objc private func changeMode() {
        previewMode = modes.selectedSegmentIndex == 0 ? .original : .tinted
        updatePreview()
    }

    private func label(_ key: String, style: UIFont.TextStyle, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedString(key, comment: "")
        label.font = UIFontMetrics(forTextStyle: style).scaledFont(for: .systemFont(ofSize: size))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }
}
