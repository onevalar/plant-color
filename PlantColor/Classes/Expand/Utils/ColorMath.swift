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
