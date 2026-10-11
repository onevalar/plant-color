//
//  GlassEffectView.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit

/// A view that provides a glass/blur background effect.
/// Uses the system material, or an opaque system surface when transparency is reduced.
class GlassEffectView: UIView {

    /// Botanical surface also used when Reduce Transparency is enabled.
    var botanicalSurface: UIColor? { didSet { updateAccessibilityAppearance() } }

    override var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
            effectView.layer.cornerRadius = newValue
            effectView.layer.masksToBounds = true
        }
    }

    private lazy var effectView: UIVisualEffectView = {
        let effect: UIVisualEffect
        if #available(iOS 26.0, *) {
            effect = UIGlassEffect(style: .regular)
        } else {
            effect = UIBlurEffect(style: .systemUltraThinMaterial)
        }
        let view = UIVisualEffectView(effect: effect)
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEffect()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEffect()
    }

    private func setupEffect() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(accessibilityAppearanceChanged),
                                               name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)
        updateAccessibilityAppearance()
    }

    @objc private func accessibilityAppearanceChanged() { updateAccessibilityAppearance() }

    func updateAccessibilityAppearance(reduceTransparency: Bool = UIAccessibility.isReduceTransparencyEnabled) {
        effectView.isHidden = reduceTransparency
        isOpaque = reduceTransparency
        backgroundColor = botanicalSurface ?? (reduceTransparency ? .secondarySystemBackground : .clear)
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}
