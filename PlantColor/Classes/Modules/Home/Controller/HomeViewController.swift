//
//  HomeViewController.swift
//  PlantColor
//
//  Created by insect on 2022/2/7.
//

import UIKit
import EachNavigationBar
import RealmSwift

class HomeViewController: CollectionViewController {

    private var currentMode: HomeColorMode = .botanical
    private var botanicalItems: [ColorModel] = []
    private var traditionalItems: [TraditionalColorModel] = []
    private var displayItems: [any ColorDisplayable] = []

    private var index: Int = 0

    private var settingConfig: SettingConfig?

    private lazy var modeSegmentView: HomeModeSegmentView = {
        let view = HomeModeSegmentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.modeDidChange = { [weak self] mode in
            self?.switchToMode(mode)
        }
        return view
    }()

    private lazy var timer: SwiftTimer = {

        let timer = SwiftTimer.repeaticTimer(interval: .seconds(Int(TimeInterval.autoScroll))) { [weak self] _ in
            self?.autoScroll()
        }
        return timer
    }()

    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        super.init(collectionViewLayout: flowLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimerIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.suspend()
    }

    deinit {
        timer.suspend()
    }

    private func startTimerIfNeeded() {
        guard let settingConfig = settingConfig,
              settingConfig.automaticSwitching else { return }
        timer.start()
    }

     override func makeUI() {
        super.makeUI()

         navigation.bar.isHidden = true
         collectionView.isPagingEnabled = true
         collectionView.dataSource = self
         collectionView.delegate = self
         collectionView.register(R.nib.homeVerticalCell)
         collectionView.showsVerticalScrollIndicator = false
         disablesAdjustScrollViewInsets(collectionView)

         settingConfig = try? SettingConfig.re.objects().first

         // Load botanical colors
         do {
             botanicalItems = try ColorModel.re.objects().toArray
             if settingConfig?.randomSwitching ?? false {
                 botanicalItems = botanicalItems.shuffled()
             }
             AppLogger.shared.info("成功加载\(botanicalItems.count)个植物颜色模型")
         } catch {
             AppLogger.shared.error("加载植物颜色模型失败: \(error.localizedDescription)")
         }

         // Load traditional colors
         do {
             traditionalItems = try TraditionalColorModel.re.objects().toArray
             if traditionalItems.isEmpty {
                 traditionalItems = TraditionalColorProvider.fetchColors()
             }
             if settingConfig?.randomSwitching ?? false {
                 traditionalItems = traditionalItems.shuffled()
             }
             AppLogger.shared.info("成功加载\(traditionalItems.count)个传统颜色模型")
         } catch {
             traditionalItems = TraditionalColorProvider.fetchColors()
             AppLogger.shared.error("加载传统颜色模型失败: \(error.localizedDescription)")
         }

         displayItems = botanicalItems
         collectionView.reloadData()

         // Add floating pill segment view
         view.addSubview(modeSegmentView)
         NSLayoutConstraint.activate([
             modeSegmentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             modeSegmentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
             modeSegmentView.widthAnchor.constraint(equalToConstant: 200),
             modeSegmentView.heightAnchor.constraint(equalToConstant: 40),
         ])
    }

    private func switchToMode(_ mode: HomeColorMode) {
        guard mode != currentMode else { return }
        currentMode = mode

        // Scroll to top before switching to prevent out-of-bounds
        if !displayItems.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: .top,
                                        animated: false)
        }

        switch mode {
        case .botanical:
            displayItems = botanicalItems
        case .traditional:
            displayItems = traditionalItems
        }

        index = 0
        collectionView.reloadData()
    }

    private func autoScroll() {

        guard let settingConfig = settingConfig else { return }

        if !settingConfig.automaticSwitching {
            return
        }

        guard let cell = collectionView.visibleCells.first ,
        var index = collectionView.indexPath(for: cell)?.row else {
            return
        }

        index += 1
        if index >= displayItems.count {
            index = 0
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                    at: .bottom,
                                    animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeVerticalCell.identifier,
                                                      for: indexPath,
                                                      cellType: HomeVerticalCell.self)
        cell.displayItem = displayItems[indexPath.row]
        cell.didEndScroll = { [weak self] in
            self?.index = $0
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        view.size
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        Feedback.lightPrepare()

        let index = Int(targetContentOffset.pointee.y / collectionView.height)
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index,
                                                                  section: 0)) as? HomeVerticalCell
        else { return }
        cell.index = self.index
    }
}
