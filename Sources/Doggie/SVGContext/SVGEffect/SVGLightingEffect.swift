//
//  SVGLightingEffect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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
    
}

public struct SVGPointLight : SVGLightSource {
    
    public var location: Vector
    
    public init(location: Vector = Vector()) {
        self.location = location
    }
}

public struct SVGSpotLight : SVGLightSource {
    
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

public struct SVGDistantLight : SVGLightSource {
    
    public var azimuth: Double
    public var elevation: Double
    
    public init(azimuth: Double = 0, elevation: Double = 0) {
        self.azimuth = azimuth
        self.elevation = elevation
    }
}

public protocol SVGLightingEffect : SVGEffectElement {
    
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

public struct SVGDiffuseLightingEffect : SVGLightingEffect {
    
    public var region: Rect?
    
    public var source: SVGEffect.Source
    
    public var light: [SVGLightSource]
    
    public var color : RGBColorModel
    
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

public struct SVGSpecularLightingEffect : SVGLightingEffect {
    
    public var region: Rect?
    
    public var source: SVGEffect.Source
    
    public var light: [SVGLightSource]
    
    public var color : RGBColorModel
    
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
