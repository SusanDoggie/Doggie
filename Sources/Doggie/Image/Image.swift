//
//  Image.swift
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

public struct Resolution {
    
    public var horizontal: Double
    public var vertical: Double
    public var unit: Unit
    
    public init(horizontal: Double, vertical: Double, unit: Unit) {
        self.horizontal = horizontal
        self.vertical = vertical
        self.unit = unit
    }
    
    public init(resolution: Double, unit: Unit) {
        self.horizontal = resolution
        self.vertical = resolution
        self.unit = unit
    }
}

extension Resolution {
    
    public enum Unit {
        
        case point
        case pica
        case meter
        case centimeter
        case millimeter
        case inch
    }
}

extension Resolution.Unit {
    
    @_versioned
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
    
    @_inlineable
    public func convert(to toUnit: Resolution.Unit) -> Resolution {
        let scale = unit.inchScale / toUnit.inchScale
        return Resolution(horizontal: scale * horizontal, vertical: scale * vertical, unit: toUnit)
    }
}

extension Resolution : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "Resolution(horizontal: \(horizontal), vertical: \(vertical), unit: \(unit))"
    }
}

public struct Image<Pixel: ColorPixelProtocol> {
    
    public let width: Int
    public let height: Int
    
    public var resolution: Resolution
    
    public internal(set) var pixels: [Pixel]
    
    public var colorSpace: ColorSpace<Pixel.Model>
    
    @_inlineable
    public init(width: Int, height: Int, colorSpace: ColorSpace<Pixel.Model>, pixel: Pixel = Pixel(), resolution: Resolution = Resolution(resolution: 1, unit: .point)) {
        precondition(width >= 0, "negative width is not allowed.")
        precondition(height >= 0, "negative height is not allowed.")
        self.width = width
        self.height = height
        self.resolution = resolution
        self.colorSpace = colorSpace
        self.pixels = [Pixel](repeating: pixel, count: width * height)
    }
    
    @_inlineable
    public init<P>(image: Image<P>) where P.Model == Pixel.Model {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = image.colorSpace
        self.pixels = image.pixels as? [Pixel] ?? image.pixels.map(Pixel.init)
    }
    
    @_inlineable
    public init<P>(image: Image<P>, colorSpace: ColorSpace<Pixel.Model>, intent: RenderingIntent = .default) {
        self.width = image.width
        self.height = image.height
        self.resolution = image.resolution
        self.colorSpace = colorSpace
        self.pixels = image.colorSpace.convert(image.pixels, to: self.colorSpace, intent: intent)
    }
}

extension Image : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "Image<\(Pixel.self)>(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution))"
    }
}

extension Image : CustomPlaygroundQuickLookable {
    
    @_inlineable
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return PlaygroundQuickLook.text(description)
    }
}

extension Image {
    
    @_inlineable
    public subscript(x: Int, y: Int) -> Color<Pixel.Model> {
        get {
            precondition(0..<width ~= x && 0..<height ~= y)
            return Color(colorSpace: colorSpace, color: pixels[width * y + x])
        }
        set {
            precondition(0..<width ~= x && 0..<height ~= y)
            pixels[width * y + x] = Pixel(newValue.convert(to: colorSpace))
        }
    }
}

extension Image {
    
    @_inlineable
    public var isOpaque: Bool {
        return pixels.all { $0.isOpaque }
    }
}

extension Image {
    
    @_inlineable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBufferPointer(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBufferPointer(body)
    }
    
    @_inlineable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeBytes(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        
        return try pixels.withUnsafeMutableBytes(body)
    }
}

