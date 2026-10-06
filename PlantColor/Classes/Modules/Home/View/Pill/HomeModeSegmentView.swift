//
//  HomeModeSegmentView.swift
//  PlantColor
//
//  Created by PlantColor on 2024/01/01.
//

import UIKit

enum HomeColorMode: Int {
    case botanical = 0
    case traditional = 1
}

class HomeModeSegmentView: UIView {

    var modeDidChange: ((HomeColorMode) -> Void)?

    private var currentMode: HomeColorMode = .botanical

    private let glassBackground = GlassEffectView()

    private lazy var botanicalButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("home_mode_plant", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.tag = HomeColorMode.botanical.rawValue
        btn.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        return btn
    }()

    private lazy var traditionalButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("home_mode_traditional", comment: ""), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.tag = HomeColorMode.traditional.rawValue
        btn.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        return btn
    }()

    private let indicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        v.layer.cornerRadius = 15
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        glassBackground.cornerRadius = 20
        glassBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glassBackground)

        indicator.translatesAutoresizingMaskIntoConstraints = false
        glassBackground.addSubview(indicator)

        let stack = UIStackView(arrangedSubviews: [botanicalButton, traditionalButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        glassBackground.addSubview(stack)

        NSLayoutConstraint.activate([
            glassBackground.topAnchor.constraint(equalTo: topAnchor),
            glassBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassBackground.bottomAnchor.constraint(equalTo: bottomAnchor),

            stack.topAnchor.constraint(equalTo: glassBackground.topAnchor),
            stack.leadingAnchor.constraint(equalTo: glassBackground.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: glassBackground.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: glassBackground.bottomAnchor),

            indicator.topAnchor.constraint(equalTo: glassBackground.topAnchor, constant: 5),
            indicator.bottomAnchor.constraint(equalTo: glassBackground.bottomAnchor, constant: -5),
            indicator.widthAnchor.constraint(equalTo: glassBackground.widthAnchor, multiplier: 0.5, constant: -6),
        ])

        indicatorLeading = indicator.leadingAnchor.constraint(equalTo: glassBackground.leadingAnchor, constant: 3)
        indicatorLeading?.isActive = true

        updateAppearance(animated: false)
    }

    private var indicatorLeading: NSLayoutConstraint?

    @objc private func segmentTapped(_ sender: UIButton) {
        guard let mode = HomeColorMode(rawValue: sender.tag),
              mode != currentMode else { return }
        Feedback.lightPrepare()
        currentMode = mode
        updateAppearance(animated: true)
        modeDidChange?(mode)
    }

    private func updateAppearance(animated: Bool) {
        let isTraditional = currentMode == .traditional
        let offset: CGFloat = isTraditional ? bounds.width / 2 + 3 : 3

        let update = {
            self.indicatorLeading?.constant = offset
            self.layoutIfNeeded()
            self.botanicalButton.alpha = isTraditional ? 0.5 : 1.0
            self.traditionalButton.alpha = isTraditional ? 1.0 : 0.5
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: update)
        } else {
            update()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Recalculate indicator position after layout
        updateAppearance(animated: false)
    }

    func updateTextColor(_ color: UIColor) {
        botanicalButton.setTitleColor(color, for: .normal)
        traditionalButton.setTitleColor(color, for: .normal)
    }
}
