//
//  Font.swift
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

protocol FontFaceBase {
    
    var fontName: String? { get }
    var displayName: String? { get }
    var uniqueName: String? { get }
    var familyName: String? { get }
    var subfamilyName: String? { get }
    
    var designer: String? { get }
    
    var version: String? { get }
    
    var trademark: String? { get }
    var manufacturer: String? { get }
    var license: String? { get }
    var copyright: String? { get }
    
}

public struct Font {
    
    private let base: FontFaceBase
    
    public var pointSize: Double = 0
    public var transform: SDTransform = SDTransform.identity
    
    init?(_ base: FontFaceBase) {
        guard base.fontName != nil else { return nil }
        self.base = base
    }
    
    public init(font: Font, size: Double, transform: SDTransform = SDTransform.identity) {
        self.base = font.base
        self.pointSize = size
        self.transform = transform
    }
}

extension Font : CustomStringConvertible {
    
    public var description: String {
        return "Font(name: \(self.fontName), pointSize: \(self.pointSize), transform: \(self.transform))"
    }
}

extension Font {
    
    public func with(size pointSize: Double) -> Font {
        return Font(font: self, size: pointSize, transform: transform)
    }
}

extension Font {
    
    public var fontName: String {
        return base.fontName!
    }
    public var displayName: String? {
        return base.displayName
    }
    public var uniqueName: String? {
        return base.uniqueName
    }
    public var familyName: String? {
        return base.familyName
    }
    public var subfamilyName: String? {
        return base.subfamilyName
    }
    
    public var designer: String? {
        return base.designer
    }
    
    public var version: String? {
        return base.version
    }
    
    public var trademark: String? {
        return base.trademark
    }
    public var manufacturer: String? {
        return base.manufacturer
    }
    public var license: String? {
        return base.license
    }
    public var copyright: String? {
        return base.copyright
    }
    
}
