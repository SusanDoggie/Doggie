//
//  ColorCompositingKernel.swift
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

@usableFromInline
protocol ColorCompositingKernel {
    
    static func mix<T: ScalarMultiplicative>(
        _ source: T,
        _ source_alpha: T.Scalar,
        _ destination: T,
        _ destination_alpha: T.Scalar
    ) -> T
    
}

extension ColorCompositingMode {
    
    @frozen
    @usableFromInline
    enum ClearCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return .zero
        }
    }
    
    @frozen
    @usableFromInline
    enum CopyCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source
        }
    }
    
    @frozen
    @usableFromInline
    enum SourceOverCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source + destination * (1 - source_alpha)
        }
    }
    
    @frozen
    @usableFromInline
    enum SourceInCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source * destination_alpha
        }
    }
    
    @frozen
    @usableFromInline
    enum SourceOutCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source * (1 - destination_alpha)
        }
    }
    
    @frozen
    @usableFromInline
    enum SourceAtopCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source * destination_alpha + destination * (1 - source_alpha)
        }
    }
    
    @frozen
    @usableFromInline
    enum DestinationOverCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source * (1 - destination_alpha) + destination
        }
    }
    
    @frozen
    @usableFromInline
    enum DestinationInCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return destination * source_alpha
        }
    }
    
    @frozen
    @usableFromInline
    enum DestinationOutCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return destination * (1 - source_alpha)
        }
    }
    
    @frozen
    @usableFromInline
    enum DestinationAtopCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            return source * (1 - destination_alpha) + destination * source_alpha
        }
    }
    
    @frozen
    @usableFromInline
    enum XorCompositingKernel: ColorCompositingKernel {
        
        @inlinable
        @inline(__always)
        static func mix<T: ScalarMultiplicative>(
            _ source: T,
            _ source_alpha: T.Scalar,
            _ destination: T,
            _ destination_alpha: T.Scalar
        ) -> T {
            let _s = source * (1 - destination_alpha)
            let _d = destination * (1 - source_alpha)
            return _s + _d
        }
    }
}
