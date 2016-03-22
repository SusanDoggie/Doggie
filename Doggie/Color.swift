//
//  Color.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public struct Color {
    public var r, g, b, a: Double
}

extension Color {
    
    public var red: Double {
        get {
            return r
        }
        set {
            r = newValue
        }
    }
    public var green: Double {
        get {
            return g
        }
        set {
            g = newValue
        }
    }
    public var blue: Double {
        get {
            return b
        }
        set {
            b = newValue
        }
    }
    public var alpha: Double {
        get {
            return a
        }
        set {
            a = newValue
        }
    }
    
    public init() {
        self.init(r: 0, g: 0, b: 0, a: 0)
    }
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.init(r: red, g: green, b: blue, a: alpha)
    }
    public init(white: Double, alpha: Double) {
        self.init(r: white, g: white, b: white, a: alpha)
    }
    
    public static func Hex(colorCode: String) -> Color? {
        var colorCode = colorCode
        if colorCode[colorCode.startIndex] == "#" {
            colorCode.removeAtIndex(colorCode.startIndex)
        }
        let scanner = NSScanner(string: colorCode)
        var color: UInt32 = 0
        if scanner.scanHexInt(&color) {
            let r = UInt8((color >> 16) & 0xFF)
            let g = UInt8((color >> 8) & 0xFF)
            let b = UInt8(color & 0xFF)
            return Color(r: Double(r) / 255, g: Double(g) / 255, b: Double(b) / 255, a: 1)
        }
        return nil
    }
}

extension Color {
    
    private init (h: Double, c: Double, m: Double, a: Double) {
        var h = h
        h = h.isSignMinus ? fmod(h * 3.0 / M_PI, 6.0) + 6.0 : fmod(h * 3.0 / M_PI, 6.0)
        let x = c * (1.0 - abs(fmod(h, 2.0) - 1.0))
        self.init(r: m, g: m, b: m, a: a)
        switch floor(h) {
        case 0:
            self.r += c
            self.g += x
        case 1:
            self.r += x
            self.g += c
        case 2:
            self.g += c
            self.b += x
        case 3:
            self.g += x
            self.b += c
        case 4:
            self.r += x
            self.b += c
        case 5:
            self.r += c
            self.b += x
        default:
            break
        }
    }
    
    public init (hue h: Double, saturation s: Double, value v: Double, alpha a: Double) {
        let c = v * s
        let m = v - c
        self.init(h: h, c: c, m: m, a: a)
    }
    public init (hue h: Double, saturation s: Double, lightness l: Double, alpha a: Double) {
        let c = (1.0 - abs(2.0 * l - 1.0)) * s
        let m = l - c / 2.0
        self.init(h: h, c: c, m: m, a: a)
    }
    
}

extension Color {
    
    public var rgb: (red: Double, green: Double, blue: Double) {
        get {
            return (r, g, b)
        }
        mutating set {
            (r, g, b) = (newValue.red, newValue.green, newValue.blue)
        }
    }
    
    private var hcm: (Double, Double, Double) {
        get {
            let alpha = 2.0 * r - g - b
            let beta = (g - b) * M_SQRT3
            let h = fmod(atan2(beta, alpha), 2.0 * M_PI)
            let c = sqrt(alpha * alpha + beta * beta) / 2.0
            let m = min(r, g, b)
            return (h.isSignMinus ? h + 2.0 * M_PI : h, c, m)
        }
        mutating set {
            self = Color(h: newValue.0, c: newValue.1, m: newValue.2, a: self.a)
        }
    }
    
    public var hsv: (hue: Double, saturation: Double, value: Double) {
        get {
            let HCM = hcm
            let v = HCM.1 + HCM.2
            let s = HCM.1 == 0.0 ? 0.0 : HCM.1 / v
            return (HCM.0, s, v)
        }
        mutating set {
            self = Color(hue: newValue.hue, saturation: newValue.saturation, value: newValue.value, alpha: self.a)
        }
    }
    
    public var hsl: (hue: Double, saturation: Double, lightness: Double) {
        get {
            let HCM = hcm
            let l = HCM.1 / 2.0 + HCM.2
            let s = HCM.1 == 0.0 ? 0.0 : HCM.1 / (1.0 - abs(2.0 * l - 1.0))
            return (HCM.0, s, l)
        }
        mutating set {
            self = Color(hue: newValue.hue, saturation: newValue.saturation, lightness: newValue.lightness, alpha: self.a)
        }
    }
    
    var hsi: (hue: Double, saturation: Double, intensity: Double) {
        get {
            let HCM = hcm
            let i = (r + g + b) / 3.0
            let s = HCM.1 == 0.0 ? 0.0 : 1.0 - HCM.2 / i
            return (HCM.0, s, i)
        }
    }
    
}

extension Color {
    
    public var yuv: (y: Double, u: Double, v: Double) {
        get {
            let y =    0.299 * r +   0.587 * g +   0.114 * b
            let u = -0.14713 * r - 0.28886 * g +   0.436 * b
            let v =    0.615 * r - 0.51499 * g - 0.10001 * b
            return (y, u, v)
        }
        mutating set {
            r = newValue.y + 1.13983 * newValue.v
            g = newValue.y - 0.39465 * newValue.u - 0.58060 * newValue.v
            b = newValue.y + 2.03211 * newValue.u
        }
    }
}

