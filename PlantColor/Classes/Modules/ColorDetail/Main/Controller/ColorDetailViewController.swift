//
//  ColorDetailViewController.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import EachNavigationBar
import UIKit
import RealmSwift

class ColorDetailViewController: TableViewController {
    private let colorModel: ColorModel
    private var items: [ColorDetailCellType] = []

    init(colorModel: ColorModel) {
        self.colorModel = colorModel
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()
        setUpNav()
        view.backgroundColor = .white
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.colorDetailIntroCell)
        tableView.register(R.nib.colorDetailImageCell)
        tableView.register(R.nib.colorDetailSubtitleCell)
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 15
        tableView.showsVerticalScrollIndicator = false
        loadData()
        setUpInsightFooter()
    }

    private var footerView: ColorInsightFooterView?

    /// 底部加上"色值（点击复制）"和"配色推荐"
    private func setUpInsightFooter() {
        let footer = ColorInsightFooterView(item: colorModel)
        footer.didSelectItem = { [weak self] item in
            self?.navigationController?.pushViewController(item.makeDetailViewController(),
                                                           animated: true)
        }
        footerView = footer
        tableView.tableFooterView = footer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 底部的高度取决于宽度，宽度确定后再算
        guard let footer = footerView, tableView.bounds.width > 0 else { return }
        let height = footer.height(fitting: tableView.bounds.width)
        if abs(footer.frame.height - height) > 0.5 || footer.frame.width != tableView.bounds.width {
            footer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height)
            tableView.tableFooterView = footer
        }
    }

    func loadData() {

        guard var localConfig = try? ColorDetailConfig.re.objects().first?.defaultNow.toArray else { return }
        
        localConfig.insert(.image0, at: 1)
        
        localConfig.append(.image2)
        
        localConfig.insert(.image1, at: localConfig.count / 2 + 1)

        for config in localConfig {

            switch config {
            case .intro:
                items.append(.intro(colorModel))
            case .derivation:
                if colorModel.plantDerivationDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantDerivationTitle,
                                                           detail: colorModel.plantDerivationDetail,
                                                           type: config)))
            case .food:
                if colorModel.plantFoodDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantFoodTitle,
                                                           detail: colorModel.plantFoodDetail,
                                                           type: config)))
            case .custom:
                if colorModel.plantCustomDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantCustomTitle,
                                                           detail: colorModel.plantCustomDetail,
                                                           type: config)))
            case .application:
                if colorModel.plantApplicationDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantApplicationTitle,
                                                           detail: colorModel.plantApplicationDetail,
                                                           type: config)))
            case .cultivation:
                if colorModel.plantCultivationDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantCultivationTitle,
                                                           detail: colorModel.plantCultivationDetail,
                                                           type: config)))
            case .medicinalEffect:
                if colorModel.plantMedicinalEffectDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantMedicinalEffectTitle,
                                                           detail: colorModel.plantMedicinalEffectDetail,
                                                           type: config)))
            case .story:
                if colorModel.plantStoryDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantStoryTitle,
                                                           detail: colorModel.plantStoryDetail,
                                                           type: config)))
            case .meanings:
                if colorModel.plantMeaningsDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantMeaningsTitle,
                                                           detail: colorModel.plantMeaningsDetail,
                                                           type: config)))
            case .literature:

                if colorModel.plantLiteratureDetail.isEmpty {
                    break
                }
                items.append(.subtitle(ColorDetailSubtitle(title: colorModel.plantLiteratureTitle,
                                                           detail: colorModel.plantLiteratureDetailString,
                                                           type: .literature)))
            case .image0:
                items.append(.image("\(colorModel.detailImageName)_0"))
            case .image1:
                items.append(.image("\(colorModel.detailImageName)_1"))
            case .image2:
                items.append(.image("\(colorModel.detailImageName)_2"))
            }
        }
        tableView.reloadData()
    }

    private func setUpNav() {
        navigation.item.title = colorModel.plantName
        navigation.bar.backgroundColor = .white
        navigation.item.rightBarButtonItems = ColorDetailActions.barItems(for: colorModel, from: self)
    }
}

// MARK: - UITableViewDataSource

extension ColorDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.row] {
        case let .intro(item):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorDetailIntroCell.identifier,
                                                     for: indexPath,
                                                     cellType: ColorDetailIntroCell.self)
            cell.item = item
            return cell
        case let .image(item):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorDetailImageCell.identifier,
                                                     for: indexPath,
                                                     cellType: ColorDetailImageCell.self)
            cell.item = item
            return cell
        case let .subtitle(item):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.colorDetailSubtitleCell.identifier,
                                                     for: indexPath,
                                                     cellType: ColorDetailSubtitleCell.self)
            cell.item = item
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ColorDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch items[indexPath.row] {
        case let .image(item):
            guard let image = UIImage(named: item) else { return 0 }
            let ratio = image.size.height / image.size.width
            return (view.width - 30) * ratio
        default:
            return UITableView.automaticDimension
        }
    }
}
