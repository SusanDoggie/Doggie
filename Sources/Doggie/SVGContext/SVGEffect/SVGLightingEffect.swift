//
//  SVGLightingEffect.swift
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

public protocol SVGLightSource {
    
    var xml_element: SDXMLElement { get }
}

public struct SVGPointLight: SVGLightSource {
    
    public var location: Vector
    
    public init(location: Vector = Vector()) {
        self.location = location
    }
}

public struct SVGSpotLight: SVGLightSource {
    
    public var location: Vector
    public var direction: Vector
    
    public var specularExponent: Double
    public var limitingConeAngle: Double
    
    public init(location: Vector = Vector(), direction: Vector = Vector(), specularExponent: Double = 1, limitingConeAngle: Double = 0.5 * .pi) {
        self.location = location
        self.direction = direction
        self.specularExponent = specularExponent
        self.limitingConeAngle = limitingConeAngle
    }
}

public struct SVGDistantLight: SVGLightSource {
    
    public var azimuth: Double
    public var elevation: Double
    
    public init(azimuth: Double = 0, elevation: Double = 0) {
        self.azimuth = azimuth
        self.elevation = elevation
    }
}

public protocol SVGLightingEffect: SVGEffectElement {
    
    var source: SVGEffect.Source { get set }
    
    var light: [SVGLightSource] { get set }
    
    var color : RGBColorModel { get set }
    
    var surfaceScale: Double { get set }
}

extension SVGLightingEffect {
    
    public var sources: [SVGEffect.Source] {
        return [source]
    }
    
    public func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect? {
        return sources[source]
    }
}

public struct SVGDiffuseLightingEffect: SVGLightingEffect {
    
    public var region: Rect?
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    
    public var light: [SVGLightSource]
    
    public var color: RGBColorModel
    
    public var surfaceScale: Double
    public var diffuseConstant: Double
    
    public init(source: SVGEffect.Source = .source, surfaceScale: Double = 1, diffuseConstant: Double = 1, color: RGBColorModel = .white, light: [SVGLightSource] = []) {
        self.source = source
        self.surfaceScale = surfaceScale
        self.diffuseConstant = diffuseConstant
        self.color = color
        self.light = light
    }
}

public struct SVGSpecularLightingEffect: SVGLightingEffect {
    
    public var region: Rect?
    
    public var regionUnit: SVGEffect.RegionUnit = .objectBoundingBox
    
    public var source: SVGEffect.Source
    
    public var light: [SVGLightSource]
    
    public var color: RGBColorModel
    
    public var surfaceScale: Double
    public var specularConstant: Double
    public var specularExponent: Double
    
    public init(source: SVGEffect.Source = .source, surfaceScale: Double = 1, specularConstant: Double = 1, specularExponent: Double = 1, color: RGBColorModel = .white, light: [SVGLightSource] = []) {
        self.source = source
        self.surfaceScale = surfaceScale
        self.specularConstant = specularConstant
        self.specularExponent = specularExponent
        self.color = color
        self.light = light
    }
}

extension SVGPointLight {
    
    public var xml_element: SDXMLElement {
        
        return SDXMLElement(name: "fePointLight", attributes: [
            "x": "\(Decimal(location.x).rounded(scale: 9))",
            "y": "\(Decimal(location.y).rounded(scale: 9))",
            "z": "\(Decimal(location.z).rounded(scale: 9))",
        ])
    }
}

extension SVGSpotLight {
    
    public var xml_element: SDXMLElement {
        
        return SDXMLElement(name: "feSpotLight", attributes: [
            "x": "\(Decimal(location.x).rounded(scale: 9))",
            "y": "\(Decimal(location.y).rounded(scale: 9))",
            "z": "\(Decimal(location.z).rounded(scale: 9))",
            "pointsAtX": "\(Decimal(direction.x).rounded(scale: 9))",
            "pointsAtY": "\(Decimal(direction.y).rounded(scale: 9))",
            "pointsAtZ": "\(Decimal(direction.z).rounded(scale: 9))",
            "specularExponent": "\(Decimal(specularExponent).rounded(scale: 9))",
            "limitingConeAngle": "\(Decimal(limitingConeAngle * 180 / .pi).rounded(scale: 9))",
        ])
    }
}

extension SVGDistantLight {
    
    public var xml_element: SDXMLElement {
        
        return SDXMLElement(name: "feDistantLight", attributes: [
            "azimuth": "\(Decimal(azimuth * 180 / .pi).rounded(scale: 9))",
            "elevation": "\(Decimal(elevation * 180 / .pi).rounded(scale: 9))",
        ])
    }
}

extension SVGDiffuseLightingEffect {
    
    public var xml_element: SDXMLElement {
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        var element = SDXMLElement(name: "feDiffuseLighting", attributes: [
            "surfaceScale": "\(Decimal(surfaceScale).rounded(scale: 9))",
            "diffuseConstant": "\(Decimal(diffuseConstant).rounded(scale: 9))",
            "lighting-color": "rgb(\(red),\(green),\(blue))"
        ])
        
        for light in self.light {
            element.append(light.xml_element)
        }
        
        switch self.source {
        case .source: element.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: element.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): element.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return element
    }
}

extension SVGSpecularLightingEffect {
    
    public var xml_element: SDXMLElement {
        
        let red = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        let green = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        let blue = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        
        var element = SDXMLElement(name: "feSpecularLighting", attributes: [
            "surfaceScale": "\(Decimal(surfaceScale).rounded(scale: 9))",
            "specularConstant": "\(Decimal(specularConstant).rounded(scale: 9))",
            "specularExponent": "\(Decimal(specularExponent).rounded(scale: 9))",
            "lighting-color": "rgb(\(red),\(green),\(blue))"
        ])
        
        for light in self.light {
            element.append(light.xml_element)
        }
        
        switch self.source {
        case .source: element.setAttribute(for: "in", value: "SourceGraphic")
        case .sourceAlpha: element.setAttribute(for: "in", value: "SourceAlpha")
        case let .reference(uuid): element.setAttribute(for: "in", value: uuid.uuidString)
        }
        
        return element
    }
}
