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
    
    init() {
        super.init(style: .insetGrouped)
    }
    
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
        tableView.register(R.nib.settingCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = SettingCell.height
        setUpBaseDate()
    }
    
    private func setUpNav() {

        navigation.item.title = NSLocalizedString("setting_title", comment: "")
        navigation.bar.backgroundColor = .main
    }
    
    func setUpBaseDate() {
        
        settingConfig = try? SettingConfig.re.objects().first
        guard let settingConfig = settingConfig else { return }
        
        items.append([SetModel(sectionName: NSLocalizedString("setting_section_my_colors", comment: ""),
                               imageName: "allColor",
                               title: NSLocalizedString("setting_all_colors", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .AllColor),
                      SetModel(sectionName: NSLocalizedString("setting_section_my_colors", comment: ""),
                               imageName: "myCollection",
                               title: NSLocalizedString("setting_my_collection", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .MyCollection)])
        
        items.append([SetModel(sectionName: NSLocalizedString("setting_section_features", comment: ""),
                               imageName: "scientificManagement",
                               title: NSLocalizedString("setting_scientific_management", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .ScientificManagement),
                      SetModel(sectionName: NSLocalizedString("setting_section_features", comment: ""),
                               imageName: "sf.books.vertical",
                               title: NSLocalizedString("setting_traditional_management", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .TraditionalManagement),
                      SetModel(sectionName: NSLocalizedString("setting_section_features", comment: ""),
                               imageName: "automaticSwitch",
                               title: NSLocalizedString("setting_auto_switch", comment: ""),
                               showSwitch: true,
                               switchState: settingConfig.automaticSwitching,
                               setType: .AutomaticSwitch),
                      SetModel(sectionName: NSLocalizedString("setting_section_features", comment: ""),
                               imageName: "sf.timer",
                               title: NSLocalizedString("setting_switch_interval", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .SwitchingInterval),
                      SetModel(sectionName: NSLocalizedString("setting_section_features", comment: ""),
                               imageName: "randomSwitching",
                               title: NSLocalizedString("setting_random_switch", comment: ""),
                               showSwitch: true,
                               switchState: settingConfig.randomSwitching,
                               setType: .RandomSwitching),
                      SetModel(sectionName: NSLocalizedString("setting_section_features", comment: ""),
                               imageName: "sf.globe",
                               title: NSLocalizedString("setting_language", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .Language)])
        
        items.append([SetModel(sectionName: NSLocalizedString("setting_section_widget", comment: ""),
                               imageName: "mapper",
                               title: NSLocalizedString("setting_show_figure", comment: ""),
                               showSwitch: true,
                               switchState: settingConfig.showFigure,
                               setType: .ShowFigure),
                      SetModel(sectionName: NSLocalizedString("setting_section_widget", comment: ""),
                               imageName: "accordingColor",
                               title: NSLocalizedString("setting_show_color_value", comment: ""),
                               showSwitch: true,
                               switchState: settingConfig.showTone,
                               setType: .ShowColorValue),
                      SetModel(sectionName: NSLocalizedString("setting_section_widget", comment: ""),
                               imageName: "customText",
                               title: NSLocalizedString("setting_custom_content", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .CustomContent),
                      SetModel(sectionName: NSLocalizedString("setting_section_widget", comment: ""),
                               imageName: "sf.square.stack",
                               title: NSLocalizedString("setting_widget_source", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .WidgetSource),
                      SetModel(sectionName: NSLocalizedString("setting_section_widget", comment: ""),
                               imageName: "refreshRate",
                               title: NSLocalizedString("setting_color_refresh", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .ColorRefresh)])
        
        items.append([SetModel(sectionName: NSLocalizedString("setting_section_about", comment: ""),
                               imageName: "thankYou",
                               title: NSLocalizedString("setting_acknowledgement", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .Acknowledgement),
                      SetModel(sectionName: NSLocalizedString("setting_section_about", comment: ""),
                               imageName: "sharingApplication",
                               title: NSLocalizedString("setting_share_app", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .ShareApplication),
                      SetModel(sectionName: NSLocalizedString("setting_section_about", comment: ""),
                               imageName: "evaluation",
                               title: NSLocalizedString("setting_rate_app", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .EvaluationApplication),
                      SetModel(sectionName: NSLocalizedString("setting_section_about", comment: ""),
                               imageName: "contactFeedback",
                               title: NSLocalizedString("setting_contact_feedback", comment: ""),
                               showSwitch: false,
                               switchState: false,
                               setType: .ContactFeedback)])
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
                } clean: {
                    SettingConfig.re.transaction {[weak self] _ in
                        self?.settingConfig?.customContent = ""
                        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set("", forKey: WidgetKitHelper.customContent)
                        WidgetKitHelper.reloadAllWidgets()
                    }
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
        }
        
    }
}

// MARK: - Option Pickers
extension SettingViewController {

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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableViewHeadView = R.nib.tableViewHeadView.firstView(owner: nil)!
        tableViewHeadView.item = items[section][0]
        return tableViewHeadView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}
