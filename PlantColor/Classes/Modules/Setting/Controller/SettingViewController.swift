//
//  SettingViewController.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import UIColor_Hex_Swift
import UIKit
import Hero

class SettingViewController: TableViewController {
    
    enum Page { case root, automaticSwitch, widget }
    private let page: Page
    private var widgetPreview: WidgetPreviewHeader?

    init(page: Page = .root) {
        self.page = page
        super.init(style: .insetGrouped)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpBaseDate()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var items: [[SetModel]] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    private var settingConfig: SettingConfig?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hero.navigationAnimationType = .auto
    }
    
    override func makeUI() {
        super.makeUI()
        setUpNav()
        view.backgroundColor = .main
        tableView.backgroundColor = .main
        view.tintColor = .settingsAccent
        tableView.register(SettingCell.self, forCellReuseIdentifier: R.reuseIdentifier.settingCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        if page == .widget {
            let header = WidgetPreviewHeader()
            addChild(header.controller)
            tableView.tableHeaderView = header
            header.controller.didMove(toParent: self)
            widgetPreview = header
        }
        setUpBaseDate()
        for name in [UIApplication.didBecomeActiveNotification, UIAccessibility.reduceTransparencyStatusDidChangeNotification,
                     UIAccessibility.reduceMotionStatusDidChangeNotification, UIContentSizeCategory.didChangeNotification] {
            NotificationCenter.default.addObserver(self, selector: #selector(refreshValues), name: name, object: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = widgetPreview, tableView.bounds.width > 0 else { return }
        let width = tableView.bounds.width
        let height = header.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                    withHorizontalFittingPriority: .required,
                                                    verticalFittingPriority: .fittingSizeLevel).height
        if abs(header.frame.height - height) > 0.5 || header.frame.width != width {
            header.frame = CGRect(x: 0, y: 0, width: width, height: height)
            tableView.tableHeaderView = header
        }
    }

    @objc private func refreshValues() { setUpBaseDate() }
    @objc private func done() { dismiss(animated: !UIAccessibility.isReduceMotionEnabled) }

    private func setUpNav() {

        let titleKey = page == .root ? "setting_title" : page == .widget ? "setting_section_widget" : "setting_auto_switch"
        navigation.item.title = NSLocalizedString(titleKey, comment: "")
        if page == .root {
            navigation.item.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("common_done", comment: ""),
                                                                 style: .plain, target: self, action: #selector(done))
        }
        navigation.bar.backgroundColor = .main
        navigation.bar.tintColor = .settingsAccent
        navigation.item.rightBarButtonItem?.tintColor = .settingsAccent
    }
    
    func setUpBaseDate() {
        settingConfig = try? SettingConfig.re.objects().first
        guard let config = settingConfig else { return }
        let preferences = HomePreferences.shared
        func row(_ section: String, _ title: String, _ icon: String, _ type: SetType,
                 detail: String? = nil, toggle: Bool? = nil) -> SetModel {
            SetModel(sectionName: NSLocalizedString(section, comment: ""), imageName: icon,
                     title: NSLocalizedString(title, comment: ""), showSwitch: toggle != nil,
                     switchState: toggle ?? false, setType: type, detail: detail)
        }
        func text(_ key: String) -> String { NSLocalizedString(key, comment: "") }
        if page == .widget {
            widgetPreview?.updatePreview()
            items = [[
                row("setting_section_widget", "setting_widget_source", "sf.square.stack", .WidgetSource,
                    detail: text("widget_source_\(WidgetPlaylist.source.rawValue)")),
                row("setting_section_widget", "setting_show_figure", "sf.photo", .ShowFigure, toggle: config.showFigure),
                row("setting_section_widget", "setting_show_color_value", "sf.number", .ShowColorValue, toggle: config.showTone),
                row("setting_section_widget", "setting_custom_content", "sf.text.alignleft", .CustomContent,
                    detail: config.customContent.isEmpty ? text("setting_value_none") : config.customContent),
                row("setting_section_widget", "setting_color_refresh", "sf.arrow.clockwise", .ColorRefresh,
                    detail: text("refresh_rate_\(config.refreshRate)")),
                row("setting_section_widget", "widget_open_preview", "sf.arrow.up.forward.app", .WidgetOpenCurrent)
            ]]
            return
        }
        if page == .automaticSwitch {
            items = [[
                row("setting_section_browsing", "setting_auto_switch", "sf.arrow.triangle.2.circlepath", .AutomaticSwitch, toggle: config.automaticSwitching),
                row("setting_section_browsing", "setting_switch_interval", "sf.timer", .SwitchingInterval,
                    detail: text("switch_interval_\(config.switchingRate)")),
                row("setting_section_browsing", "setting_random_switch", "sf.shuffle", .RandomSwitching, toggle: config.randomSwitching)
            ]]
            return
        }
        let language = (UserDefaults.standard.array(forKey: "AppleLanguages") as? [String])?.first
        let languageNames = ["zh-Hans": "简体中文", "zh-Hant": "繁體中文", "en": "English", "ja": "日本語", "ko": "한국어"]
        let languageTitle = language.flatMap { code in languageNames.first { code.hasPrefix($0.key) }?.value } ?? text("setting_language_follow_system")
        items = [
            [row("setting_section_browsing", "setting_startup_display", "sf.clock.arrow.circlepath", .StartupDisplay,
                 detail: text("setting_startup_\(preferences.startup.rawValue)")),
             row("setting_section_browsing", "setting_auto_switch", "sf.arrow.triangle.2.circlepath", .AutomaticSwitchOptions,
                 detail: text(config.automaticSwitching ? "setting_value_on" : "setting_value_off")),
             row("setting_section_browsing", "setting_haptic_feedback", "sf.hand.tap", .HapticFeedback, toggle: preferences.hapticsEnabled)],
            [row("setting_section_display", "setting_appearance", "sf.circle.lefthalf.filled", .Appearance,
                 detail: text("setting_appearance_\(preferences.appearance.rawValue)")),
             row("setting_section_display", "setting_reduce_transparency", "sf.square.on.square", .ReduceTransparency,
                 detail: text("setting_language_follow_system")),
             row("setting_section_display", "setting_reduce_motion", "sf.figure.walk.motion", .ReduceMotion,
                 detail: text("setting_language_follow_system")),
             row("setting_section_display", "setting_text_size", "sf.textformat.size", .TextSize,
                 detail: text("setting_language_follow_system"))],
            [row("setting_section_my_colors", "setting_all_colors", "sf.square.grid.2x2", .AllColor),
             row("setting_section_my_colors", "setting_my_collection", "sf.heart", .MyCollection),
             row("setting_section_my_colors", "setting_scientific_management", "sf.leaf", .ScientificManagement),
             row("setting_section_my_colors", "setting_traditional_management", "sf.books.vertical", .TraditionalManagement)],
            [row("setting_section_widget", "setting_section_widget", "sf.square.stack", .WidgetOptions,
                 detail: text("widget_preview_settings"))],
            [row("setting_section_about", "setting_language", "sf.globe", .Language, detail: languageTitle),
             row("setting_section_about", "setting_about_app", "sf.info.circle", .About, detail: appVersion),
             row("setting_section_about", "setting_acknowledgement", "sf.heart.text.square", .Acknowledgement),
             row("setting_section_about", "setting_share_app", "sf.square.and.arrow.up", .ShareApplication),
             row("setting_section_about", "setting_rate_app", "sf.star", .EvaluationApplication),
             row("setting_section_about", "setting_contact_feedback", "sf.bubble.left.and.bubble.right", .ContactFeedback)]
        ]
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.section][indexPath.row]
        
        switch item.setType {

        case .AllColor:
            navigationController?.pushViewController(ColorListViewController(type: .all),
                                                     animated: true)
        case .MyCollection:
            navigationController?.pushViewController(ColorListViewController(type: .collect),
                                                     animated: true)
            
        case .ScientificManagement:
            navigationController?.pushViewController(ColorDetailManageViewController(kind: .plant),
                                                         animated: true)

        case .TraditionalManagement:
            navigationController?.pushViewController(ColorDetailManageViewController(kind: .traditional),
                                                     animated: true)

        case .SwitchingInterval:
            showSwitchIntervalPicker()

        case .WidgetSource:
            showWidgetSourcePicker()
            
        case .AutomaticSwitch: break
            
        case .RandomSwitching: break
            
        case .ShowFigure: break
            
        case .ShowColorValue: break
            
        case .CustomContent:
            Feedback.prepare()
            if let customContent = settingConfig?.customContent {
                showWidgetScriptField(title: NSLocalizedString("setting_custom_alert_title", comment: ""), message: customContent.isEmpty ? "" : String(format: NSLocalizedString("setting_custom_history", comment: ""), customContent)) { field in
                    field.placeholder = NSLocalizedString("setting_custom_placeholder", comment: "")
                } confirm: {[weak self] content in
                    if content.count > 20 {
                        self?.showAlertMessage(NSLocalizedString("setting_custom_length_error", comment: ""))
                        return
                    }
                    SettingConfig.re.transaction {[weak self] _ in
                        self?.settingConfig?.customContent = content
                        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(content, forKey: WidgetKitHelper.customContent)
                        WidgetKitHelper.reloadAllWidgets()
                    }
                    self?.refreshValues()
                } clean: {[weak self] in
                    SettingConfig.re.transaction {[weak self] _ in
                        self?.settingConfig?.customContent = ""
                        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set("", forKey: WidgetKitHelper.customContent)
                        WidgetKitHelper.reloadAllWidgets()
                    }
                    self?.refreshValues()
                }
            }

        case .ColorRefresh:
            showRefreshRatePicker()
            
        case .Acknowledgement:
            SettingViewModel.acknowledgement()
            
        case .ShareApplication:
            SettingViewModel.shareMyApp(name: NSLocalizedString("share_app_text", comment: ""))
            
        case .EvaluationApplication:
            SettingViewModel.commentMyApp()
            
        case .ContactFeedback:
            SettingViewModel.contactFeedback()

        case .Language:
            showLanguagePicker()
        case .StartupDisplay:
            showStartupPicker()
        case .AutomaticSwitchOptions:
            navigationController?.pushViewController(SettingViewController(page: .automaticSwitch), animated: !UIAccessibility.isReduceMotionEnabled)
        case .Appearance:
            showAppearancePicker()
        case .ReduceTransparency:
            showSystemPreferenceInfo("setting_reduce_transparency", message: "setting_reduce_transparency_info")
        case .ReduceMotion:
            showSystemPreferenceInfo("setting_reduce_motion", message: "setting_reduce_motion_info")
        case .TextSize:
            showSystemPreferenceInfo("setting_text_size", message: "setting_text_size_info")
        case .About:
            showSystemPreferenceInfo("setting_about_app", messageText: String(format: NSLocalizedString("setting_about_version", comment: ""), appVersion))
        case .HapticFeedback: break
        case .WidgetOptions:
            navigationController?.pushViewController(SettingViewController(page: .widget), animated: !UIAccessibility.isReduceMotionEnabled)
        case .WidgetOpenCurrent:
            guard let url = widgetPreview?.model.deepLink else {
                showAlertMessage(NSLocalizedString("widget_empty_hint", comment: ""))
                return
            }
            dismiss(animated: !UIAccessibility.isReduceMotionEnabled) { DeepLinkRouter.shared.handle(url) }
        }
        
    }
}

// MARK: - Option Pickers
extension SettingViewController {

