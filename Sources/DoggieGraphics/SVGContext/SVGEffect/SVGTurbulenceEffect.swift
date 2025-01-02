//
//  SVGTurbulenceEffect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

public struct SVGTurbulenceEffect: SVGEffectElement {
    
    public var region: Rect = .null
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var stitchTiles: Bool
    public var type: SVGTurbulenceType
    public var seed: Int
    public var baseFrequency: Size
    public var numOctaves: Int
    
    public var sources: [SVGEffect.Source] {
        return []
    }
    
    public init(type: SVGTurbulenceType = .turbulence, stitchTiles: Bool = false, seed: Int = 0, baseFrequency: Size = Size(), numOctaves: Int = 1) {
        self.type = type
        self.stitchTiles = stitchTiles
        self.seed = seed
        self.baseFrequency = baseFrequency
        self.numOctaves = numOctaves
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return nil
    }
}

extension SVGTurbulenceEffect {
    
    public var xml_element: SDXMLElement {
        
        var filter = SDXMLElement(name: "feTurbulence", attributes: [
            "stitchTiles": stitchTiles ? "stitch" : "noStitch",
            "seed": "\(seed)",
            "numOctaves": "\(numOctaves)",
        ])
        
        switch self.type {
        case .turbulence: filter.setAttribute(for: "type", value: "turbulence")
        case .fractalNoise: filter.setAttribute(for: "type", value: "fractalNoise")
        }
        
        if baseFrequency.width == baseFrequency.height {
            filter.setAttribute(for: "baseFrequency", value: "\(Decimal(baseFrequency.width).rounded(scale: 9))")
        } else {
            filter.setAttribute(for: "baseFrequency", value: "\(Decimal(baseFrequency.width).rounded(scale: 9)) \(Decimal(baseFrequency.height).rounded(scale: 9))")
        }
        
        return filter
    }
}
