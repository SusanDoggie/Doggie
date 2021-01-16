//
//  SVGDropShadowEffect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public struct SVGDropShadowEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    
    public var offset: Size
    
    public var stdDeviation: Size
    
    public var color: AnyColor
    
    public var sources: [SVGEffect.Source] {
        return [source]
    }
    
    public init(source: SVGEffect.Source = .source, offset: Size = Size(), stdDeviation: Double, color: AnyColor = .black) {
        self.source = source
        self.offset = offset
        self.stdDeviation = Size(width: stdDeviation, height: stdDeviation)
        self.color = color
    }
    
    public init(source: SVGEffect.Source = .source, offset: Size = Size(), stdDeviation: Size = Size(), color: AnyColor = .black) {
        self.source = source
        self.offset = offset
        self.stdDeviation = stdDeviation
        self.color = color
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        guard let source = sources[self.source] else { return nil }
        let shadow = source.inset(dx: -ceil(3 * abs(stdDeviation.width)), dy: -ceil(3 * abs(stdDeviation.height))).offset(dx: offset.width, dy: offset.height)
        return source.union(shadow)
    }
}

extension SVGDropShadowEffect {
    
    private func create_color<C: ColorProtocol>(_ color: C) -> String {
        
        let color = color.convert(to: ColorSpace.sRGB, intent: .default)
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        return "rgb(\(red),\(green),\(blue))"
    }
    
    public var xml_element: SDXMLElement {
        
        var filter = SDXMLElement(name: "feDropShadow", attributes: [
            "dx": "\(Decimal(offset.width).rounded(scale: 9))",
            "dy": "\(Decimal(offset.height).rounded(scale: 9))",
            "flood-color": create_color(color),
        ])
        
        if stdDeviation.width == stdDeviation.height {
            filter.setAttribute(for: "stdDeviation", value: "\(Decimal(stdDeviation.width).rounded(scale: 9))")
        } else {
            filter.setAttribute(for: "stdDeviation", value: "\(Decimal(stdDeviation.width).rounded(scale: 9)) \(Decimal(stdDeviation.height).rounded(scale: 9))")
        }
        
        if self.color.opacity < 1 {
            filter.setAttribute(for: "flood-opacity", value: "\(Decimal(self.color.opacity).rounded(scale: 9))")
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}
