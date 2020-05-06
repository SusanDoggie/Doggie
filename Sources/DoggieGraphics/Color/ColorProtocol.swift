//
//  ColorProtocol.swift
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

public protocol ColorProtocol {
    
    associatedtype ColorSpace: ColorSpaceProtocol
    
    var colorSpace: ColorSpace { get }
    
    func linearTone() -> Self
    
    var cieXYZ: Color<XYZColorModel> { get }
    
    func with(opacity: Double) -> Self
    
    var numberOfComponents: Int { get }
    
    func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
    
    var opacity: Double { get set }
    
    var isOpaque: Bool { get }
    
    func convert<Model>(to colorSpace: DoggieGraphics.ColorSpace<Model>, intent: RenderingIntent) -> Color<Model>
    
    func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent) -> AnyColor
}

extension ColorProtocol {
    
    @inlinable
    public var model: _ColorModel.Type {
        return colorSpace.model
    }
    
    @inlinable
    public func almostEqual<C: ColorProtocol>(_ other: C, intent: RenderingIntent = .default, epsilon: Double = 0.0001) -> Bool {
        
        guard self.opacity.almostEqual(other.opacity, epsilon: epsilon) else { return false }
        
        let _cieXYZ = self.colorSpace.cieXYZ
        let _self = self.convert(to: _cieXYZ, intent: intent)
        let _other = other.convert(to: _cieXYZ, intent: intent)
        
        return _self.color.x.almostEqual(_other.color.x, epsilon: epsilon)
            && _self.color.y.almostEqual(_other.color.y, epsilon: epsilon)
            && _self.color.z.almostEqual(_other.color.z, epsilon: epsilon)
    }
}
