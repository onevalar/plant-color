//
//  OptionListViewController.swift
//  PlantColor
//
//  单选列表：设置里"刷新频率""切换间隔""小组件颜色来源"等都用它。
//

import UIKit

class OptionListViewController: TableViewController {

    struct Option {
        let key: String
        let title: String
    }

    private let navTitle: String
    private let options: [Option]
    private var selectedKey: String
    private let onSelect: (String) -> Void

    init(title: String,
         options: [Option],
         selectedKey: String,
         onSelect: @escaping (String) -> Void) {
        self.navTitle = title
        self.options = options
        self.selectedKey = selectedKey
        self.onSelect = onSelect
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()
        navigation.item.title = navTitle
        navigation.bar.backgroundColor = .main
        view.backgroundColor = .main
        tableView.backgroundColor = .main
        view.tintColor = .settingsAccent
        navigation.bar.tintColor = .settingsAccent
        tableView.register(R.nib.rateCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = RateCell.height
        exposeAuxiliaryNavigationControls()
    }
}

extension OptionListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = options[indexPath.row].key
        guard key != selectedKey else { return }
        selectedKey = key
        tableView.reloadData()
        onSelect(key)
    }
}

extension OptionListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.rateCell.identifier,
                                                 for: indexPath,
                                                 cellType: RateCell.self)
        let option = options[indexPath.row]
        let model = RateModel()
        model.rate = option.key
        model.displayName = option.title
        model.select = option.key == selectedKey
        cell.item = model
        return cell
    }
}
