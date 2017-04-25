//
//  ColorModel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

public protocol ColorModelProtocol {
    
    static var count: Int { get }
    
    init()
    
    func component(_ index: Int) -> Double
    mutating func setComponent(_ index: Int, _ value: Double)
    
    var hashValue: Int { get }
}

extension ColorModelProtocol {
    
    @_inlineable
    public var hashValue: Int {
        var hash = 0
        for i in 0..<Self.count {
            hash = hash_combine(seed: hash, self.component(i))
        }
        return hash
    }
}

@_fixed_layout
public struct ColorModelComponentCollection<Model: ColorModelProtocol>: RandomAccessCollection {
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public let base: Model
    
    @_inlineable
    public init(base: Model) {
        self.base = base
    }
    
    @_inlineable
    public var startIndex: Int {
        return 0
    }
    @_inlineable
    public var endIndex: Int {
        return Model.count
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        _failEarlyRangeCheck(position, bounds: startIndex..<endIndex)
        return base.component(position)
    }
}

extension ColorModelProtocol {
    
    @_inlineable
    public var components: ColorModelComponentCollection<Self> {
        return ColorModelComponentCollection(base: self)
    }
}

@_inlineable
public prefix func +<Model : ColorModelProtocol>(val: Model) -> Model {
    return val
}
@_inlineable
public prefix func -<Model : ColorModelProtocol>(val: Model) -> Model {
    var val = val
    for i in 0..<Model.count {
        val.setComponent(i, -val.component(i))
    }
    return val
}
@_inlineable
public func +<Model : ColorModelProtocol>(lhs: Model, rhs:  Model) -> Model {
    var result = Model()
    for i in 0..<Model.count {
        result.setComponent(i, lhs.component(i) + rhs.component(i))
    }
    return result
}
@_inlineable
public func -<Model : ColorModelProtocol>(lhs: Model, rhs:  Model) -> Model {
    var result = Model()
    for i in 0..<Model.count {
        result.setComponent(i, lhs.component(i) - rhs.component(i))
    }
    return result
}

@_inlineable
public func *<Model : ColorModelProtocol>(lhs: Double, rhs:  Model) -> Model {
    var result = Model()
    for i in 0..<Model.count {
        result.setComponent(i, lhs * rhs.component(i))
    }
    return result
}
@_inlineable
public func *<Model : ColorModelProtocol>(lhs: Model, rhs:  Double) -> Model {
    var result = Model()
    for i in 0..<Model.count {
        result.setComponent(i, lhs.component(i) * rhs)
    }
    return result
}

@_inlineable
public func /<Model : ColorModelProtocol>(lhs: Model, rhs:  Double) -> Model {
    var result = Model()
    for i in 0..<Model.count {
        result.setComponent(i, lhs.component(i) / rhs)
    }
    return result
}

@_inlineable
public func *=<Model : ColorModelProtocol> (lhs: inout Model, rhs:  Double) {
    for i in 0..<Model.count {
        lhs.setComponent(i, lhs.component(i) * rhs)
    }
}
@_inlineable
public func /=<Model : ColorModelProtocol> (lhs: inout Model, rhs:  Double) {
    for i in 0..<Model.count {
        lhs.setComponent(i, lhs.component(i) / rhs)
    }
}
@_inlineable
public func +=<Model : ColorModelProtocol> (lhs: inout Model, rhs:  Model) {
    for i in 0..<Model.count {
        lhs.setComponent(i, lhs.component(i) + rhs.component(i))
    }
}
@_inlineable
public func -=<Model : ColorModelProtocol> (lhs: inout Model, rhs:  Model) {
    for i in 0..<Model.count {
        lhs.setComponent(i, lhs.component(i) - rhs.component(i))
    }
}
@_inlineable
public func ==<Model : ColorModelProtocol>(lhs: Model, rhs: Model) -> Bool {
    for i in 0..<Model.count where lhs.component(i) != rhs.component(i) {
        return false
    }
    return true
}
@_inlineable
public func !=<Model : ColorModelProtocol>(lhs: Model, rhs: Model) -> Bool {
    for i in 0..<Model.count where lhs.component(i) != rhs.component(i) {
        return true
    }
    return false
}

public protocol ColorVectorConvertible : ColorModelProtocol {
    
    init(_ vector: Vector)
    
    var vector: Vector { get set }
}

extension ColorVectorConvertible {
    
    @_inlineable
    public init() {
        self.init(Vector())
    }
}

@_inlineable
public func * <C: ColorVectorConvertible>(lhs: C, rhs: Matrix) -> Vector {
    return lhs.vector * rhs
}

