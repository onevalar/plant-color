import Foundation

@main enum ColorHarmonyChecks {
    static func main() throws {
        let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
        let plants = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
        let colors = plants.map { RGBColor(hex: $0["colorHEX"] as! String)! }
        var count = 0
        func check(_ bg: RGBColor) {
            let p = BotanicalPalette.make(background: bg)
            precondition(p.background == bg, "Never alter the botanical background")
            precondition(bg.contrast(with: p.name) >= 3.99, "Name \(bg.hexString)")
            precondition(bg.contrast(with: p.summary) >= 4.5, "Small text \(bg.hexString)")
            precondition(p.glass.contrast(with: p.icon) >= 3.49, "Icon \(bg.hexString)")
            precondition(bg.contrast(with: p.artwork) >= 2.99, "Artwork \(bg.hexString)")
            precondition(p.usesDarkInk == (p.summary.relativeLuminance < bg.relativeLuminance))
            count += 1
        }
        for bg in colors { check(bg) }
        // Random-order paging can cross any pair, not just adjacent records.
        for a in colors {
            for b in colors where a != b {
                for t in [0.25, 0.5, 0.75] { check(a.mixed(with: b, fraction: t)) }
            }
        }
        for v in stride(from: 0, through: 255, by: 5) { check(RGBColor(r: v, g: v, b: v)) }
        for hex in ["#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#00FFFF", "#FF00FF"] { check(RGBColor(hex: hex)!) }
        print("PASS: \(count) backgrounds, including all 32 plants, every page pair, grayscale and saturated colors")
        let rows = zip(plants, colors).map { plant, bg -> [String: Any] in
            let p = BotanicalPalette.make(background: bg)
            return ["name": plant["plantName"]!, "background": bg.hexString,
                    "title": p.name.hexString, "summary": p.summary.hexString,
                    "icon": p.icon.hexString, "art": p.artwork.hexString, "darkInk": p.usesDarkInk]
        }
        if CommandLine.arguments.count > 2 {
            try JSONSerialization.data(withJSONObject: rows, options: [.prettyPrinted, .sortedKeys])
                .write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
        }
    }
}
