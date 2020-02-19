//
//  Resolution.swift
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

@frozen
public struct Resolution: Hashable {
    
    public var horizontal: Double
    public var vertical: Double
    public var unit: Unit
    
    @inlinable
    public init(horizontal: Double, vertical: Double, unit: Unit) {
        self.horizontal = horizontal
        self.vertical = vertical
        self.unit = unit
    }
    
    @inlinable
    public init(resolution: Double, unit: Unit) {
        self.horizontal = resolution
        self.vertical = resolution
        self.unit = unit
    }
}

extension Resolution {
    
    @inlinable
    public static var `default`: Resolution {
        return Resolution(resolution: 1, unit: .point)
    }
}

extension Resolution {
    
    public enum Unit: CaseIterable {
        
        case point
        case pica
        case meter
        case centimeter
        case millimeter
        case inch
    }
}

extension Resolution.Unit {
    
    @usableFromInline
    var inchScale : Double {
        switch self {
        case .point: return 72
        case .pica: return 6
        case .meter: return 0.0254
        case .centimeter: return 2.54
        case .millimeter: return 25.4
        case .inch: return 1
        }
    }
}

extension Resolution {
    
    @inlinable
    public func convert(to toUnit: Resolution.Unit) -> Resolution {
        let scale = unit.inchScale / toUnit.inchScale
        return Resolution(horizontal: scale * horizontal, vertical: scale * vertical, unit: toUnit)
    }
}

extension Resolution.Unit {
    
    @inlinable
    public func convert(length: Double, from fromUnit: Resolution.Unit) -> Double {
        return fromUnit.convert(length: length, to: self)
    }
    
    @inlinable
    public func convert(point: Point, from fromUnit: Resolution.Unit) -> Point {
        return fromUnit.convert(point: point, to: self)
    }
    
    @inlinable
    public func convert(size: Size, from fromUnit: Resolution.Unit) -> Size {
        return fromUnit.convert(size: size, to: self)
    }
    
    @inlinable
    public func convert(rect: Rect, from fromUnit: Resolution.Unit) -> Rect {
        return fromUnit.convert(rect: rect, to: self)
    }
    
    @inlinable
    public func convert(length: Double, to toUnit: Resolution.Unit) -> Double {
        let scale = toUnit.inchScale / self.inchScale
        return length * scale
    }
    
    @inlinable
    public func convert(point: Point, to toUnit: Resolution.Unit) -> Point {
        let scale = toUnit.inchScale / self.inchScale
        return point * scale
    }
    
    @inlinable
    public func convert(size: Size, to toUnit: Resolution.Unit) -> Size {
        let scale = toUnit.inchScale / self.inchScale
        return size * scale
    }
    
    @inlinable
    public func convert(rect: Rect, to toUnit: Resolution.Unit) -> Rect {
        let scale = toUnit.inchScale / self.inchScale
        return rect * scale
    }
}

extension Resolution: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "Resolution(horizontal: \(horizontal), vertical: \(vertical), unit: \(unit))"
    }
}
