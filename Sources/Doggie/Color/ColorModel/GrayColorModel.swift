//
//  GrayColorModel.swift
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

public struct GrayColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var numberOfComponents: Int {
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
