//
//  SearchView.swift
//  PlantColor
//
//  Created by insect on 2022/2/10.
//

import UIKit
import SnapKit

class SearchView: View {
    
    public static let height: CGFloat = 40
    
    public var searchButtonClicked: ((String?) -> Void)?

    public var text: String? {
        get { searchBar.text }
        set { searchBar.text = newValue }
    }

    private var pendingSearch: DispatchWorkItem?

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("common_search", comment: "")
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()
    
    override func makeUI() {
        super.makeUI()
        addSubview(searchBar)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.snp.makeConstraints {
            $0.left.right.bottom.top.equalToSuperview()
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        pendingSearch?.cancel()
        searchBar.resignFirstResponder()
        searchButtonClicked?(searchBar.text)
    }

    /// 边输入边搜索：停顿 0.3 秒后自动触发
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pendingSearch?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.searchButtonClicked?(searchText)
        }
        pendingSearch = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }
}
