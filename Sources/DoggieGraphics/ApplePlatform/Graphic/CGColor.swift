//
//  CGColor.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

#if canImport(CoreGraphics)

extension Color {
    
    public var cgColor: CGColor? {
        return colorSpace.cgColorSpace.flatMap { CGColor(colorSpace: $0, components: color.map { CGFloat($0) } + [CGFloat(opacity)]) }
    }
}

protocol CGColorConvertibleProtocol {
    
    var cgColor: CGColor? { get }
}

extension Color: CGColorConvertibleProtocol {
    
}

extension AnyColor {
    
    public init?(cgColor: CGColor) {
        
        guard let colorSpace = cgColor.colorSpace.flatMap(AnyColorSpace.init) else { return nil }
        guard let components = cgColor.components, components.count == colorSpace.numberOfComponents + 1 else { return nil }
        guard let opacity = components.last else { return nil }
        
        self.init(colorSpace: colorSpace, components: components.dropLast().lazy.map(Double.init), opacity: Double(opacity))
    }
}

extension AnyColor {
    
    public var cgColor: CGColor? {
        if let base = _base as? CGColorConvertibleProtocol {
            return base.cgColor
        }
        return nil
    }
}

#endif

