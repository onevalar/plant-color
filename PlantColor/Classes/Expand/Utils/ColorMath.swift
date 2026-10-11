//
//  ColorMath.swift
//  PlantColor
//
//  色值换算：HEX / RGB / HSL / Lab，以及两个颜色之间的差异。
//

import Foundation

struct RGBColor: Equatable {

    let r: Int
    let g: Int
    let b: Int

    init(r: Int, g: Int, b: Int) {
        self.r = min(max(r, 0), 255)
        self.g = min(max(g, 0), 255)
        self.b = min(max(b, 0), 255)
    }

    /// 支持 "#F9F4DC" / "F9F4DC"
    init?(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard clean.count == 6, let value = UInt32(clean, radix: 16) else { return nil }
        self.init(r: Int((value >> 16) & 0xFF),
                  g: Int((value >> 8) & 0xFF),
                  b: Int(value & 0xFF))
    }

    var hexString: String {
        String(format: "#%02X%02X%02X", r, g, b)
    }

    // MARK: - HSL

    /// h: 0..<360，s / l: 0...1
    var hsl: (h: Double, s: Double, l: Double) {
        let rf = Double(r) / 255, gf = Double(g) / 255, bf = Double(b) / 255
        let maxC = max(rf, gf, bf), minC = min(rf, gf, bf)
        let delta = maxC - minC
        let l = (maxC + minC) / 2
        guard delta > 0 else { return (0, 0, l) }

        let s = delta / (1 - abs(2 * l - 1))
        var h: Double
        if maxC == rf {
            h = 60 * fmod((gf - bf) / delta, 6)
        } else if maxC == gf {
            h = 60 * ((bf - rf) / delta + 2)
        } else {
            h = 60 * ((rf - gf) / delta + 4)
        }
        if h < 0 { h += 360 }
        return (h, s, l)
    }

    init(h: Double, s: Double, l: Double) {
        let hue = fmod(fmod(h, 360) + 360, 360)
        let sat = min(max(s, 0), 1)
        let lig = min(max(l, 0), 1)
        let c = (1 - abs(2 * lig - 1)) * sat
        let x = c * (1 - abs(fmod(hue / 60, 2) - 1))
        let m = lig - c / 2
        let (rp, gp, bp): (Double, Double, Double)
        switch hue {
        case 0..<60: (rp, gp, bp) = (c, x, 0)
        case 60..<120: (rp, gp, bp) = (x, c, 0)
        case 120..<180: (rp, gp, bp) = (0, c, x)
        case 180..<240: (rp, gp, bp) = (0, x, c)
        case 240..<300: (rp, gp, bp) = (x, 0, c)
        default: (rp, gp, bp) = (c, 0, x)
        }
        self.init(r: Int(round((rp + m) * 255)),
                  g: Int(round((gp + m) * 255)),
                  b: Int(round((bp + m) * 255)))
    }

    /// 色相旋转，保持明度与饱和度
    func rotatedHue(by degrees: Double) -> RGBColor {
        let value = hsl
        return RGBColor(h: value.h + degrees, s: value.s, l: value.l)
    }

    /// 黑白灰一类几乎没有色相的颜色
    var isNeutral: Bool {
        hsl.s < 0.1
    }

    // MARK: - Lab（用于衡量"看起来有多接近"）

    var lab: (l: Double, a: Double, b: Double) {
        func linear(_ value: Int) -> Double {
            let c = Double(value) / 255
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        let rl = linear(r), gl = linear(g), bl = linear(b)
        let x = (rl * 0.4124564 + gl * 0.3575761 + bl * 0.1804375) / 0.95047
        let y = rl * 0.2126729 + gl * 0.7151522 + bl * 0.0721750
        let z = (rl * 0.0193339 + gl * 0.1191920 + bl * 0.9503041) / 1.08883

        func f(_ t: Double) -> Double {
            t > 0.008856 ? cbrt(t) : 7.787 * t + 16.0 / 116.0
        }
        let fx = f(x), fy = f(y), fz = f(z)
        return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))
    }

    /// 色度：颜色的"鲜艳程度"。比 HSL 的饱和度更贴近眼睛的感觉
    /// （HSL 里很浅的粉彩色饱和度也会很高）。大约 0 为灰色，纯红约 100
    var chroma: Double {
        let value = lab
        return sqrt(value.a * value.a + value.b * value.b)
    }

    /// 色差（CIE76），数值越小越接近，约 2.3 以内人眼几乎看不出区别
    func distance(to other: RGBColor) -> Double {
        let p = lab, q = other.lab
        let dl = p.l - q.l, da = p.a - q.a, db = p.b - q.b
        return sqrt(dl * dl + da * da + db * db)
    }
}

// MARK: - Botanical harmony (shared by the app and widget)

