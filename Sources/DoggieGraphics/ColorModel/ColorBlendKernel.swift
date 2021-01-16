//
//  ColorBlendKernel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

public protocol ColorBlendKernel {
    
    static func blend<C: ColorModel>(_ destination: C, _ source: C) -> C
    
    static func blend<C: ColorComponents>(_ destination: C, _ source: C) -> C
    
}

extension ColorBlendKernel {
    
    @inlinable
    @inline(__always)
    public static func blend<C: ColorComponents>(_ destination: C, _ source: C) -> C {
        return C(self.blend(destination.model, source.model))
    }
}

public protocol ElementwiseColorBlendKernel: ColorBlendKernel {
    
    static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T
    
}

extension ColorBlendKernel where Self: ElementwiseColorBlendKernel {
    
    @inlinable
    @inline(__always)
    public static func blend<C: ColorModel>(_ destination: C, _ source: C) -> C {
        return destination.combined(source, self.blend)
    }
    
    @inlinable
    @inline(__always)
    public static func blend<C: ColorComponents>(_ destination: C, _ source: C) -> C {
        return destination.combined(source, self.blend)
    }
    
}

extension ColorBlendMode {
    
    @frozen
    @usableFromInline
    struct NormalBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return source
        }
    }
    
    @frozen
    @usableFromInline
    struct MultiplyBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return destination * source
        }
    }
    
    @frozen
    @usableFromInline
    struct ScreenBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return destination + source - destination * source
        }
    }
    
    @frozen
    @usableFromInline
    struct OverlayBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            
            if destination < 0.5 {
                return 2 * destination * source
            }
            let u = 1 - destination
            let v = 1 - source
            return 1 - 2 * u * v
        }
    }
    
    @frozen
    @usableFromInline
    struct DarkenBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return min(destination, source)
        }
    }
    
    @frozen
    @usableFromInline
    struct LightenBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return max(destination, source)
        }
    }
    
    @frozen
    @usableFromInline
    struct ColorDodgeBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return source < 1 ? min(1, destination / (1 - source)) : 1
        }
    }
    
    @frozen
    @usableFromInline
    struct ColorBurnBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return source > 0 ? 1 - min(1, (1 - destination) / source) : 0
        }
    }
    
    @frozen
    @usableFromInline
    struct SoftLightBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            
            let db: T
            
            if destination < 0.25 {
                let s = 16 * destination - 12
                let t = s * destination + 4
                db = t * destination
            } else {
                db = sqrt(destination)
            }
            
            let u = 1 - 2 * source
            
            if source < 0.5 {
                return destination - u * destination * (1 - destination)
            }
            return destination - u * (db - destination)
        }
    }
    
    @frozen
    @usableFromInline
    struct HardLightBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return OverlayBlendKernel.blend(source, destination)
        }
    }
    
    @frozen
    @usableFromInline
    struct DifferenceBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return abs(destination - source)
        }
    }
    
    @frozen
    @usableFromInline
    struct ExclusionBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return destination + source - 2 * destination * source
        }
    }
    
    @frozen
    @usableFromInline
    struct PlusDarkerBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            let u = 1 - destination
            let v = 1 - source
            return max(0, 1 - (u + v))
        }
    }
    
    @frozen
    @usableFromInline
    struct PlusLighterBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
            return min(1, destination + source)
        }
    }
}
