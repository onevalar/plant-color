//
//  DeepLinkRouter.swift
//  PlantColor
//
//  处理 plantcolor://color/<plant|traditional>/<id>：从小组件直接跳到对应颜色的详情页。
//

import RealmSwift
import UIKit

final class DeepLinkRouter {

    static let shared = DeepLinkRouter()

    /// 数据还在导入、首页还没准备好时先记下来
    private var pending: URL?

    private init() {}

    static func url(kind: ColorKind, id: Int) -> URL? {
        URL(string: "\(WidgetKitHelper.urlScheme)://color/\(kind.rawValue)/\(id)")
    }

    func handle(_ url: URL) {
        guard url.scheme == WidgetKitHelper.urlScheme, url.host == "color" else { return }
        guard let navigation = UIApplication.keyWindow?.rootViewController as? UINavigationController,
              navigation.viewControllers.first is HomeViewController else {
            pending = url
            return
        }
        open(url, in: navigation)
    }

    func flushPending() {
        guard let url = pending else { return }
        pending = nil
        handle(url)
    }

    private func open(_ url: URL, in navigation: UINavigationController) {
        let parts = url.pathComponents.filter { $0 != "/" }
        guard parts.count == 2,
              let kind = ColorKind(rawValue: parts[0]),
              let id = Int(parts[1]) else { return }

        let item: (any ColorDisplayable)?
        switch kind {
        case .plant:
            let plant: ColorModel? = try? ColorModel.re.objects().where { $0.id == id }.first
            item = plant
        case .traditional:
            let traditional: TraditionalColorModel? = try? TraditionalColorModel.re.objects().where { $0.id == id }.first
            item = traditional
        }
        guard let item = item else { return }

        // 设置页、分享页等弹出层先收起，再回到首页并进入详情
        navigation.dismiss(animated: false)
        navigation.popToRootViewController(animated: false)
        navigation.pushViewController(item.makeDetailViewController(), animated: true)
    }
}
