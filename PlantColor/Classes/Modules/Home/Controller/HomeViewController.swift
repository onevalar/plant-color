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

    private lazy var toolbar: HomeToolbar = {
        let bar = HomeToolbar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.onInfo = { [weak self] in self?.showInfo() }
        bar.onSearch = { [weak self] in
            let vc = NavigationController(rootViewController: ColorListViewController(type: .all))
            self?.present(vc, animated: true)
        }
        bar.onShare = { [weak self] in
            guard let item = self?.currentItem else { return }
            let vc = NavigationController(rootViewController: ShareViewController(item: item))
            self?.present(vc, animated: true)
        }
        bar.onSettings = { [weak self] in
            self?.present(NavigationController(rootViewController: SettingViewController()), animated: true)
        }
        return bar
    }()

    /// 屏幕上正在显示的颜色
    private var currentItem: (any ColorDisplayable)? {
        guard collectionView.bounds.height > 0 else { return displayItems.first }
        let row = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        return displayItems.indices.contains(row) ? displayItems[row] : displayItems.first
    }

    /// 让工具条和切换条的颜色、操作对象跟上当前色块
    private func refreshCurrentItem() {
        guard let item = currentItem else { return }
        toolbar.item = item
        modeSegmentView.updateTextColor(item.textUIColor)
        // 玻璃的明暗跟着色块走：浅色块上用浅色玻璃，深色块上用深色玻璃，
        // 这样不管系统是浅色还是深色模式，图标和文字都清楚
        let isLightColor = (RGBColor(hex: item.colorHEX)?.lab.l ?? 60) > 60
        let style: UIUserInterfaceStyle = isLightColor ? .light : .dark
        toolbar.overrideUserInterfaceStyle = style
        modeSegmentView.overrideUserInterfaceStyle = style
    }

    private func showInfo() {
        guard let item = currentItem else { return }
        let sheet = ColorInfoSheetViewController(item: item) { [weak self] in
            let vc = NavigationController(rootViewController: item.makeDetailViewController())
            self?.present(vc, animated: true)
        }
        present(sheet, animated: !UIAccessibility.isReduceMotionEnabled)
    }

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
        refreshCurrentItem()
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
        refreshCurrentItem()
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
         collectionView.register(HomeColorCell.self, forCellWithReuseIdentifier: "HomeColorCell")
         collectionView.showsVerticalScrollIndicator = false
         disablesAdjustScrollViewInsets(collectionView)

         settingConfig = try? SettingConfig.re.objects().first
         if HomePreferences.shared.startup == .last {
             currentMode = HomePreferences.shared.lastMode
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

         // 底部悬浮工具条
         view.addSubview(toolbar)
         NSLayoutConstraint.activate([
             toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DS.barBottomGap),
             toolbar.widthAnchor.constraint(equalToConstant: 316),
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
        collectionView.reloadData()
        if !displayItems.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: .top,
                                        animated: false)
        }
        rememberBrowsingPosition()
        refreshCurrentItem()
    }

    private func switchToMode(_ mode: HomeColorMode) {
        guard mode != currentMode else { return }

        // 记下离开前停在第几个，回来时接着看
        if collectionView.bounds.height > 0 {
            savedPositions[currentMode] = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        }
        currentMode = mode

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
        refreshCurrentItem()
    }

    private func rememberBrowsingPosition() {
        guard !needsInitialRestore, collectionView.bounds.height > 0 else { return }
        let row = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        guard displayItems.indices.contains(row) else { return }
        HomePreferences.shared.remember(mode: currentMode, colorID: displayItems[row].id, page: 0)
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
        if UIAccessibility.isReduceMotionEnabled { settleOnCurrentColor() }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeColorCell", for: indexPath) as! HomeColorCell
        cell.displayItem = displayItems[indexPath.row]
        cell.onShowInfo = { [weak self] in self?.showInfo() }
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { settleOnCurrentColor() }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { settleOnCurrentColor() }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { settleOnCurrentColor() }
    }

    /// 停稳在某个颜色上：记住位置，并让工具条对准它
    private func settleOnCurrentColor() {
        rememberBrowsingPosition()
        refreshCurrentItem()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        Feedback.lightPrepare()
    }
}
