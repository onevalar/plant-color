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

    /// 只看植物色 / 只看传统色；nil 表示都看
    var sourceFilter: ColorKind? {
        didSet {
            loadingNewData { [weak self] in
                self?.loadingDataFinished()
            }
        }
    }

    var items: [any ColorDisplayable] = []

    lazy var sourceSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: [NSLocalizedString("color_series_all", comment: ""),
                                                 NSLocalizedString("home_mode_plant", comment: ""),
                                                 NSLocalizedString("home_mode_traditional", comment: "")])
        segment.selectedSegmentIndex = sourceIndex(for: sourceFilter)
        segment.addTarget(self, action: #selector(sourceSegmentChanged), for: .valueChanged)
        return segment
    }()

    private func sourceIndex(for kind: ColorKind?) -> Int {
        switch kind {
        case nil: return 0
        case .plant?: return 1
        case .traditional?: return 2
        }
    }

    @objc private func sourceSegmentChanged() {
        switch sourceSegment.selectedSegmentIndex {
        case 1: sourceFilter = .plant
        case 2: sourceFilter = .traditional
        default: sourceFilter = nil
        }
    }

    lazy var searchView: SearchView = {
        let searchView = SearchView(frame: .zero)
        searchView.searchButtonClicked = { [weak self] in
            guard let self = self, self.searchKey != $0 else { return }
            self.searchKey = $0
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

        sourceSegment.snp.remakeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(2)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview().offset(-14)
            $0.height.equalTo(30)
        }

        filterMenu.snp.remakeConstraints {
            $0.top.equalTo(sourceSegment.snp.bottom).offset(6)
            $0.height.equalTo(ColorFilterMenu.height)
            $0.left.equalTo(18)
            $0.right.equalTo(-14)
        }
    }

    init(type: ColorListType,
         searchKey: String? = nil,
         colorSeries: ColorSeries? = nil,
         sourceFilter: ColorKind? = nil) {
        self.type = type
        self.searchKey = searchKey
        self.colorSeries = colorSeries
        self.sourceFilter = sourceFilter
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
        view.addSubview(sourceSegment)
        view.addSubview(filterMenu)
        searchView.text = searchKey
        filterMenu.isGrid = isGrid
    }

    private func setUpNav() {
        navigation.item.title = type.title
        navigation.bar.backgroundColor = .white
    }

    func loadingNewData(result: (() -> Void)? = nil) {
        var combined: [any ColorDisplayable] = []
        if sourceFilter != .traditional {
            combined += loadPlantItems()
        }
        if sourceFilter != .plant {
            combined += loadTraditionalItems()
        }
        items = combined
        AppLogger.shared.info("成功加载\(items.count)个颜色项目")
        result?()
    }

    private func loadPlantItems() -> [ColorModel] {
        do {
            return try ColorModel.re.objects().where { [weak self] element in
                guard let self else { return element.id > 0 }
                var query: Query<Bool> = element.id > 0
                if let key = self.searchKey, !key.isEmpty {
                    query = query && (
                        element.plantName.contains(key, options: .caseInsensitive)
                        || element.plantFamily.contains(key, options: .caseInsensitive)
                        || element.plantGenus.contains(key, options: .caseInsensitive)
                        || element.plantAlias.contains(key, options: .caseInsensitive)
                        || element.colorHEX.contains(key, options: .caseInsensitive)
                        || element.plantAbstract.contains(key, options: .caseInsensitive)
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
        } catch {
            AppLogger.shared.error("加载植物颜色失败: \(error.localizedDescription)")
            return []
        }
    }

    private func loadTraditionalItems() -> [TraditionalColorModel] {
        do {
            return try TraditionalColorModel.re.objects().where { [weak self] element in
                guard let self else { return element.id > 0 }
                var query: Query<Bool> = element.id > 0
                if let key = self.searchKey, !key.isEmpty {
                    query = query && (
                        element.name.contains(key, options: .caseInsensitive)
                        || element.pinyin.contains(key, options: .caseInsensitive)
                        || element.colorHEX.contains(key, options: .caseInsensitive)
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
        } catch {
            AppLogger.shared.error("加载传统颜色失败: \(error.localizedDescription)")
            return []
        }
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