@_inlineable
public func *= <C: ColorVectorConvertible>(lhs: inout C, rhs: Matrix) {
    lhs.vector *= rhs
}

public struct RGBColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    public var red: Double
    public var green: Double
    public var blue: Double
    
    @_inlineable
    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return red
        case 1: return green
        case 2: return blue
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: red = value
        case 1: green = value
        case 2: blue = value
        default: fatalError()
        }
    }
}

extension RGBColorModel : ColorVectorConvertible {
    
    @_inlineable
    public init(_ vector: Vector) {
        self.red = vector.x
        self.green = vector.y
        self.blue = vector.z
    }
    
    @_inlineable
    public var vector: Vector {
        get {
            return Vector(x: red, y: green, z: blue)
        }
        set {
            self.red = newValue.x
            self.green = newValue.y
            self.blue = newValue.z
        }
    }
}

extension RGBColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "RGBColorModel(red: \(red), green: \(green), blue: \(blue))"
    }
}

extension RGBColorModel {
    
    @_inlineable
    public init(_ hex: UInt32) {
        self.red = Double((hex >> 16) & 0xFF) / 255
        self.green = Double((hex >> 8) & 0xFF) / 255
        self.blue = Double(hex & 0xFF) / 255
    }
}

extension RGBColorModel {
    
    @_inlineable
    public init(_ gray: GrayColorModel) {
        self.red = gray.white
        self.green = gray.white
        self.blue = gray.white
    }
    
    @_inlineable
    public init(_ cmyk: CMYKColorModel) {
        let _k = 1 - cmyk.black
        let _cyan = cmyk.cyan * _k + cmyk.black
        let _magenta = cmyk.magenta * _k + cmyk.black
        let _yellow = cmyk.yellow * _k + cmyk.black
        self.red = 1 - _cyan
        self.green = 1 - _magenta
        self.blue = 1 - _yellow
    }
}

extension RGBColorModel {
    
    @_inlineable
    public init(hue: Double, saturation: Double, brightness: Double) {
        let _hue = positive_mod(hue, 1) * 6
        let __hue = Int(_hue)
        let c = brightness * saturation
        let x = c * (1 - abs(positive_mod(_hue, 2) - 1))
        let m = brightness - c
        switch __hue {
        case 0:
            self.red = c + m
            self.green = x + m
            self.blue = m
        case 1:
            self.red = x + m
            self.green = c + m
            self.blue = m
        case 2:
            self.red = m
            self.green = c + m
            self.blue = x + m
        case 3:
            self.red = m
            self.green = x + m
            self.blue = c + m
        case 4:
            self.red = x + m
            self.green = m
            self.blue = c + m
        default:
            self.red = c + m
            self.green = m
            self.blue = x + m
        }
    }
}

extension RGBColorModel {
    
    @_inlineable
    public var hue: Double {
        get {
            let _max = max(red, green, blue)
            let _min = min(red, green, blue)
            let c = _max - _min
            if c == 0 {
                return 0
            }
            switch _max {
            case red: return positive_mod((green - blue) / (6 * c), 1)
            case green: return positive_mod((blue - red) / (6 * c) + 2 / 6, 1)
            case blue: return positive_mod((red - green) / (6 * c) + 4 / 6, 1)
            default: return 0
            }
        }
        set {
            let _max = max(red, green, blue)
            let _min = min(red, green, blue)
            self = RGBColorModel(hue: newValue, saturation: _max == 0 ? 0 : (_max - _min) / _max, brightness: _max)
        }
    }
    
    @_inlineable
    public var saturation: Double {
        get {
            let _max = max(red, green, blue)
            let _min = min(red, green, blue)
            return _max == 0 ? 0 : (_max - _min) / _max
        }
        set {
            self = RGBColorModel(hue: hue, saturation: newValue, brightness: brightness)
        }
    }
    
    @_inlineable
    public var brightness: Double {
        get {
            return max(red, green, blue)
        }
        set {
            self = RGBColorModel(hue: hue, saturation: saturation, brightness: newValue)
        }
    }
}

public struct CMYKColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 4
    }
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    public var black: Double
    
    @_inlineable
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double) {
        self.cyan = cyan
        self.magenta = magenta
        self.yellow = yellow
        self.black = black
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return cyan
        case 1: return magenta
        case 2: return yellow
        case 3: return black
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: cyan = value
        case 1: magenta = value
        case 2: yellow = value
        case 3: black = value
        default: fatalError()
        }
    }
}

extension CMYKColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "CMYKColorModel(cyan: \(cyan), magenta: \(magenta), yellow: \(yellow), black: \(black))"
    }
}

extension CMYKColorModel {
    
    @_inlineable
    public init() {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
        self.black = 0
    }
}

