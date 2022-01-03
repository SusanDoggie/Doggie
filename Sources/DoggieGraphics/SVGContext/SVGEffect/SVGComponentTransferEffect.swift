//
//  SVGComponentTransferEffect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

public struct SVGComponentTransferEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    
    public var red: TransferFunction
    public var green: TransferFunction
    public var blue: TransferFunction
    public var alpha: TransferFunction
    
    public var sources: [SVGEffect.Source] {
        return [source]
    }
    
    public init(source: SVGEffect.Source = .source, red: TransferFunction = .identity, green: TransferFunction = .identity, blue: TransferFunction = .identity, alpha: TransferFunction = .identity) {
        self.source = source
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public enum TransferFunction: Hashable {
        
        case identity
        case table([Double])
        case discrete([Double])
        case gamma(Double, Double, Double)
        
        public init(slope: Double, intercept: Double) {
            self = .gamma(slope, 1, intercept)
        }
        
        public init(amplitude: Double, exponent: Double, offset: Double) {
            self = .gamma(amplitude, exponent, offset)
        }
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return sources[source]
    }
}

extension SVGComponentTransferEffect.TransferFunction {
    
    fileprivate func xml_element(_ node: String) -> SDXMLElement {
        
        switch self {
        case .identity: return SDXMLElement(name: node, attributes: ["type": "identity"])
            
        case let .table(values):
            
            let _values = values.map { "\(Decimal($0).rounded(scale: 9))" }.joined(separator: " ")
            
            return SDXMLElement(name: node, attributes: ["type": "table", "tableValues": _values])
            
        case let .discrete(values):
            
            let _values = values.map { "\(Decimal($0).rounded(scale: 9))" }.joined(separator: " ")
            
            return SDXMLElement(name: node, attributes: ["type": "discrete", "tableValues": _values])
            
        case let .gamma(amplitude, exponent, offset):
            
            var element = SDXMLElement(name: node)
            
            if exponent == 1 {
                element.setAttribute(for: "type", value: "linear")
                element.setAttribute(for: "slope", value: "\(Decimal(amplitude).rounded(scale: 9))")
                element.setAttribute(for: "intercept", value: "\(Decimal(offset).rounded(scale: 9))")
            } else {
                element.setAttribute(for: "type", value: "gamma")
                element.setAttribute(for: "amplitude", value: "\(Decimal(amplitude).rounded(scale: 9))")
                element.setAttribute(for: "exponent", value: "\(Decimal(exponent).rounded(scale: 9))")
                element.setAttribute(for: "offset", value: "\(Decimal(offset).rounded(scale: 9))")
            }
            
            return element
        }
    }
}

extension SVGComponentTransferEffect {
    
    public var xml_element: SDXMLElement {
        
        var filter = SDXMLElement(name: "feComponentTransfer", elements: [
            red.xml_element("feFuncR"),
            green.xml_element("feFuncG"),
            blue.xml_element("feFuncB"),
            alpha.xml_element("feFuncA"),
        ])
        
        switch self.source {
        case .source: filter.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: filter.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): filter.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return filter
    }
}
