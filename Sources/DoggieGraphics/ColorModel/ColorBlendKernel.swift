//
//  ColorBlendKernel.swift
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

@usableFromInline
protocol ColorBlendKernel {
    
    static func blend<C: ColorModel>(_ source: C, _ destination: C) -> C
    
    static func blend<C: ColorComponents>(_ source: C, _ destination: C) -> C
    
    static func combine<C: ColorModel>(
        _ source: C,
        _ destination: C,
        _ destination_alpha: C.Scalar
    ) -> C
    
    static func combine<C: ColorComponents>(
        _ source: C,
        _ destination: C,
        _ destination_alpha: C.Scalar
    ) -> C
    
}

extension ColorBlendKernel {
    
    @inlinable
    @inline(__always)
    static func blend<C: ColorComponents>(_ source: C, _ destination: C) -> C {
        return C(self.blend(source.model, destination.model))
    }
    
    @inlinable
    @inline(__always)
    static func combine<C: ColorModel>(
        _ source: C,
        _ destination: C,
        _ destination_alpha: C.Scalar
    ) -> C {
        return (1 - destination_alpha) * source + destination_alpha * Self.blend(source, destination)
    }
    
    @inlinable
    @inline(__always)
    static func combine<C: ColorComponents>(
        _ source: C,
        _ destination: C,
        _ destination_alpha: C.Scalar
    ) -> C {
        return (1 - destination_alpha) * source + destination_alpha * Self.blend(source, destination)
    }
    
}

@usableFromInline
protocol ElementwiseColorBlendKernel: ColorBlendKernel {
    
    static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T
    
}

extension ColorBlendKernel where Self: ElementwiseColorBlendKernel {
    
    @inlinable
    @inline(__always)
    static func blend<C: ColorModel>(_ source: C, _ destination: C) -> C {
        return source.combined(destination, self.blend)
    }
    
    @inlinable
    @inline(__always)
    static func blend<C: ColorComponents>(_ source: C, _ destination: C) -> C {
        return source.combined(destination, self.blend)
    }
    
}

extension ColorBlendMode {
    
    @frozen
    @usableFromInline
    enum NormalBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return source
        }
        
        @inlinable
        @inline(__always)
        static func combine<C: ColorModel>(
            _ source: C,
            _ destination: C,
            _ destination_alpha: C.Scalar
        ) -> C {
            return source
        }
        
        @inlinable
        @inline(__always)
        static func combine<C: ColorComponents>(
            _ source: C,
            _ destination: C,
            _ destination_alpha: C.Scalar
        ) -> C {
            return source
        }
    }
    
    @frozen
    @usableFromInline
    enum MultiplyBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return destination * source
        }
    }
    
    @frozen
    @usableFromInline
    enum ScreenBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return destination + source - destination * source
        }
    }
    
    @frozen
    @usableFromInline
    enum OverlayBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            
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
    enum DarkenBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return min(destination, source)
        }
    }
    
    @frozen
    @usableFromInline
    enum LightenBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return max(destination, source)
        }
    }
    
    @frozen
    @usableFromInline
    enum ColorDodgeBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return source < 1 ? min(1, destination / (1 - source)) : 1
        }
    }
    
    @frozen
    @usableFromInline
    enum ColorBurnBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return source > 0 ? 1 - min(1, (1 - destination) / source) : 0
        }
    }
    
    @frozen
    @usableFromInline
    enum SoftLightBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            
            let u = 1 - 2 * source
            
            if source < 0.5 {
                return destination - u * destination * (1 - destination)
            }
            
            let db: T
            
            if destination < 0.25 {
                let s = 16 * destination - 12
                let t = s * destination + 4
                db = t * destination
            } else {
                db = sqrt(destination)
            }
            
            return destination - u * (db - destination)
        }
    }
    
    @frozen
    @usableFromInline
    enum HardLightBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return OverlayBlendKernel.blend(source, destination)
        }
    }
    
    @frozen
    @usableFromInline
    enum DifferenceBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return abs(destination - source)
        }
    }
    
    @frozen
    @usableFromInline
    enum ExclusionBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return destination + source - 2 * destination * source
        }
    }
    
    @frozen
    @usableFromInline
    enum PlusDarkerBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            let u = 1 - destination
            let v = 1 - source
            return max(0, 1 - (u + v))
        }
    }
    
    @frozen
    @usableFromInline
    enum PlusLighterBlendKernel: ElementwiseColorBlendKernel {
        
        @inlinable
        @inline(__always)
        static func blend<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
            return min(1, destination + source)
        }
    }
}