public func mix(lhs: Color, rhs: Color) -> Color {
    let alpha = lhs.a + rhs.a * (1.0 - lhs.a)
    let red = (lhs.r * lhs.a + rhs.r * rhs.a * (1.0 - lhs.a)) / alpha
    let green = (lhs.g * lhs.a + rhs.g * rhs.a * (1.0 - lhs.a)) / alpha
    let blue = (lhs.b * lhs.a + rhs.b * rhs.a * (1.0 - lhs.a)) / alpha
    return Color(r: red, g: green, b: blue, a: alpha)
}

private let colorTable = ["lavender": "#E6E6FA", "black": "#000000", "olive": "#808000", "saddlebrown": "#8B4513", "lightcoral": "#F08080", "navy": "#000080", "burlywood": "#DEB887", "darkgoldenrod": "#B8860B", "deeppink": "#FF1493", "violet": "#EE82EE", "lime": "#00FF00", "dimgrey": "#696969", "indianred ": "#CD5C5C", "darkgray": "#A9A9A9", "mediumslateblue": "#7B68EE", "oldlace": "#FDF5E6", "snow": "#FFFAFA", "darkgreen": "#006400", "salmon": "#FA8072", "gold": "#FFD700", "aquamarine": "#7FFFD4", "slateblue": "#6A5ACD", "darkolivegreen": "#556B2F", "orchid": "#DA70D6", "navajowhite": "#FFDEAD", "powderblue": "#B0E0E6", "lightcyan": "#E0FFFF", "red": "#FF0000", "darkviolet": "#9400D3", "cyan": "#00FFFF", "darkmagenta": "#8B008B", "wheat": "#F5DEB3", "cornflowerblue": "#6495ED", "aqua": "#00FFFF", "palevioletred": "#DB7093", "moccasin": "#FFE4B5", "palegreen": "#98FB98", "khaki": "#F0E68C", "honeydew": "#F0FFF0", "orange": "#FFA500", "papayawhip": "#FFEFD5", "indigo": "#4B0082", "royalblue": "#4169E1", "lightyellow": "#FFFFE0", "mediumvioletred": "#C71585", "forestgreen": "#228B22", "lightslategrey": "#778899", "teal": "#008080", "lightslategray": "#778899", "magenta": "#FF00FF", "deepskyblue": "#00BFFF", "mediumblue": "#0000CD", "mediumspringgreen": "#00FA9A", "palegoldenrod": "#EEE8AA", "paleturquoise": "#AFEEEE", "bisque": "#FFE4C4", "peachpuff": "#FFDAB9", "darkred": "#8B0000", "mediumorchid": "#BA55D3", "mistyrose": "#FFE4E1", "lightseagreen": "#20B2AA", "turquoise": "#40E0D0", "darkslategray": "#2F4F4F", "lawngreen": "#7CFC00", "lightgoldenrodyellow": "#FAFAD2", "linen": "#FAF0E6", "grey": "#808080", "purple": "#800080", "blanchedalmond": "#FFEBCD", "antiquewhite": "#FAEBD7", "gainsboro": "#DCDCDC", "midnightblue": "#191970", "darksalmon": "#E9967A", "seashell": "#FFF5EE", "sandybrown": "#F4A460", "dimgray": "#696969", "azure": "#F0FFFF", "goldenrod": "#DAA520", "maroon": "#800000", "slategrey": "#708090", "greenyellow": "#ADFF2F", "gray": "#808080", "lightblue": "#ADD8E6", "cadetblue": "#5F9EA0", "crimson": "#DC143C", "peru": "#CD853F", "rebeccapurple": "#663399", "lightgrey": "#D3D3D3", "indigo ": "#4B0082", "limegreen": "#32CD32", "darkslateblue": "#483D8B", "brown": "#A52A2A", "floralwhite": "#FFFAF0", "hotpink": "#FF69B4", "orangered": "#FF4500", "blue": "#0000FF", "coral": "#FF7F50", "beige": "#F5F5DC", "darkslategrey": "#2F4F4F", "mediumaquamarine": "#66CDAA", "tan": "#D2B48C", "aliceblue": "#F0F8FF", "dodgerblue": "#1E90FF", "lavenderblush": "#FFF0F5", "lightpink": "#FFB6C1", "darkorchid": "#9932CC", "firebrick": "#B22222", "indianred": "#CD5C5C", "lightgray": "#D3D3D3", "mediumpurple": "#9370DB", "mediumturquoise": "#48D1CC", "pink": "#FFC0CB", "lightsalmon": "#FFA07A", "plum": "#DDA0DD", "seagreen": "#2E8B57", "slategray": "#708090", "darkkhaki": "#BDB76B", "olivedrab": "#6B8E23", "blueviolet": "#8A2BE2", "cornsilk": "#FFF8DC", "fuchsia": "#FF00FF", "darkturquoise": "#00CED1", "tomato": "#FF6347", "white": "#FFFFFF", "mediumseagreen": "#3CB371", "darkorange": "#FF8C00", "green": "#008000", "ghostwhite": "#F8F8FF", "rosybrown": "#BC8F8F", "lightsteelblue": "#B0C4DE", "chartreuse": "#7FFF00", "lemonchiffon": "#FFFACD", "steelblue": "#4682B4", "mintcream": "#F5FFFA", "silver": "#C0C0C0", "lightgreen": "#90EE90", "skyblue": "#87CEEB", "lightskyblue": "#87CEFA", "ivory": "#FFFFF0", "yellow": "#FFFF00", "sienna": "#A0522D", "yellowgreen": "#9ACD32", "chocolate": "#D2691E", "darkcyan": "#008B8B", "darkgrey": "#A9A9A9", "darkseagreen": "#8FBC8F", "springgreen": "#00FF7F", "darkblue": "#00008B", "thistle": "#D8BFD8", "whitesmoke": "#F5F5F5"]
