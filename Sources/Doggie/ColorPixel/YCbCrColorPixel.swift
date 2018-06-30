//
//  YCbCrColorPixel.swift
//
//  The MIT License
//  Copyright (c) 2015 -2018 Susan Cheng. All rights reserved.
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

public struct YCbCrColorPixel : ColorPixelProtocol {
    
    public var a: UInt8
    public var y: UInt8
    public var cb: UInt8
    public var cr: UInt8
    
    @_transparent
    public init() {
        self.a = 0
        self.y = 0
        self.cb = 0
        self.cr = 0
    }
    @_transparent
    public init(color: YCbCrColorModel, opacity: Double) {
        self.a = UInt8((opacity * 255).clamped(to: 0...255).rounded())
        self.y = UInt8((color.y * 255).clamped(to: 0...255).rounded())
        self.cb = UInt8((color.cb * 255).clamped(to: 0...255).rounded())
        self.cr = UInt8((color.cr * 255).clamped(to: 0...255).rounded())
    }
    
    @_transparent
    public var color: YCbCrColorModel {
        get {
            return YCbCrColorModel(y: Double(y) / 255, cb: Double(cb) / 255, cr: Double(cr) / 255)
        }
        set {
            self.y = UInt8((newValue.y * 255).clamped(to: 0...255).rounded())
            self.cb = UInt8((newValue.cb * 255).clamped(to: 0...255).rounded())
            self.cr = UInt8((newValue.cr * 255).clamped(to: 0...255).rounded())
        }
    }
    @_transparent
    public var opacity: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8((newValue * 255).clamped(to: 0...255).rounded())
        }
    }
    
    @_transparent
    public var isOpaque: Bool {
        return a == 255
    }
    
    @_transparent
    public func with(opacity: Double) -> YCbCrColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}
