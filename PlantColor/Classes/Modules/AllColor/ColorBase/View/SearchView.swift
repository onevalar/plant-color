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
        searchButtonClicked?(searchBar.text)
    }
}
