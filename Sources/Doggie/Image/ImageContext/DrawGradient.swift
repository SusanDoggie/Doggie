//
//  DrawGradient.swift
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

import Foundation

public enum GradientSpreadMode {
    
    case none
    case pad
    case reflect
    case `repeat`
}

public struct GradientStop<Model : ColorModelProtocol> {
    
    public var offset: Double
    public var color: Color<Model>
    
    @_inlineable
    public init(offset: Double, color: Color<Model>) {
        self.offset = offset
        self.color = color
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    func _shading(_ shader: (Point) throws -> ColorPixel<Model>) rethrows {
        
        if let next = self.next {
            try next._shading(shader)
            return
        }
        
        if _image.width == 0 || _image.height == 0 || _transform.determinant.almostZero() {
            return
        }
        
        let transform = self._transform.inverse
        
        try _image.withUnsafeMutableBufferPointer { _image in
            
            if var _destination = _image.baseAddress {
                
                try clip.withUnsafeBufferPointer { _clip in
                    
                    if var _clip = _clip.baseAddress {
                        
                        var _p = Point(x: 0, y: 0)
                        let _p1 = Point(x: 1, y: 0) * transform
                        let _p2 = Point(x: 0, y: 1) * transform
                        
                        for _ in 0..<height {
                            var p = _p
                            for _ in 0..<width {
                                
                                let _alpha = _clip.pointee
                                
                                if _alpha > 0 {
                                    
                                    var pixel = try shader(p)
                                    pixel.opacity *= _alpha
                                    
                                    if pixel.opacity > 0 {
                                        _destination.pointee.blend(source: pixel, blendMode: _blendMode, compositingMode: _compositingMode)
                                    }
                                }
                                
                                _destination += 1
                                _clip += 1
                                p += _p1
                            }
                            _p += _p2
                        }
                    }
                }
            }
        }
        
    }
}

extension ImageContext {
    
    @_inlineable
    public func axialShading(start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) throws -> ColorPixel<Model>) rethrows {
        
        if start.almostEqual(end) {
            return
        }
        
        let startColor = try shading(0)
        let endColor = try shading(1)
        
        try self._shading { point in
            
            let a = start - point
            let b = end - start
            let u = b.x * a.x + b.y * a.y
            let v = b.x * b.x + b.y * b.y
            
            let t = -u / v
            
            if 0...1 ~= t {
                
                return try shading(t)
                
            } else if t > 1 {
                
                switch endSpread {
                case .none: return endColor.with(opacity: 0)
                case .pad: return endColor
                case .reflect:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(Int(_t) & 1 == 0 ? s : 1 - s)
                case .repeat:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(s)
                }
                
            } else {
                
                switch startSpread {
                case .none: return startColor.with(opacity: 0)
                case .pad: return startColor
                case .reflect:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(Int(_t) & 1 == 0 ? -s : 1 + s)
                case .repeat:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return try shading(1 + s)
                }
            }
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func radialShading(start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) throws -> ColorPixel<Model>) rethrows {
        
        if start.almostEqual(end) && startRadius.almostEqual(endRadius) {
            return
        }
        
        let startColor = try shading(0)
        let endColor = try shading(1)
        
        try self._shading { point in
            
            let p0 = point - start
            let p1 = start - end
            let r0 = startRadius
            let r1 = endRadius - startRadius
            
            let a = p1.x * p1.x + p1.y * p1.y - r1 * r1
            let b = 2 * (p0.x * p1.x + p0.y * p1.y - r0 * r1)
            let c = p0.x * p0.x + p0.y * p0.y - r0 * r0
            
            var t: Double?
            
            func _filter(_ t: Double) -> Bool {
                return r0 + t * r1 >= 0 && (t >= 0 || startSpread != .none) && (t <= 1 || endSpread != .none)
            }
            
            if a.almostZero() {
                if b.almostZero() {
                    t = nil
                } else {
                    let _t = -c / b
                    if _filter(_t) {
                        t = _t
                    }
                }
            } else {
                for _t in degree2roots(b / a, c / a) where _filter(_t) {
                    t = t.map { max($0, _t) } ?? _t
                }
            }
            
            if let t = t {
                
                if 0...1 ~= t {
                    
                    return try shading(t)
                    
                } else if t > 1 {
                    
                    switch endSpread {
                    case .none: return endColor.with(opacity: 0)
                    case .pad: return endColor
                    case .reflect:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(Int(_t) & 1 == 0 ? s : 1 - s)
                    case .repeat:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(s)
                    }
                    
                } else {
                    
                    switch startSpread {
                    case .none: return startColor.with(opacity: 0)
                    case .pad: return startColor
                    case .reflect:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(Int(_t) & 1 == 0 ? -s : 1 + s)
                    case .repeat:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return try shading(1 + s)
                    }
                }
            }
            
            return ColorPixel()
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.sorted { $0.offset }.map { ($0.offset, ColorPixel($0.color.convert(to: colorSpace))) }
        
        switch stops.count {
        case 0: break
        case 1: axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread) { _ in stops[0].1 }
        default:
            axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread) { t in
                
                if t <= stops[0].0 {
                    return stops[0].1
                }
                if t >= stops.last!.0 {
                    return stops.last!.1
                }
                
                for (lhs, rhs) in zip(stops, stops.dropFirst()) where lhs.0 != rhs.0 && t >= lhs.0 && t <= rhs.0 {
                    
                    let s = (t - lhs.0) / (rhs.0 - lhs.0)
                    return lhs.1 * (1 - s) + rhs.1 * s
                }
                
                return stops[0].1
            }
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let stops = stops.sorted { $0.offset }.map { ($0.offset, ColorPixel($0.color.convert(to: colorSpace))) }
        
        switch stops.count {
        case 0: break
        case 1: radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread) { _ in stops[0].1 }
        default:
            radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread) { t in
                
                if t <= stops[0].0 {
                    return stops[0].1
                }
                if t >= stops.last!.0 {
                    return stops.last!.1
                }
                
                for (lhs, rhs) in zip(stops, stops.dropFirst()) where lhs.0 != rhs.0 && t >= lhs.0 && t <= rhs.0 {
                    
                    let s = (t - lhs.0) / (rhs.0 - lhs.0)
                    return lhs.1 * (1 - s) + rhs.1 * s
                }
                
                return stops[0].1
            }
        }
    }
}