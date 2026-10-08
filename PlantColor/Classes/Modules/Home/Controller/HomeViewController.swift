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

    /// 两个模式各自停留的位置，切换回来时回到原处
    private var savedPositions: [HomeColorMode: Int] = [:]

    private var settingConfig: SettingConfig?
    private var settingToken: NotificationToken?
    /// 当前列表是否已按"随机切换"打乱
    private var isShuffled = false
    private var needsInitialRestore = true

    private lazy var modeSegmentView: HomeModeSegmentView = {
        let view = HomeModeSegmentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.modeDidChange = { [weak self] mode in
            self?.switchToMode(mode)
        }
        return view
    }()

    private lazy var timer: SwiftTimer = {

        let timer = SwiftTimer.repeaticTimer(interval: .seconds(Int(switchInterval))) { [weak self] _ in
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
        rememberBrowsingPosition()
        timer.suspend()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard needsInitialRestore, collectionView.bounds.height > 0, !displayItems.isEmpty else { return }
        needsInitialRestore = false
        let saved = HomePreferences.shared.startup == .last ? HomePreferences.shared.position(for: currentMode) : nil
        let row = saved.flatMap { position in displayItems.firstIndex { $0.id == position.colorID } } ?? 0
        collectionView.scrollToItem(at: IndexPath(item: row, section: 0), at: .top, animated: false)
        rememberBrowsingPosition()
    }

    deinit {
        settingToken?.invalidate()
        timer.suspend()
        NotificationCenter.default.removeObserver(self)
    }

    /// 自动切换的间隔，取自设置里的"切换间隔"（如 "5s"），没设置时用默认值
    private var switchInterval: TimeInterval {
        guard let rate = settingConfig?.switchingRate,
              rate.hasSuffix("s"),
              let seconds = TimeInterval(rate.dropLast()),
              seconds > 0 else { return .autoScroll }
        return seconds
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
         collectionView.bounces = !UIAccessibility.isReduceMotionEnabled
         NotificationCenter.default.addObserver(self, selector: #selector(accessibilityMotionChanged),
                                                name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
         collectionView.dataSource = self
         collectionView.delegate = self
         collectionView.register(R.nib.homeVerticalCell)
         collectionView.showsVerticalScrollIndicator = false
         disablesAdjustScrollViewInsets(collectionView)

         settingConfig = try? SettingConfig.re.objects().first
         if HomePreferences.shared.startup == .last {
             currentMode = HomePreferences.shared.lastMode
             index = HomePreferences.shared.position(for: currentMode)?.page ?? 0
         }
         modeSegmentView.selectMode(currentMode)

         isShuffled = settingConfig?.randomSwitching ?? false
         loadItems()
         collectionView.reloadData()
         observeSettingChanges()

         // Add floating pill segment view
         view.addSubview(modeSegmentView)
         NSLayoutConstraint.activate([
             modeSegmentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             modeSegmentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
             modeSegmentView.widthAnchor.constraint(equalToConstant: 200),
             modeSegmentView.heightAnchor.constraint(equalToConstant: 44),
         ])
    }

    @objc private func accessibilityMotionChanged() {
        collectionView.bounces = !UIAccessibility.isReduceMotionEnabled
    }

    /// 设置页是半屏弹出的，关闭时首页不会重新出现，
    /// 所以直接监听设置的变化，开关一拨就立即生效
    private func observeSettingChanges() {
        settingToken = settingConfig?.observe { [weak self] change in
            guard case .change = change else { return }
            self?.applySettingChanges()
        }
    }

    private func applySettingChanges() {
        guard let settingConfig = settingConfig else { return }

        timer.rescheduleRepeating(interval: .seconds(Int(switchInterval)))
        if settingConfig.automaticSwitching {
            if view.window != nil { timer.start() }
        } else {
            timer.suspend()
        }

        if settingConfig.randomSwitching != isShuffled {
            isShuffled = settingConfig.randomSwitching
            reloadItemsForCurrentOrder()
        }
    }

    /// 读取两类颜色，并按"随机切换"的开关决定是否打乱顺序
    private func loadItems() {
        do {
            botanicalItems = try ColorModel.re.objects().toArray
            AppLogger.shared.info("成功加载\(botanicalItems.count)个植物颜色模型")
        } catch {
            AppLogger.shared.error("加载植物颜色模型失败: \(error.localizedDescription)")
        }

        do {
            traditionalItems = try TraditionalColorModel.re.objects().toArray
            if traditionalItems.isEmpty {
                traditionalItems = TraditionalColorProvider.fetchColors()
            }
            AppLogger.shared.info("成功加载\(traditionalItems.count)个传统颜色模型")
        } catch {
            traditionalItems = TraditionalColorProvider.fetchColors()
            AppLogger.shared.error("加载传统颜色模型失败: \(error.localizedDescription)")
        }

        if isShuffled {
            botanicalItems = botanicalItems.shuffled()
            traditionalItems = traditionalItems.shuffled()
        }
        displayItems = currentMode == .botanical ? botanicalItems : traditionalItems
    }

    /// 随机切换开关变化后，重新排列首页的颜色顺序
    private func reloadItemsForCurrentOrder() {
        loadItems()
        index = 0
        collectionView.reloadData()
        if !displayItems.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: .top,
                                        animated: false)
        }
        rememberBrowsingPosition()
    }

    private func switchToMode(_ mode: HomeColorMode) {
        guard mode != currentMode else { return }

        // 记下离开前停在第几个，回来时接着看
        if collectionView.bounds.height > 0 {
            savedPositions[currentMode] = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        }
        currentMode = mode
        index = HomePreferences.shared.position(for: mode)?.page ?? index

        // 先回到顶部再换数据，避免两边数量不同导致偏移越界
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

        collectionView.reloadData()

        let rememberedID = HomePreferences.shared.position(for: mode)?.colorID
        let position = savedPositions[mode] ?? rememberedID.flatMap { id in displayItems.firstIndex { $0.id == id } } ?? 0
        if position < displayItems.count {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: IndexPath(item: position, section: 0),
                                        at: .top,
                                        animated: false)
        }
        rememberBrowsingPosition()
    }

    private func rememberBrowsingPosition() {
        guard !needsInitialRestore, collectionView.bounds.height > 0 else { return }
        let row = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        guard displayItems.indices.contains(row) else { return }
        HomePreferences.shared.remember(mode: currentMode, colorID: displayItems[row].id, page: index)
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
                                    animated: !UIAccessibility.isReduceMotionEnabled)
        if UIAccessibility.isReduceMotionEnabled { rememberBrowsingPosition() }
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
            self?.rememberBrowsingPosition()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? HomeVerticalCell)?.index = index
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        view.size
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { rememberBrowsingPosition() }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { rememberBrowsingPosition() }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { rememberBrowsingPosition() }
    }

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
