//
//  Maths misc.swift
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

extension Complex {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.real.almostZero(epsilon: epsilon, reference: reference) && self.imag.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: Complex, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.real.almostEqual(other.real, epsilon: epsilon) && self.imag.almostEqual(other.imag, epsilon: epsilon)
    }
}

extension Point {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.x.almostZero(epsilon: epsilon, reference: reference) && self.y.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: Point, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.x.almostEqual(other.x, epsilon: epsilon) && self.y.almostEqual(other.y, epsilon: epsilon)
    }
}

extension Vector {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.x.almostZero(epsilon: epsilon, reference: reference) && self.y.almostZero(epsilon: epsilon, reference: reference) && self.z.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: Vector, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.x.almostEqual(other.x, epsilon: epsilon) && self.y.almostEqual(other.y, epsilon: epsilon) && self.z.almostEqual(other.z, epsilon: epsilon)
    }
}

extension Size {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.width.almostZero(epsilon: epsilon, reference: reference) && self.height.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: Size, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.width.almostEqual(other.width, epsilon: epsilon) && self.height.almostEqual(other.height, epsilon: epsilon)
    }
}

extension Rect {
    
    @_transparent
    public func almostEqual(_ other: Rect, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.origin.almostEqual(other.origin, epsilon: epsilon) && self.size.almostEqual(other.size, epsilon: epsilon)
    }
}

extension Radius {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.x.almostZero(epsilon: epsilon, reference: reference) && self.y.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: Radius, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.x.almostEqual(other.x, epsilon: epsilon) && self.y.almostEqual(other.y, epsilon: epsilon)
    }
}

extension SDTransform {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.a.almostZero(epsilon: epsilon, reference: reference)
            && self.b.almostZero(epsilon: epsilon, reference: reference)
            && self.c.almostZero(epsilon: epsilon, reference: reference)
            && self.d.almostZero(epsilon: epsilon, reference: reference)
            && self.e.almostZero(epsilon: epsilon, reference: reference)
            && self.f.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: SDTransform, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.a.almostEqual(other.a, epsilon: epsilon)
            && self.b.almostEqual(other.b, epsilon: epsilon)
            && self.c.almostEqual(other.c, epsilon: epsilon)
            && self.d.almostEqual(other.d, epsilon: epsilon)
            && self.e.almostEqual(other.e, epsilon: epsilon)
            && self.f.almostEqual(other.f, epsilon: epsilon)
    }
}

extension Matrix {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.a.almostZero(epsilon: epsilon, reference: reference)
            && self.b.almostZero(epsilon: epsilon, reference: reference)
            && self.c.almostZero(epsilon: epsilon, reference: reference)
            && self.d.almostZero(epsilon: epsilon, reference: reference)
            && self.e.almostZero(epsilon: epsilon, reference: reference)
            && self.f.almostZero(epsilon: epsilon, reference: reference)
            && self.g.almostZero(epsilon: epsilon, reference: reference)
            && self.h.almostZero(epsilon: epsilon, reference: reference)
            && self.i.almostZero(epsilon: epsilon, reference: reference)
            && self.j.almostZero(epsilon: epsilon, reference: reference)
            && self.k.almostZero(epsilon: epsilon, reference: reference)
            && self.l.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @_transparent
    public func almostEqual(_ other: Matrix, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return self.a.almostEqual(other.a, epsilon: epsilon)
            && self.b.almostEqual(other.b, epsilon: epsilon)
            && self.c.almostEqual(other.c, epsilon: epsilon)
            && self.d.almostEqual(other.d, epsilon: epsilon)
            && self.e.almostEqual(other.e, epsilon: epsilon)
            && self.f.almostEqual(other.f, epsilon: epsilon)
            && self.g.almostEqual(other.g, epsilon: epsilon)
            && self.h.almostEqual(other.h, epsilon: epsilon)
            && self.i.almostEqual(other.i, epsilon: epsilon)
            && self.j.almostEqual(other.j, epsilon: epsilon)
            && self.k.almostEqual(other.k, epsilon: epsilon)
            && self.l.almostEqual(other.l, epsilon: epsilon)
    }
}

extension Polynomial {
    
    @_transparent
    public func almostZero(epsilon: Double = Double.defaultAlmostEqualEpsilon, reference: Double = 0) -> Bool {
        
        return self.all { $0.almostZero(epsilon: epsilon, reference: reference) }
    }
    
    @_transparent
    public func almostEqual(_ other: Polynomial, epsilon: Double = Double.defaultAlmostEqualEpsilon) -> Bool {
        
        return (0..<Swift.max(self.count, other.count)).all { self[$0].almostEqual(other[$0], epsilon: epsilon) }
    }
}
