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

    /// 整屏背景色：随滚动在相邻两个颜色之间连续过渡，页与页之间没有"硬切"的色边
    let backgroundColorView = UIView()
    private var lastStyleRow = -1

    private lazy var topBar: HomeTopBar = {
        let bar = HomeTopBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.onModeChange = { [weak self] in self?.switchToMode($0) }
        bar.onSettings = { [weak self] in
            self?.present(NavigationController(rootViewController: SettingViewController()), animated: true)
        }
        bar.onSearch = { [weak self] in
            self?.navigationController?.pushViewController(ColorLibraryViewController(type: .all), animated: true)
        }
        return bar
    }()

    private lazy var actionBar: HomeActionBar = {
        let bar = HomeActionBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.onInfo = { [weak self] in self?.showInfo() }
        bar.onShare = { [weak self] in
            guard let item = self?.currentItem else { return }
            self?.present(NavigationController(rootViewController: ShareViewController(item: item)), animated: true)
        }
        return bar
    }()

    /// 屏幕上正在显示的颜色
    private var currentItem: (any ColorDisplayable)? {
        guard collectionView.bounds.height > 0 else { return displayItems.first }
        let row = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        return displayItems.indices.contains(row) ? displayItems[row] : displayItems.first
    }

    /// 让悬浮控件的颜色、操作对象跟上当前色块
    private func refreshCurrentItem() {
        guard let item = currentItem else { return }
        actionBar.item = item
        // 玻璃的明暗跟着色块走：浅色块上用浅色玻璃，深色块上用深色玻璃
        let isLightColor = (RGBColor(hex: item.colorHEX)?.lab.l ?? 60) > 60
        topBar.apply(ink: item.textUIColor, style: isLightColor ? .light : .dark)
        actionBar.overrideUserInterfaceStyle = isLightColor ? .light : .dark
    }

    private func showInfo() {
        guard let item = currentItem else { return }
        let sheet = ColorInfoSheetViewController(item: item) { [weak self] in
            self?.navigationController?.pushViewController(item.makeDetailViewController(), animated: true)
        }
        present(sheet, animated: !UIAccessibility.isReduceMotionEnabled)
    }

    private var storedTimer: SwiftTimer?

    /// 自动切换用的定时器（用到时才创建；销毁时不能再触发创建，否则会在释放过程中引用自己）
    private var timer: SwiftTimer {
        if let storedTimer { return storedTimer }
        let created = SwiftTimer.repeaticTimer(interval: .seconds(Int(switchInterval))) { [weak self] _ in
            self?.autoScroll()
        }
        storedTimer = created
        return created
    }

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
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startTimerIfNeeded()
        refreshCurrentItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        // 调试用：用环境变量把首页停在两页之间，方便截图检查过渡效果
        if let raw = ProcessInfo.processInfo.environment["PLANT_DEBUG_PAGE_POSITION"], let position = Double(raw) {
            collectionView.contentOffset.y = CGFloat(position) * collectionView.bounds.height
        }
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 首页自己不显示导航栏；进入其它页面时让它们用系统导航栏
        if presentedViewController == nil {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
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
        updateBlend()
        refreshCurrentItem()
    }

    deinit {
        settingToken?.invalidate()
        storedTimer?.suspend()
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

         view.backgroundColor = .systemBackground
         view.insertSubview(backgroundColorView, at: 0)
         backgroundColorView.frame = view.bounds
         backgroundColorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         collectionView.backgroundColor = .clear
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
         topBar.showsModeSwitch = FeatureFlags.traditionalColorsEnabled
         if HomePreferences.shared.startup == .last, FeatureFlags.traditionalColorsEnabled {
             currentMode = HomePreferences.shared.lastMode
         }
         topBar.select(currentMode)

         isShuffled = settingConfig?.randomSwitching ?? false
         loadItems()
         collectionView.reloadData()
         observeSettingChanges()

         // 悬浮控件：顶部（设置 · 切换 · 搜索）、底部（收藏 · 简介 · 分享）
         view.addSubview(topBar)
         view.addSubview(actionBar)
         NSLayoutConstraint.activate([
             topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
             topBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
             topBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
             actionBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             actionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DS.barBottomGap),
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

        if !FeatureFlags.traditionalColorsEnabled {
            traditionalItems = []
        } else {
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
        updateBlend()
        refreshCurrentItem()
    }

    private func switchToMode(_ mode: HomeColorMode) {
        guard mode != currentMode else { return }

        // 记下离开前停在第几个，回来时接着看
        if collectionView.bounds.height > 0 {
            savedPositions[currentMode] = Int(round(collectionView.contentOffset.y / collectionView.bounds.height))
        }
        currentMode = mode

        let swap = { [self] in
            displayItems = mode == .botanical ? botanicalItems : traditionalItems
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            let rememberedID = HomePreferences.shared.position(for: mode)?.colorID
            let position = savedPositions[mode] ?? rememberedID.flatMap { id in displayItems.firstIndex { $0.id == id } } ?? 0
            let row = displayItems.indices.contains(position) ? position : 0
            collectionView.contentOffset = CGPoint(x: 0, y: CGFloat(row) * collectionView.bounds.height)
            updateBlend()
            refreshCurrentItem()
        }
        // 两套颜色整体交叉淡入淡出，而不是瞬间换掉
        if UIAccessibility.isReduceMotionEnabled {
            swap()
        } else {
            UIView.transition(with: view, duration: 0.35, options: [.transitionCrossDissolve, .allowUserInteraction], animations: swap)
        }
        rememberBrowsingPosition()
    }

    // MARK: - 连续的颜色过渡

    /// 背景色随滚动位置在相邻两个颜色之间渐变；每一页的内容随离开中心的程度淡出。
    /// 这样翻页时看到的是"颜色慢慢洇开"，而不是一块色块硬生生顶走另一块。
    private func updateBlend() {
        let height = collectionView.bounds.height
        guard height > 0, !displayItems.isEmpty else { return }
        let position = min(max(collectionView.contentOffset.y / height, 0), CGFloat(displayItems.count - 1))
        let lower = Int(floor(position))
        let upper = min(lower + 1, displayItems.count - 1)
        let fraction = position - CGFloat(lower)
        backgroundColorView.backgroundColor = Self.blend(displayItems[lower].color, displayItems[upper].color, fraction)

        for cell in collectionView.visibleCells {
            guard let colorCell = cell as? HomeColorCell else { continue }
            let offset = (cell.frame.midY - (collectionView.contentOffset.y + height / 2)) / height
            colorCell.setTransition(progress: offset)
        }
        // 控件的明暗在过半时切换，避免在中间态来回闪
        let row = Int(round(position))
        if row != lastStyleRow {
            lastStyleRow = row
            refreshCurrentItem()
        }
    }

    private static func blend(_ from: UIColor, _ to: UIColor, _ t: CGFloat) -> UIColor {
        var a: (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0), b = a
        from.getRed(&a.0, green: &a.1, blue: &a.2, alpha: &a.3)
        to.getRed(&b.0, green: &b.1, blue: &b.2, alpha: &b.3)
        return UIColor(red: a.0 + (b.0 - a.0) * t, green: a.1 + (b.1 - a.1) * t, blue: a.2 + (b.2 - a.2) * t, alpha: 1)
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
        cell.setTransition(progress: 0)
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) { updateBlend() }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { settleOnCurrentColor() }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { settleOnCurrentColor() }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { settleOnCurrentColor() }
    }

    /// 停稳在某个颜色上：记住位置，并让工具条对准它
    private func settleOnCurrentColor() {
        rememberBrowsingPosition()
        updateBlend()
        refreshCurrentItem()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        Feedback.lightPrepare()
    }
}
