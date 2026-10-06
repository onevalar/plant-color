//
//  ShareEditView.swift
//  PlantColor
//
//  Created by QY on 2022/5/7.
//

import UIKit
import JXCategoryView
import SnapKit

class ShareEditPageView: View {

    static let height = 180
    
    var items: [ShareEditModel] = []

    let colorModel: ColorModel

    var didSelectEditType: (([ShareEditModel]) -> Void)?

    public lazy var categoryView: JXCategoryTitleImageView = {

        let backgroundView = JXCategoryIndicatorBackgroundView()
        backgroundView.indicatorHeight = 33
        backgroundView.indicatorColor = .RGBA(242, 242, 247)
        backgroundView.indicatorCornerRadius = 5
        let categoryView = JXCategoryTitleImageView()
        categoryView.indicators = [backgroundView]
        categoryView.titleColor = .black
        categoryView.titleSelectedColor = .black
        categoryView.isAverageCellSpacingEnabled = false
        categoryView.delegate = self
        categoryView.listContainer = listContainerView
        return categoryView
    }()

    private lazy var listContainerView = JXCategoryListContainerView(type: .scrollView,
                                                                     delegate: self)!

    init(colorModel: ColorModel, items: [ShareEditModel]) {
        self.colorModel = colorModel
        self.items = items
        super.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI() {
        super.makeUI()
        backgroundColor = .white
        addSubview(categoryView)
        addSubview(listContainerView)
        loadData()
        didSelectEditType?(items)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        categoryView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(44)
        }

        listContainerView.snp.makeConstraints {
            $0.top.equalTo(categoryView.snp.bottom)
            $0.right.left.bottom.equalToSuperview()
        }
    }

    private func loadData() {

        categoryView.titles = items.map { $0.title }
        categoryView.imageNames = items.map { $0.icon }
    }
}

// MARK: - JXCategoryViewDelegate
extension ShareEditPageView: JXCategoryViewDelegate {

    func categoryView(_ categoryView: JXCategoryBaseView!, didSelectedItemAt index: Int) {
        listContainerView.didClickSelectedItem(at: index)
    }
}

// MARK: - JXCategoryListContainerViewDelegate
extension ShareEditPageView: JXCategoryListContainerViewDelegate {

    func number(ofListsInlistContainerView listContainerView: JXCategoryListContainerView!) -> Int {
        items.count
    }

    func listContainerView(_ listContainerView: JXCategoryListContainerView!, initListFor index: Int) -> JXCategoryListContentViewDelegate! {
        let view = ShareEditListContainerView(frame: listContainerView.bounds,
                                              item: items[index],
                                              colorModel: colorModel)
        view.didSelectItemAt = { [weak self] in
            guard let self = self else { return }
            self.items[index].selectedIndex = $0
            self.listContainerView.reloadData()
            self.didSelectEditType?(self.items)
        }
        return view
    }
}
