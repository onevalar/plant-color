//
//  ColorBaseViewController.swift
//  PlantColor
//
//  Created by QY on 2022/4/25.
//

import EachNavigationBar
import EmptyDataSetExtension
import Hero
import UIKit
import RealmSwift

class ColorListBaseViewController: ViewController {

    var isGrid: Bool = false {
        didSet {
            filterMenu.isGrid = isGrid
        }
    }

    var isShowColorSeriesView: Bool = false {
        didSet {

            if isShowColorSeriesView {

                UIView.animate(withDuration: 0.25) {
                    self.colorSeriesFilterView.snp.remakeConstraints {
                        $0.top.equalTo(self.filterMenu.snp.bottom)
                        $0.height.equalTo(ColorSeriesFilterView.height)
                        $0.right.left.equalTo(self.view)
                    }
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.colorSeriesFilterView.snp.remakeConstraints {
                        $0.top.equalTo(self.filterMenu.snp.top).offset(-ColorSeriesFilterView.height)
                        $0.height.equalTo(ColorSeriesFilterView.height)
                        $0.right.left.equalTo(self.view)
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    let type: ColorListType

    var searchKey: String? {
        didSet {
            loadingNewData { [weak self] in
                self?.loadingDataFinished()
            }
        }
    }

    var colorSeries: ColorSeries? {
        didSet {
            loadingNewData { [weak self] in
                self?.loadingDataFinished()
            }
        }
    }

    var items: [any ColorDisplayable] = []

    lazy var searchView: SearchView = {
        let searchView = SearchView(frame: .zero)
        searchView.searchButtonClicked = { [weak self] in
            self?.searchKey = $0
        }
        return searchView
    }()

    lazy var filterMenu: ColorFilterMenu = {
        let filterMenu = R.nib.colorFilterMenu.firstView(owner: nil)!
        filterMenu.gridDidClick = { [weak self] in
            self?.gridDidClick()
        }

        filterMenu.listDidClick = { [weak self] in
            self?.listDidClick()
        }

        filterMenu.colorSeriesDidClick = { [weak self] in
            guard let self = self else { return }
            self.isShowColorSeriesView = !self.isShowColorSeriesView
        }
        return filterMenu
    }()

    lazy var colorSeriesFilterView: ColorSeriesFilterView = {
        let colorSeriesFilterView = ColorSeriesFilterView(frame: .zero)
        colorSeriesFilterView.didClickColorSeries = { [weak self] in
            self?.colorSeries = $0
            self?.isShowColorSeriesView = false
        }
        return colorSeriesFilterView
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        searchView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(navigation.bar.bottom)
            $0.left.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-14)
            $0.height.equalTo(SearchView.height)
        }

        filterMenu.snp.remakeConstraints {
            $0.top.equalTo(searchView.snp.bottom)
            $0.height.equalTo(ColorFilterMenu.height)
            $0.left.equalTo(18)
            $0.right.equalTo(-14)
        }
    }

    init(type: ColorListType, searchKey: String? = nil) {
        self.type = type
        self.searchKey = searchKey
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()

        setUpNav()
        view.addSubview(searchView)
        view.addSubview(filterMenu)
        filterMenu.isGrid = isGrid
    }

    private func setUpNav() {
        navigation.item.title = type.title
        navigation.bar.backgroundColor = .white
    }

    func loadingNewData(result: (() -> Void)? = nil) {
        var combined: [any ColorDisplayable] = []

        // 加载植物色
        do {
            let plantItems = try ColorModel.re.objects().where { [weak self] element in
                guard let self else { return element.id > 0 }
                var query: Query<Bool> = element.id > 0
                if let key = self.searchKey, !key.isEmpty {
                    query = query && (
                        element.plantName.starts(with: key)
                        || element.plantFamily.starts(with: key)
                        || element.plantGenus.starts(with: key)
                        || element.plantAlias.starts(with: key)
                        || element.plantAbstract.contains(key)
                    )
                }
                if let series = self.colorSeries {
                    query = query && element.colorSeries == series
                }
                if self.type == .collect {
                    query = query && element.isCollect == true
                }
                return query
            }.toArray
            combined += plantItems
        } catch {
            AppLogger.shared.error("加载植物颜色失败: \(error.localizedDescription)")
        }

        // 加载传统色
        do {
            let traditionalItems = try TraditionalColorModel.re.objects().where { [weak self] element in
                guard let self else { return element.id > 0 }
                var query: Query<Bool> = element.id > 0
                if let key = self.searchKey, !key.isEmpty {
                    query = query && (
                        element.name.starts(with: key)
                        || element.pinyin.starts(with: key)
                    )
                }
                if let series = self.colorSeries {
                    query = query && element.colorSeries == series
                }
                if self.type == .collect {
                    query = query && element.isCollect == true
                }
                return query
            }.toArray
            combined += traditionalItems
        } catch {
            AppLogger.shared.error("加载传统颜色失败: \(error.localizedDescription)")
        }

        items = combined
        AppLogger.shared.info("成功加载\(items.count)个颜色项目")
        result?()
    }

    func loadingDataFinished() {}

    func listDidClick() {
        isGrid  = false
        navigationController?.hero.navigationAnimationType = .fade
    }

    func gridDidClick() {
        isGrid  = true
        navigationController?.hero.navigationAnimationType = .fade
    }

    func pushToDetail(index: Int) {
        guard index < items.count else { return }
        let item = items[index]
        navigationController?.hero.navigationAnimationType = .auto
        let vc = item.makeDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
