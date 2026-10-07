//
//  ColorImporter.swift
//  PlantColor
//
//  把随 App 打包的颜色数据（JSON）导入本地数据库，同时保留用户的收藏。
//

import DefaultsKit
import RealmSwift
import UIKit

enum ColorImporter {

    /// 导入规则（代码）有变化时加 1。
    private static let importRuleRevision = 2

    /// 数据"指纹"：由两个 JSON 文件的内容和导入规则版本算出。
    /// 内容有任何变化指纹就会变，App 启动时发现和上次导入时不一样，就会重新导入。
    /// （以前只看 App 版本号：改了 JSON 却忘了升版本号，用户手机上就不会更新。）
    static var currentFingerprint: String {
        let names = ["PlantColor", "chinese_traditional_colors"]
        let parts = names.map { name -> String in
            guard let path = Bundle.main.path(forResource: name, ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return "missing" }
            return fnv1a(data)
        }
        return "\(importRuleRevision)-" + parts.joined(separator: "-")
    }

    static var needsImport: Bool {
        guard let lastBuild = Defaults().get(for: AppKey.buildNumberKey),
              let build = UIApplication.buildNumber,
              build == lastBuild else { return true }
        return Defaults().get(for: AppKey.dataFingerprintKey) != currentFingerprint
    }

    /// FNV-1a 64 位哈希：简单、够快，用来判断文件内容有没有变
    private static func fnv1a(_ data: Data) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        data.withUnsafeBytes { buffer in
            for byte in buffer {
                hash ^= UInt64(byte)
                hash = hash &* 0x100000001b3
            }
        }
        return String(hash, radix: 16)
    }

    /// 在后台一次性写入全部数据（单个事务），完成后回到主线程回调
    static func run(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let plants: [ColorModel] = ColorProvider.fetchColors()
            let traditional: [TraditionalColorModel] = TraditionalColorProvider.fetchColors()

            do {
                let realm = try Realm(configuration: ColorModel.re.createConfiguration())
                let collectedPlants = Set(realm.objects(ColorModel.self).filter("isCollect == true").map(\.id))
                let collectedTraditional = Set(realm.objects(TraditionalColorModel.self).filter("isCollect == true").map(\.id))

                try realm.write {
                    for item in plants {
                        item.isCollect = collectedPlants.contains(item.id)
                    }
                    for item in traditional {
                        item.isCollect = collectedTraditional.contains(item.id)
                    }
                    // 数据变少时，清掉已经不存在的旧颜色
                    let plantIDs = plants.map(\.id)
                    let traditionalIDs = traditional.map(\.id)
                    realm.delete(realm.objects(ColorModel.self).filter("NOT id IN %@", plantIDs))
                    realm.delete(realm.objects(TraditionalColorModel.self).filter("NOT id IN %@", traditionalIDs))
                    realm.add(plants, update: .all)
                    realm.add(traditional, update: .all)
                }
                AppLogger.shared.info("颜色数据导入完成：植物色 \(plants.count)，传统色 \(traditional.count)")
            } catch {
                AppLogger.shared.error("颜色数据导入失败: \(error.localizedDescription)")
            }

            let fingerprint = currentFingerprint
            DispatchQueue.main.async {
                Defaults().set(UIApplication.buildNumber ?? "", for: AppKey.buildNumberKey)
                Defaults().set(fingerprint, for: AppKey.dataFingerprintKey)
                ColorCatalog.shared.invalidate()
                WidgetPlaylist.rebuild()
                completion()
            }
        }
    }
}