    private func showStartupPicker() {
        let options = [HomePreferences.Startup.last, .first].map {
            OptionListViewController.Option(key: $0.rawValue, title: NSLocalizedString("setting_startup_\($0.rawValue)", comment: ""))
        }
        let vc = OptionListViewController(title: NSLocalizedString("setting_startup_display", comment: ""), options: options,
                                          selectedKey: HomePreferences.shared.startup.rawValue) { [weak self] key in
            HomePreferences.shared.startup = HomePreferences.Startup(rawValue: key) ?? .last
            self?.setUpBaseDate()
        }
        navigationController?.pushViewController(vc, animated: !UIAccessibility.isReduceMotionEnabled)
    }

    private func showAppearancePicker() {
        let options = HomePreferences.Appearance.allCases.map {
            OptionListViewController.Option(key: $0.rawValue, title: NSLocalizedString("setting_appearance_\($0.rawValue)", comment: ""))
        }
        let vc = OptionListViewController(title: NSLocalizedString("setting_appearance", comment: ""), options: options,
                                          selectedKey: HomePreferences.shared.appearance.rawValue) { [weak self] key in
            let appearance = HomePreferences.Appearance(rawValue: key) ?? .system
            HomePreferences.shared.appearance = appearance
            (UIApplication.shared.delegate as? AppDelegate)?.window?.overrideUserInterfaceStyle = appearance.style
            self?.setUpBaseDate()
        }
        navigationController?.pushViewController(vc, animated: !UIAccessibility.isReduceMotionEnabled)
    }

