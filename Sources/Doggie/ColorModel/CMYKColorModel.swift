//
//  CMYKColorModel.swift
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

public struct CMYKColorModel : ColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_inlineable
    public static var numberOfComponents: Int {
        return 4
    }
    
    @_inlineable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
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
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return cyan
            case 1: return magenta
            case 2: return yellow
            case 3: return black
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: cyan = newValue
            case 1: magenta = newValue
            case 2: yellow = newValue
            case 3: black = newValue
            default: fatalError()
            }
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
        self.init(CMYColorModel(rgb))
    }
    
    @_inlineable
    public init(_ cmy: CMYColorModel) {
        self.black = Swift.min(cmy.cyan, cmy.magenta, cmy.yellow)
        if black == 1 {
            self.cyan = 0
            self.magenta = 0
            self.yellow = 0
        } else {
            let _k = 1 / (1 - black)
            self.cyan = _k * (cmy.cyan - black)
            self.magenta = _k * (cmy.magenta - black)
            self.yellow = _k * (cmy.yellow - black)
        }
    }
}

@_inlineable
public prefix func +(val: CMYKColorModel) -> CMYKColorModel {
    return val
}
@_inlineable
public prefix func -(val: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: -val.cyan, magenta: -val.magenta, yellow: -val.yellow, black: -val.black)
}
@_inlineable
public func +(lhs: CMYKColorModel, rhs: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan + rhs.cyan, magenta: lhs.magenta + rhs.magenta, yellow: lhs.yellow + rhs.yellow, black: lhs.black + rhs.black)
}
@_inlineable
public func -(lhs: CMYKColorModel, rhs: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan - rhs.cyan, magenta: lhs.magenta - rhs.magenta, yellow: lhs.yellow - rhs.yellow, black: lhs.black - rhs.black)
}

@_inlineable
public func *(lhs: Double, rhs: CMYKColorModel) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs * rhs.cyan, magenta: lhs * rhs.magenta, yellow: lhs * rhs.yellow, black: lhs * rhs.black)
}
@_inlineable
public func *(lhs: CMYKColorModel, rhs: Double) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan * rhs, magenta: lhs.magenta * rhs, yellow: lhs.yellow * rhs, black: lhs.black * rhs)
}

@_inlineable
public func /(lhs: CMYKColorModel, rhs: Double) -> CMYKColorModel {
    return CMYKColorModel(cyan: lhs.cyan / rhs, magenta: lhs.magenta / rhs, yellow: lhs.yellow / rhs, black: lhs.black / rhs)
}

@_inlineable
public func *= (lhs: inout CMYKColorModel, rhs: Double) {
    lhs.cyan *= rhs
    lhs.magenta *= rhs
    lhs.yellow *= rhs
    lhs.black *= rhs
}
@_inlineable
public func /= (lhs: inout CMYKColorModel, rhs: Double) {
    lhs.cyan /= rhs
    lhs.magenta /= rhs
    lhs.yellow /= rhs
    lhs.black /= rhs
}
@_inlineable
public func += (lhs: inout CMYKColorModel, rhs: CMYKColorModel) {
    lhs.cyan += rhs.cyan
    lhs.magenta += rhs.magenta
    lhs.yellow += rhs.yellow
    lhs.black += rhs.black
}
@_inlineable
public func -= (lhs: inout CMYKColorModel, rhs: CMYKColorModel) {
    lhs.cyan -= rhs.cyan
    lhs.magenta -= rhs.magenta
    lhs.yellow -= rhs.yellow
    lhs.black -= rhs.black
}
@_inlineable
public func ==(lhs: CMYKColorModel, rhs: CMYKColorModel) -> Bool {
    return lhs.cyan == rhs.cyan && lhs.magenta == rhs.magenta && lhs.yellow == rhs.yellow && lhs.black == rhs.black
}
@_inlineable
public func !=(lhs: CMYKColorModel, rhs: CMYKColorModel) -> Bool {
    return lhs.cyan != rhs.cyan || lhs.magenta != rhs.magenta || lhs.yellow != rhs.yellow || lhs.black != rhs.black
}
