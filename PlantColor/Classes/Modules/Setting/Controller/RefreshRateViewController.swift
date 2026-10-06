//
//  RefreshRateViewController.swift
//  PlantColor
//
//  Created by PlantColor on 2022/5/3.
//

import UIKit

class RefreshRateViewController: TableViewController {

    init() {
        super.init(style: .insetGrouped)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var items: [RateModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var settingConfig: SettingConfig?
    
    override func makeUI() {
        super.makeUI()
        setUpNav()
        view.backgroundColor = .main
        tableView.register(R.nib.rateCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = SettingCell.height
        setUpBaseDate()
    }
    
    private func setUpNav() {
        navigation.item.title = NSLocalizedString("refresh_rate_title", comment: "")
        navigation.bar.backgroundColor = .main
    }
    
    func setUpBaseDate() {
        
        settingConfig = try? SettingConfig.re.objects().first
        guard let settingConfig = settingConfig else { return }
        
        let oneHour = RateModel()
        oneHour.rate = "1hour"
        oneHour.displayName = NSLocalizedString("refresh_rate_1hour", comment: "")
        oneHour.select = settingConfig.refreshRate == oneHour.rate
        items.append(oneHour)

        let sixHour = RateModel()
        sixHour.rate = "6hours"
        sixHour.displayName = NSLocalizedString("refresh_rate_6hours", comment: "")
        sixHour.select = settingConfig.refreshRate == sixHour.rate
        items.append(sixHour)

        let oneDay = RateModel()
        oneDay.rate = "1day"
        oneDay.displayName = NSLocalizedString("refresh_rate_1day", comment: "")
        oneDay.select = settingConfig.refreshRate == oneDay.rate
        items.append(oneDay)
        
    }
    


}

extension RefreshRateViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for item in items {
            item.select = false
        }
        
        items[indexPath.row].select = true
        tableView.reloadData()
        
        
        UserDefaults(suiteName: WidgetKitHelper.groupBundleID)?.set(items[indexPath.row].rate, forKey: WidgetKitHelper.refreshRate)
        WidgetKitHelper.reloadAllWidgets()
        
        
        SettingConfig.re.transaction {[weak self] _ in
            guard let rate = self?.items[indexPath.row].rate else { return }
            self?.settingConfig?.refreshRate = rate
        }
    }
}

extension RefreshRateViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.rateCell.identifier,
                                                 for: indexPath,
                                                 cellType: RateCell.self)
        cell.item = items[indexPath.row]
        return cell
    }
    
    
    
}