extension CMYKColorModel {
    
    @_inlineable
    public init(_ gray: GrayColorModel) {
        self.cyan = 0
        self.magenta = 0
        self.yellow = 0
        self.black = 1 - gray.white
    }
    
    @_inlineable
    public init(_ rgb: RGBColorModel) {
        let _cyan = 1 - rgb.red
        let _magenta = 1 - rgb.green
        let _yellow = 1 - rgb.blue
        self.black = min(_cyan, _magenta, _yellow)
        if black == 1 {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        } else {
            let _k = 1 / (1 - black)
            self.cyan = _k * (_cyan - black)
            self.magenta = _k * (_magenta - black)
            self.yellow = _k * (_yellow - black)
        }
    }
}

public struct LabColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    /// The lightness dimension.
    public var lightness: Double
    /// The a color component.
    public var a: Double
    /// The b color component.
    public var b: Double
    
    @_inlineable
    public init() {
        self.lightness = 0
        self.a = 0
        self.b = 0
    }
    
    @_inlineable
    public init(lightness: Double, a: Double, b: Double) {
        self.lightness = lightness
        self.a = a
        self.b = b
    }
    @_inlineable
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.a = chroma * cos(2 * Double.pi * hue)
        self.b = chroma * sin(2 * Double.pi * hue)
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return lightness
        case 1: return a
        case 2: return b
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: lightness = value
        case 1: a = value
        case 2: b = value
        default: fatalError()
        }
    }
}

extension LabColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "LabColorModel(lightness: \(lightness), a: \(a), b: \(b))"
    }
}

extension LabColorModel {
    
    @_inlineable
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(b, a) / Double.pi, 1)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @_inlineable
    public var chroma: Double {
        get {
            return sqrt(a * a + b * b)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

public struct LuvColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    /// The lightness dimension.
    public var lightness: Double
    /// The u color component.
    public var u: Double
    /// The v color component.
    public var v: Double
    
    @_inlineable
    public init() {
        self.lightness = 0
        self.u = 0
        self.v = 0
    }
    @_inlineable
    public init(lightness: Double, u: Double, v: Double) {
        self.lightness = lightness
        self.u = u
        self.v = v
    }
    @_inlineable
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.u = chroma * cos(2 * Double.pi * hue)
        self.v = chroma * sin(2 * Double.pi * hue)
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return lightness
        case 1: return u
        case 2: return v
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: lightness = value
        case 1: u = value
        case 2: v = value
        default: fatalError()
        }
    }
}

extension LuvColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "LuvColorModel(lightness: \(lightness), u: \(u), v: \(v))"
    }
}

extension LuvColorModel {
    
    @_inlineable
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(v, u) / Double.pi, 1)
        }
        set {
            self = LuvColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @_inlineable
    public var chroma: Double {
        get {
            return sqrt(u * u + v * v)
        }
        set {
            self = LuvColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

public struct XYZColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    public var x: Double
    public var y: Double
    public var z: Double
    
    @_inlineable
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    @_inlineable
    public init(luminance: Double, point: Point) {
        self.init(luminance: luminance, x: point.x, y: point.y)
    }
    
    @_inlineable
    public init(luminance: Double, x: Double, y: Double) {
        let _y = 1 / y
        self.x = x * _y * luminance
        self.y = luminance
        self.z = (1 - x - y) * _y * luminance
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return x
        case 1: return y
        case 2: return z
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: x = value
        case 1: y = value
        case 2: z = value
        default: fatalError()
        }
    }
}

extension XYZColorModel {
    
    @_inlineable
    public var luminance: Double {
        get {
            return y
        }
        set {
            self = XYZColorModel(luminance: newValue, point: point)
        }
    }
    
    @_inlineable
    public var point: Point {
        get {
            return Point(x: x, y: y) / (x + y + z)
        }
        set {
            self = XYZColorModel(luminance: luminance, point: newValue)
        }
    }
}

extension XYZColorModel : ColorVectorConvertible {
    
    @_inlineable
    public init(_ vector: Vector) {
        self.x = vector.x
        self.y = vector.y
        self.z = vector.z
    }
    
    @_inlineable
    public var vector: Vector {
        get {
            return Vector(x: x, y: y, z: z)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
            self.z = newValue.z
        }
    }
}

extension XYZColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "XYZColorModel(x: \(x), y: \(y), z: \(z))"
    }
}

public struct GrayColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 1
    }
    
    public var white: Double
    
    @_inlineable
    public init(white: Double) {
        self.white = white
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return white
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: white = value
        default: fatalError()
        }
    }
}

extension GrayColorModel {
    
    @_inlineable
    public init() {
        self.white = 0
    }
}
