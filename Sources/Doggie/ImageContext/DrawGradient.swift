//
//  DrawGradient.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

extension ImageContext {
    
    @inline(__always)
    @usableFromInline
    func _shading<P : ColorPixelProtocol>(_ shader: (Point) -> P) where Pixel.Model == P.Model {
        
        let width = self.width
        let height = self.height
        
        if width == 0 || height == 0 || self.transform.determinant.almostZero() {
            return
        }
        
        let transform = self.transform.inverse
        
        self.withUnsafePixelBlender { blender in
            
            var blender = blender
            
            for y in 0..<height {
                for x in 0..<width {
                    blender.draw { shader(Point(x: x, y: y) * transform) }
                    blender += 1
                }
            }
        }
        
    }
}

extension ImageContext {
    
    @inline(__always)
    public func axialShading<P : ColorPixelProtocol>(start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) -> P) where Pixel.Model == P.Model {
        
        if start.almostEqual(end) {
            return
        }
        
        let startColor = shading(0)
        let endColor = shading(1)
        
        self._shading { point -> P in
            
            let a = start - point
            let b = end - start
            let u = b.x * a.x + b.y * a.y
            let v = b.x * b.x + b.y * b.y
            
            let t = -u / v
            
            if 0...1 ~= t {
                
                return shading(t)
                
            } else if t > 1 {
                
                switch endSpread {
                case .none: return endColor.with(opacity: 0)
                case .pad: return endColor
                case .reflect:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return shading(Int(_t) & 1 == 0 ? s : 1 - s)
                case .repeat:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return shading(s)
                }
                
            } else {
                
                switch startSpread {
                case .none: return startColor.with(opacity: 0)
                case .pad: return startColor
                case .reflect:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return shading(Int(_t) & 1 == 0 ? -s : 1 + s)
                case .repeat:
                    var _t = 0.0
                    let s = modf(t, &_t)
                    return shading(1 + s)
                }
            }
        }
    }
}

extension ImageContext {
    
    @inline(__always)
    public func radialShading<P : ColorPixelProtocol>(start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) -> P) where Pixel.Model == P.Model {
        
        if start.almostEqual(end) && startRadius.almostEqual(endRadius) {
            return
        }
        
        let startColor = shading(0)
        let endColor = shading(1)
        
        self._shading { point -> P in
            
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
                    
                    return shading(t)
                    
                } else if t > 1 {
                    
                    switch endSpread {
                    case .none: return endColor.with(opacity: 0)
                    case .pad: return endColor
                    case .reflect:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return shading(Int(_t) & 1 == 0 ? s : 1 - s)
                    case .repeat:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return shading(s)
                    }
                    
                } else {
                    
                    switch startSpread {
                    case .none: return startColor.with(opacity: 0)
                    case .pad: return startColor
                    case .reflect:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return shading(Int(_t) & 1 == 0 ? -s : 1 + s)
                    case .repeat:
                        var _t = 0.0
                        let s = modf(t, &_t)
                        return shading(1 + s)
                    }
                }
            }
            
            return P()
        }
    }
}

extension ImageContext {
    
    @inline(__always)
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.indexed().sorted { ($0.0, $0.1.offset) < ($1.0, $1.1.offset) }.map { ($0.1.offset, ColorPixel($0.1.color.convert(to: colorSpace, intent: renderingIntent))) }
        
        switch stops.count {
        case 0: break
        case 1: axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread) { _ in stops[0].1 }
        default:
            axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread) { t -> ColorPixel<Pixel.Model> in
                
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
    
    @inline(__always)
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.indexed().sorted { ($0.0, $0.1.offset) < ($1.0, $1.1.offset) }.map { ($0.1.offset, ColorPixel($0.1.color.convert(to: colorSpace, intent: renderingIntent))) }
        
        switch stops.count {
        case 0: break
        case 1: radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread) { _ in stops[0].1 }
        default:
            radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread) { t -> ColorPixel<Pixel.Model> in
                
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
