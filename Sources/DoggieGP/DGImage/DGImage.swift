//
//  DGImage.swift
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

import Doggie

public class DGImage<Model : ColorModelProtocol> {
    
    private let kernel: Kernel
    
    private init(kernel: Kernel) {
        self.kernel = kernel
    }
    
    public init() {
        self.kernel = Kernel()
    }
    
    public init(image: Image<FloatColorPixel<Model>>) {
        self.kernel = _Image(image: image)
    }
}

extension DGImage {
    
    public func applying(_ kernel: Kernel) -> DGImage {
        return DGImage(kernel: self.kernel.appending(kernel))
    }
}

extension DGImage {
    
    private class _Image : Kernel {
        
        let width: Int
        let height: Int
        
        let pixels: MappedBuffer<FloatColorPixel<Model>>
        
        init(image: Image<FloatColorPixel<Model>>) {
            self.width = image.width
            self.height = image.height
            self.pixels = image.pixels
        }
    }
    
    private class _KernelChain : Kernel {
        
        let chain: [Kernel]
        
        init(chain: [Kernel]) {
            self.chain = chain
        }
        
        override func appending(_ kernel: Kernel) -> Kernel {
            return _KernelChain(chain: self.chain + [kernel])
        }
    }
    
    open class Kernel {
        
        let source: Kernel?
        
        public init() {
            self.source = nil
        }
        
        func appending(_ kernel: Kernel) -> Kernel {
            return _KernelChain(chain: [self, kernel])
        }
    }
    
    open class WarpKernel : Kernel {
        
    }
    
    open class ColorKernel : Kernel {
        
    }
    
    open class BlendKernel : ColorKernel {
        
        let background: Kernel
        
        public init(background: Kernel) {
            self.background = background
        }
    }
}
