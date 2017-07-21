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
        self.init(CMYColorModel(rgb))
    }
    
    @_inlineable
    public init(_ cmy: CMYColorModel) {
        self.black = min(cmy.cyan, cmy.magenta, cmy.yellow)
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
