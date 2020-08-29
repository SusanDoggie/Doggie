//
//  SVGBlendEffect.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public struct SVGBlendEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    public var source2: SVGEffect.Source
    
    public var mode: Mode
    
    public var sources: [SVGEffect.Source] {
        return [source, source2]
    }
    
    public init(source: SVGEffect.Source = .source, source2: SVGEffect.Source = .source, mode: Mode = .normal) {
        self.source = source
        self.source2 = source2
        self.mode = mode
    }
    
    public enum Mode: Hashable {
        
        case normal
        
        case `in`
        case out
        case atop
        case xor
        
        case multiply
        case screen
        case overlay
        case darken
        case lighten
        case colorDodge
        case colorBurn
        case softLight
        case hardLight
        case difference
        case exclusion
        
        case hue
        case saturation
        case color
        case luminosity
        
        case arithmetic(Double, Double, Double, Double)
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return self.sources.lazy.map { sources[$0] }.reduce { lhs, rhs in rhs.flatMap { lhs?.union($0) } }
    }
}

extension SVGBlendEffect {
    
    public var xml_element: SDXMLElement {
        
        var filter: SDXMLElement
        
        switch mode {
        case .normal: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "normal"])
            
        case .in: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "in"])
        case .out: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "out"])
        case .atop: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "atop"])
        case .xor: filter = SDXMLElement(name: "feComposite", attributes: ["operator": "xor"])
            
        case .multiply: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "multiply"])
        case .screen: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "screen"])
        case .overlay: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "overlay"])
        case .darken: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "darken"])
        case .lighten: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "lighten"])
        case .colorDodge: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "color-dodge"])
        case .colorBurn: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "color-burn"])
        case .softLight: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "soft-light"])
        case .hardLight: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "hard-light"])
        case .difference: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "difference"])
        case .exclusion: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "exclusion"])
            
        case .hue: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "hue"])
        case .saturation: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "saturation"])
        case .color: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "color"])
        case .luminosity: filter = SDXMLElement(name: "feBlend", attributes: ["mode": "luminosity"])
            
        case let .arithmetic(k1, k2, k3, k4):
            filter = SDXMLElement(name: "feComposite", attributes: ["operator": "arithmetic"])
            filter.setAttribute(for: "k1", value: "\(Decimal(k1).rounded(scale: 9))")
            filter.setAttribute(for: "k2", value: "\(Decimal(k2).rounded(scale: 9))")
            filter.setAttribute(for: "k3", value: "\(Decimal(k3).rounded(scale: 9))")
            filter.setAttribute(for: "k4", value: "\(Decimal(k4).rounded(scale: 9))")
        }
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        switch self.source2 {
        case .source: filter.setAttribute(for: "in2", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in2", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in2", value: uuid.uuidString)
        }
        
        return filter
    }
}