extension RGBColor {
    var components: [Double] { [Double(r) / 255, Double(g) / 255, Double(b) / 255] }
    private static func linear(_ c: Double) -> Double {
        c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
    }
    var relativeLuminance: Double {
        let c = components.map(Self.linear)
        return c[0] * 0.2126 + c[1] * 0.7152 + c[2] * 0.0722
    }
    func contrast(with other: RGBColor) -> Double {
        let a = relativeLuminance, b = other.relativeLuminance
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }
    func mixed(with other: RGBColor, fraction: Double) -> RGBColor {
        let t = min(max(fraction, 0), 1)
        return Self.quantized(zip(components, other.components).map { $0 * (1 - t) + $1 * t })
    }
    fileprivate static func quantized(_ values: [Double]) -> RGBColor {
        let c = values.map { Int((min(max($0, 0), 1) * 255).rounded()) }
        return RGBColor(r: c[0], g: c[1], b: c[2])
    }
    fileprivate var oklch: (l: Double, c: Double, h: Double) {
        let rgb = components.map(Self.linear), r = rgb[0], g = rgb[1], b = rgb[2]
        let l = cbrt(0.4122214708*r + 0.5363325363*g + 0.0514459929*b)
        let m = cbrt(0.2119034982*r + 0.6806995451*g + 0.1073969566*b)
        let s = cbrt(0.0883024619*r + 0.2817188376*g + 0.6299787005*b)
        let lightness = 0.2104542553*l + 0.793617785*m - 0.0040720468*s
        let a = 1.9779984951*l - 2.428592205*m + 0.4505937099*s
        let bAxis = 0.0259040371*l + 0.7827717662*m - 0.808675766*s
        return (lightness, hypot(a, bAxis), atan2(bAxis, a))
    }
    fileprivate static func oklch(l: Double, c: Double, h: Double) -> RGBColor {
        func linear(_ chroma: Double) -> [Double] {
            let a = chroma * cos(h), b = chroma * sin(h)
            let x = pow(l + 0.3963377774*a + 0.2158037573*b, 3)
            let y = pow(l - 0.1055613458*a - 0.0638541728*b, 3)
            let z = pow(l - 0.0894841775*a - 1.291485548*b, 3)
            return [4.0767416621*x - 3.3077115913*y + 0.2309699292*z,
                    -1.2684380046*x + 2.6097574011*y - 0.3413193965*z,
                    -0.0041960863*x - 0.7034186147*y + 1.707614701*z]
        }
        func fits(_ chroma: Double) -> Bool { linear(chroma).allSatisfy { $0 >= -1e-5 && $0 <= 1.00001 } }
        var chroma = c
        if !fits(chroma) {
            var low = 0.0, high = c
            for _ in 0..<22 {
                let mid = (low + high) / 2
                if fits(mid) { low = mid } else { high = mid }
            }
            chroma = low
        }
        return quantized(linear(chroma).map {
            let v = min(max($0, 0), 1)
            return v <= 0.0031308 ? 12.92*v : 1.055*pow(v, 1/2.4)-0.055
        })
    }
}

struct BotanicalPalette {
    let background: RGBColor
    let name: RGBColor
    let summary: RGBColor
    let icon: RGBColor
    let artwork: RGBColor
    let glass: RGBColor
    let usesDarkInk: Bool

    /// Preview standard: same hue/chroma; find the nearest lightness meeting each role's target.
    /// Rounded 8-bit colors are tested, not unquantized intermediate values.
    static func make(background: RGBColor) -> BotanicalPalette {
        let lch = background.oklch
        let black = RGBColor(r: 0, g: 0, b: 0), white = RGBColor(r: 255, g: 255, b: 255)
        func candidate(dark: Bool) -> (palette: BotanicalPalette, valid: Bool, cost: Double) {
            let end = dark ? 0.0 : 1.0
            let glass = background.mixed(with: dark ? white : black, fraction: dark ? 0.18 : 0.14)
            func solve(_ reference: RGBColor, _ target: Double) -> (rgb: RGBColor, move: Double, valid: Bool) {
                func at(_ t: Double) -> RGBColor { .oklch(l: lch.l + (end-lch.l)*t, c: lch.c, h: lch.h) }
                guard reference.contrast(with: at(1)) >= target else { return (at(1), abs(end-lch.l), false) }
                var low = 0.0, high = 1.0
                for _ in 0..<26 {
                    let mid = (low+high)/2
                    if reference.contrast(with: at(mid)) >= target { high = mid } else { low = mid }
                }
                return (at(high), abs(end-lch.l)*high, true)
            }
            let name = solve(background, 4), summary = solve(background, 4.6)
            let icon = solve(glass, 3.5), art = solve(background, 3)
            let all = [name, summary, icon, art]
            return (BotanicalPalette(background: background, name: name.rgb, summary: summary.rgb,
                                     icon: icon.rgb, artwork: art.rgb, glass: glass, usesDarkInk: dark),
                    all.allSatisfy { $0.valid }, all.map { $0.move }.max() ?? 0)
        }
        let dark = candidate(dark: true), light = candidate(dark: false)
        if dark.valid && light.valid { return dark.cost <= light.cost ? dark.palette : light.palette }
        if dark.valid { return dark.palette }
        if light.valid { return light.palette }
        // At some midtones 4.6 is impossible even for black/white. Best polarity still exceeds 4.5.
        return background.contrast(with: black) >= background.contrast(with: white) ? dark.palette : light.palette
    }
}
