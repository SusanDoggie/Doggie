//
//  DrawGradient.swift
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

extension ImageContext {
    
    @inlinable
    @inline(__always)
    func _shading<P: ColorPixel>(_ shader: (Point) -> P?) where Pixel.Model == P.Model {
        
        let width = self.width
        let height = self.height
        
        guard width != 0 && height != 0 && self.transform.invertible else { return }
        
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
    
    @inlinable
    @inline(__always)
    func _shading<P: ColorPixel>(startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, mapping: (Point) -> Double?, shading: (Double) -> P) where Pixel.Model == P.Model {
        
        let startColor = shading(0)
        let endColor = shading(1)
        
        self._shading { point -> P? in
            
            guard let t = mapping(point) else { return nil }
            
            if 0...1 ~= t {
                
                return shading(t)
                
            } else if t > 0.5 {
                
                let i = Int(trunc(t))
                let s = t - Double(i)
                
                switch endSpread {
                case .none: return endColor.with(opacity: 0)
                case .pad: return endColor
                case .reflect: return shading(i & 1 == 0 ? s : 1 - s)
                case .repeat: return shading(s)
                }
                
            } else {
                
                let i = Int(trunc(t))
                let s = t - Double(i)
                
                switch startSpread {
                case .none: return startColor.with(opacity: 0)
                case .pad: return startColor
                case .reflect: return shading(i & 1 == 0 ? -s : 1 + s)
                case .repeat: return shading(1 + s)
                }
            }
        }
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func axialShading<P: ColorPixel>(start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) -> P) where Pixel.Model == P.Model {
        
        guard !start.almostEqual(end) else { return }
        
        self._shading(startSpread: startSpread, endSpread: endSpread, mapping: { point -> Double? in
            
            let a = start - point
            let b = end - start
            let u = b.x * a.x + b.y * a.y
            let v = b.x * b.x + b.y * b.y
            
            return -u / v
            
        }, shading: shading)
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func radialShading<P: ColorPixel>(start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) -> P) where Pixel.Model == P.Model {
        
        guard !start.almostEqual(end) || !startRadius.almostEqual(endRadius) else { return }
        
        self._shading(startSpread: startSpread, endSpread: endSpread, mapping: { point -> Double? in
            
            let p0 = point - start
            let p1 = start - end
            let r0 = startRadius
            let r1 = endRadius - startRadius
            
            let a = p1.x * p1.x + p1.y * p1.y - r1 * r1
            let b = 2 * (p0.x * p1.x + p0.y * p1.y - r0 * r1)
            let c = p0.x * p0.x + p0.y * p0.y - r0 * r0
            
            @inline(__always)
            func _filter(_ t: Double) -> Bool {
                return r0 + t * r1 >= 0 && (t >= 0 || startSpread != .none) && (t <= 1 || endSpread != .none)
            }
            
            if a.almostZero() {
                if !b.almostZero() {
                    let _t = -c / b
                    if _filter(_t) {
                        return _t
                    }
                }
            } else {
                
                var t: Double?
                
                for _t in degree2roots(b / a, c / a) where _filter(_t) {
                    t = t.map { max($0, _t) } ?? _t
                }
                
                return t
            }
            
            return nil
            
        }, shading: shading)
    }
}

@usableFromInline
protocol _GradientStop {
    
    var offset: Double { get }
}
extension GradientStop: _GradientStop { }

extension Array where Element: _GradientStop {
    
    @inlinable
    @inline(__always)
    func sorted() -> [Element] {
        return self.indexed().sorted { ($0.1.offset, $0.0) < ($1.1.offset, $1.0) }.map { $1 }
    }
}

@usableFromInline
struct Float32GradientStop<Model: ColorModel> {
    
    @usableFromInline
    var offset: Float
    
    @usableFromInline
    var color: Float32ColorPixel<Model>
    
    @inlinable
    @inline(__always)
    init(_ stop: GradientStop<Color<Model>>) {
        self.offset = Float(stop.offset)
        self.color = Float32ColorPixel(stop.color)
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    func _drawGradient<C>(stops: [GradientStop<C>], shading: ((Double) -> Float32ColorPixel<Pixel.Model>) -> Void) {
        
        let colorSpace = self.colorSpace
        let renderingIntent = self.renderingIntent
        let stops = stops.sorted().map { Float32GradientStop($0.convert(to: colorSpace, intent: renderingIntent)) }
        
        switch stops.count {
        case 0: break
        case 1:
            
            let color = stops[0].color
            shading { _ in color }
            
        default:
            
            let first = stops.first!
            let last = stops.last!
            
            shading { t in
                
                let t = Float(t)
                
                if t <= first.offset {
                    return first.color
                }
                if t >= last.offset {
                    return last.color
                }
                
                for (lhs, rhs) in zip(stops, stops.dropFirst()) where lhs.offset != rhs.offset && t >= lhs.offset && t <= rhs.offset {
                    
                    let s = (t - lhs.offset) / (rhs.offset - lhs.offset)
                    return lhs.color * (1 - s) + rhs.color * s
                }
                
                return first.color
            }
        }
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        self._drawGradient(stops: stops) { axialShading(start: start, end: end, startSpread: startSpread, endSpread: endSpread, shading: $0) }
    }
    
    @inlinable
    @inline(__always)
    public func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) {
        self._drawGradient(stops: stops) { radialShading(start: start, startRadius: startRadius, end: end, endRadius: endRadius, startSpread: startSpread, endSpread: endSpread, shading: $0) }
    }
}
