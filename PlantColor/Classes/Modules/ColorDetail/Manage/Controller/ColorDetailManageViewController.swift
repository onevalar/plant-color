//
//  ColorDetailManageViewController.swift
//  PlantColor
//
//  Created by QY on 2022/4/30.
//

import UIKit

/// "科普页管理"：决定详情页显示哪些版块、按什么顺序。植物色和传统色各有一份设置。
class ColorDetailManageViewController: TableViewController {

    enum Kind {
        case plant
        case traditional
    }

    /// 列表里的一行（植物色和传统色的版块类型不同，这里统一成一种）
    private struct Entry {
        let title: String
        /// 不允许隐藏和移动（如"概览"）
        let isLocked: Bool
        let plant: ColorDetailInfoType?
        let traditional: TraditionalColorDetailInfoType?
    }

    private let kind: Kind

    init(kind: Kind = .plant) {
        self.kind = kind
        super.init(style: .insetGrouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var items: [[Entry]] = []

    private var plantConfig: ColorDetailConfig?

    private var traditionalConfig: TraditionalColorDetailConfig?

    override func makeUI() {
        super.makeUI()

        view.backgroundColor = .main
        setUpNav()
        tableView.register(R.nib.colorDetailManageCell)
        tableView.register(UINib(resource: R.nib.colorDetailManageSectionHeader),
                           forHeaderFooterViewReuseIdentifier: "ColorDetailManageSectionHeader")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = ColorDetailManageCell.height
        tableView.sectionHeaderHeight = ColorDetailManageSectionHeader.height
        loadData()
    }

    func loadData() {
        switch kind {
        case .plant:
            plantConfig = try? ColorDetailConfig.re.objects().first
            guard let config = plantConfig else { return }
            items = [config.defaultNow.toArray, config.defaultOther.toArray].map { list in
                list.map { Entry(title: $0.title, isLocked: $0 == .intro, plant: $0, traditional: nil) }
            }
        case .traditional:
            traditionalConfig = try? TraditionalColorDetailConfig.re.objects().first
            guard let config = traditionalConfig else { return }
            items = [config.defaultNow.toArray, config.defaultOther.toArray].map { list in
                list.map { Entry(title: $0.title, isLocked: $0 == .intro, plant: nil, traditional: $0) }
            }
        }
        tableView.reloadData()
    }

    private func setUpNav() {
        navigationItem.title = NSLocalizedString(kind == .plant ? "manage_title" : "manage_traditional_title",
                                                  comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("common_edit", comment: ""),
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(editPressed))
    }

    @objc private func editPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        let title = tableView.isEditing ? NSLocalizedString("common_done", comment: "") : NSLocalizedString("common_edit", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title,
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(editPressed))
        if !tableView.isEditing {
            completeEdit()
        }
    }

    private func completeEdit() {
        switch kind {
        case .plant:
            ColorDetailConfig.re.transaction { [weak self] _ in
                guard let self = self else { return }
                let now = self.items[0].compactMap(\.plant)
                let other = self.items[1].compactMap(\.plant)
                self.plantConfig?.defaultNow.removeAll()
                self.plantConfig?.defaultOther.removeAll()
                self.plantConfig?.defaultNow.append(objectsIn: now)
                self.plantConfig?.defaultOther.append(objectsIn: other)
            }
        case .traditional:
            TraditionalColorDetailConfig.re.transaction { [weak self] _ in
                guard let self = self else { return }
                let now = self.items[0].compactMap(\.traditional)
                let other = self.items[1].compactMap(\.traditional)
                self.traditionalConfig?.defaultNow.removeAll()
                self.traditionalConfig?.defaultOther.removeAll()
                self.traditionalConfig?.defaultNow.append(objectsIn: now)
                self.traditionalConfig?.defaultOther.append(objectsIn: other)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ColorDetailManageViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorDetailManageCell.identifier,
                                                 for: indexPath,
                                                 cellType: ColorDetailManageCell.self)
        cell.item = items[indexPath.section][indexPath.row].title
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ColorDetailManageViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (kind, section) {
        case (.plant, 0): return NSLocalizedString("manage_section_science", comment: "")
        case (.traditional, 0): return NSLocalizedString("manage_traditional_section_main", comment: "")
        case (.plant, _): return NSLocalizedString("manage_section_other", comment: "")
        case (.traditional, _): return NSLocalizedString("manage_traditional_section_other", comment: "")
        }
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ColorDetailManageSectionHeader", ColorDetailManageSectionHeader.self)
//        header.item = section == 0 ? "植物科普" : "其他版块"
//        return header
//    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        if isAllowEdit(indexPath: indexPath) {
            return indexPath.section == 0 ? .delete : .insert
        } else {
            return .none
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        let item = items[indexPath.section][indexPath.row]
        items[indexPath.section].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        switch editingStyle {
        case .delete:
            items[1].append(item)
            tableView.insertRows(at: [IndexPath(row: items[1].count - 1,
                                                section: 1)],
                                 with: .automatic)
        case .insert:
            items[0].append(item)
            tableView.insertRows(at: [IndexPath(row: items[0].count - 1,
                                                section: 0)],
                                 with: .automatic)
        case .none:
            break
        @unknown default:
            break
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let item = items[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        items[destinationIndexPath.section].insert(item, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return isAllowEdit(indexPath: proposedDestinationIndexPath) ? proposedDestinationIndexPath : sourceIndexPath
        } else {
            return sourceIndexPath
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        isAllowEdit(indexPath: indexPath)
    }

    func isAllowEdit(indexPath: IndexPath) -> Bool {
        !items[indexPath.section][indexPath.row].isLocked
    }
}
