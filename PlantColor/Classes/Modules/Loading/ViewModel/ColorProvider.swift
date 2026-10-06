//
//  ColorProvider.swift
//  PlantColor
//
//  Created by insect on 2022/5/10.
//

import CleanJSON

class ColorProvider {

    static func fetchColors() -> [ColorModel] {
        
        guard
            let jsonPath = Bundle.main.path(forResource: "PlantColor", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath))
        else {
            print("[ColorProvider] 无法找到PlantColor.json文件或读取失败")
            assert(false, "请在主工程中配置一个 PlantColor.json 文件，具体结构参考文档")
            return []
        }
        
        do {
            let items: [ColorModel] = try CleanJSONDecoder().decode([ColorModel].self,
                                                                    from: jsonData)
            print("[ColorProvider] 成功解析\(items.count)个颜色模型")
            return items
        } catch {
            print("[ColorProvider] 解析PlantColor.json异常: \(error.localizedDescription)")
        }
        return []
    }
}
