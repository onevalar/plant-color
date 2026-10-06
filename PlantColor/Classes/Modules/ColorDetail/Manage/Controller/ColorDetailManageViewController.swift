//
//  ColorDetailManageViewController.swift
//  PlantColor
//
//  Created by QY on 2022/4/30.
//

import UIKit

class ColorDetailManageViewController: TableViewController {

    private let disableEdit: [ColorDetailInfoType] = [.intro]

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var items: [[ColorDetailInfoType]] = []

    private var localConfig: ColorDetailConfig?

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

        localConfig = try? ColorDetailConfig.re.objects().first
        guard let localConfig = localConfig else { return }
        items.append(localConfig.defaultNow.toArray)
        items.append(localConfig.defaultOther.toArray)
        tableView.reloadData()
    }

    private func setUpNav() {
        navigation.item.title = NSLocalizedString("manage_title", comment: "")
        navigation.item.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("common_edit", comment: ""),
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(editPressed))
    }

    @objc private func editPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        let title = tableView.isEditing ? NSLocalizedString("common_done", comment: "") : NSLocalizedString("common_edit", comment: "")
        navigation.item.rightBarButtonItem = UIBarButtonItem(title: title,
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(editPressed))
        if !tableView.isEditing {
            completeEdit()
        }
    }

    private func completeEdit() {

        ColorDetailConfig.re.transaction { [weak self] _ in
            guard let self = self else { return }
            self.localConfig?.defaultNow.removeAll()
            self.localConfig?.defaultOther.removeAll()
            self.localConfig?.defaultNow.append(objectsIn: self.items[0])
            self.localConfig?.defaultOther.append(objectsIn: self.items[1])
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
        section == 0 ? NSLocalizedString("manage_section_science", comment: "") : NSLocalizedString("manage_section_other", comment: "")
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
        disableEdit.filter { [unowned self] in
            self.items[indexPath.section][indexPath.row] == $0
        }.isEmpty
    }
}
