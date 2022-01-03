//
//  MathsExtension.swift
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

extension Point {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        return self.x.almostZero(epsilon: epsilon, reference: reference) && self.y.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Point, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return self.x.almostEqual(other.x, epsilon: epsilon) && self.y.almostEqual(other.y, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Point, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return self.x.almostEqual(other.x, epsilon: epsilon, reference: reference) && self.y.almostEqual(other.y, epsilon: epsilon, reference: reference)
    }
}

extension Vector {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        return self.x.almostZero(epsilon: epsilon, reference: reference) && self.y.almostZero(epsilon: epsilon, reference: reference) && self.z.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Vector, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return self.x.almostEqual(other.x, epsilon: epsilon) && self.y.almostEqual(other.y, epsilon: epsilon) && self.z.almostEqual(other.z, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Vector, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return self.x.almostEqual(other.x, epsilon: epsilon, reference: reference) && self.y.almostEqual(other.y, epsilon: epsilon, reference: reference) && self.z.almostEqual(other.z, epsilon: epsilon, reference: reference)
    }
}

extension Size {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        return self.width.almostZero(epsilon: epsilon, reference: reference) && self.height.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Size, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return self.width.almostEqual(other.width, epsilon: epsilon) && self.height.almostEqual(other.height, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Size, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return self.width.almostEqual(other.width, epsilon: epsilon, reference: reference) && self.height.almostEqual(other.height, epsilon: epsilon, reference: reference)
    }
}

extension Rect {
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Rect, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return self.origin.almostEqual(other.origin, epsilon: epsilon) && self.size.almostEqual(other.size, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Rect, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return self.origin.almostEqual(other.origin, epsilon: epsilon, reference: reference) && self.size.almostEqual(other.size, epsilon: epsilon, reference: reference)
    }
}

extension Radius {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        return self.x.almostZero(epsilon: epsilon, reference: reference) && self.y.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Radius, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        return self.x.almostEqual(other.x, epsilon: epsilon) && self.y.almostEqual(other.y, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Radius, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        return self.x.almostEqual(other.x, epsilon: epsilon, reference: reference) && self.y.almostEqual(other.y, epsilon: epsilon, reference: reference)
    }
}

extension SDTransform {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        
        return self.a.almostZero(epsilon: epsilon, reference: reference)
            && self.b.almostZero(epsilon: epsilon, reference: reference)
            && self.c.almostZero(epsilon: epsilon, reference: reference)
            && self.d.almostZero(epsilon: epsilon, reference: reference)
            && self.e.almostZero(epsilon: epsilon, reference: reference)
            && self.f.almostZero(epsilon: epsilon, reference: reference)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: SDTransform, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        
        return self.a.almostEqual(other.a, epsilon: epsilon)
            && self.b.almostEqual(other.b, epsilon: epsilon)
            && self.c.almostEqual(other.c, epsilon: epsilon)
            && self.d.almostEqual(other.d, epsilon: epsilon)
            && self.e.almostEqual(other.e, epsilon: epsilon)
            && self.f.almostEqual(other.f, epsilon: epsilon)
    }
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: SDTransform, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        
        return self.a.almostEqual(other.a, epsilon: epsilon, reference: reference)
            && self.b.almostEqual(other.b, epsilon: epsilon, reference: reference)
            && self.c.almostEqual(other.c, epsilon: epsilon, reference: reference)
            && self.d.almostEqual(other.d, epsilon: epsilon, reference: reference)
            && self.e.almostEqual(other.e, epsilon: epsilon, reference: reference)
            && self.f.almostEqual(other.f, epsilon: epsilon, reference: reference)
    }
}

extension Matrix {
    
    @inlinable
    @inline(__always)
    public func almostZero(epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double = 0) -> Bool {
        
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
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Matrix, epsilon: Double = Double.ulpOfOne.squareRoot()) -> Bool {
        
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
    
    @inlinable
    @inline(__always)
    public func almostEqual(_ other: Matrix, epsilon: Double = Double.ulpOfOne.squareRoot(), reference: Double) -> Bool {
        
        return self.a.almostEqual(other.a, epsilon: epsilon, reference: reference)
            && self.b.almostEqual(other.b, epsilon: epsilon, reference: reference)
            && self.c.almostEqual(other.c, epsilon: epsilon, reference: reference)
            && self.d.almostEqual(other.d, epsilon: epsilon, reference: reference)
            && self.e.almostEqual(other.e, epsilon: epsilon, reference: reference)
            && self.f.almostEqual(other.f, epsilon: epsilon, reference: reference)
            && self.g.almostEqual(other.g, epsilon: epsilon, reference: reference)
            && self.h.almostEqual(other.h, epsilon: epsilon, reference: reference)
            && self.i.almostEqual(other.i, epsilon: epsilon, reference: reference)
            && self.j.almostEqual(other.j, epsilon: epsilon, reference: reference)
            && self.k.almostEqual(other.k, epsilon: epsilon, reference: reference)
            && self.l.almostEqual(other.l, epsilon: epsilon, reference: reference)
    }
}