    private func showSystemPreferenceInfo(_ title: String, message: String? = nil, messageText: String? = nil) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""),
                                      message: messageText ?? message.map { NSLocalizedString($0, comment: "") },
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""), style: .default))
        present(alert, animated: !UIAccessibility.isReduceMotionEnabled)
    }

    private func showSwitchIntervalPicker() {
        let options = ["5s", "10s", "30s"].map {
            OptionListViewController.Option(key: $0,
                                            title: NSLocalizedString("switch_interval_\($0)", comment: ""))
        }
        let selected = settingConfig?.switchingRate ?? "10s"
        let vc = OptionListViewController(title: NSLocalizedString("setting_switch_interval", comment: ""),
                                          options: options,
                                          selectedKey: selected) { [weak self] key in
            SettingConfig.re.transaction { _ in
                self?.settingConfig?.switchingRate = key
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showRefreshRatePicker() {
        let options = ["1hour", "6hours", "1day"].map {
            OptionListViewController.Option(key: $0,
                                            title: NSLocalizedString("refresh_rate_\($0)", comment: ""))
        }
        let selected = settingConfig?.refreshRate ?? "1hour"
        let vc = OptionListViewController(title: NSLocalizedString("refresh_rate_title", comment: ""),
                                          options: options,
                                          selectedKey: selected) { [weak self] key in
            WidgetKitHelper.sharedDefaults?.set(key, forKey: WidgetKitHelper.refreshRate)
            WidgetKitHelper.reloadAllWidgets()
            SettingConfig.re.transaction { _ in
                self?.settingConfig?.refreshRate = key
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showWidgetSourcePicker() {
        let sources: [WidgetSource] = [.all, .plant, .traditional, .collect]
        let options = sources.map {
            OptionListViewController.Option(key: $0.rawValue,
                                            title: NSLocalizedString("widget_source_\($0.rawValue)", comment: ""))
        }
        let vc = OptionListViewController(title: NSLocalizedString("setting_widget_source", comment: ""),
                                          options: options,
                                          selectedKey: WidgetPlaylist.source.rawValue) { key in
            WidgetPlaylist.source = WidgetSource(rawValue: key) ?? .all
            WidgetPlaylist.rebuild()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Language Picker
extension SettingViewController {

    private func showLanguagePicker() {
        let alert = UIAlertController(title: NSLocalizedString("setting_language", comment: ""),
                                      message: nil,
                                      preferredStyle: .actionSheet)

        let options: [(String, String?)] = [
            (NSLocalizedString("setting_language_follow_system", comment: ""), nil),
            ("简体中文", "zh-Hans"),
            ("繁體中文", "zh-Hant"),
            ("English", "en"),
            ("日本語", "ja"),
            ("한국어", "ko")
        ]

        for (title, code) in options {
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                if let code = code {
                    UserDefaults.standard.set([code], forKey: "AppleLanguages")
                } else {
                    UserDefaults.standard.removeObject(forKey: "AppleLanguages")
                }
                UserDefaults.standard.synchronize()
                self?.showRestartAlert()
            })
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""),
                                      style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    private func showRestartAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("setting_language_restart_title", comment: ""),
            message: NSLocalizedString("setting_language_restart_message", comment: ""),
            preferredStyle: .alert)
        // 不能由 App 自己强制退出（App Store 审核不允许），只提示用户手动重启
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: ""),
                                      style: .default))
        present(alert, animated: true)
    }
}

extension SettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingCell.identifier,
                                                 for: indexPath,
                                                 cellType: SettingCell.self)
        let item = items[indexPath.section][indexPath.row]
        cell.item = item

        cell.switchDidClick = { [weak self] on in
            if item.setType == .HapticFeedback {
                HomePreferences.shared.hapticsEnabled = on
                self?.setUpBaseDate()
                return
            }
            SettingConfig.re.transaction {[weak self] _ in
                switch item.setType {
                case .AutomaticSwitch:
                    self?.settingConfig?.automaticSwitching = on
                case .RandomSwitching:
                    self?.settingConfig?.randomSwitching = on
                case .ShowFigure:
                    self?.settingConfig?.showFigure = on
                    UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(on, forKey: WidgetKitHelper.showFigure)
                    WidgetKitHelper.reloadAllWidgets()
                    
                case .ShowColorValue:
                    self?.settingConfig?.showTone = on
                    UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(on, forKey: WidgetKitHelper.showTone)
                    WidgetKitHelper.reloadAllWidgets()
                    
                default:
                    break
                    
                }
            }
            self?.widgetPreview?.updatePreview()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        items[section].first?.sectionName
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}
