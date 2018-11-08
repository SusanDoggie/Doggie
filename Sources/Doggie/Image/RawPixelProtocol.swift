//
//  RawPixelProtocol.swift
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

public protocol RawPixelProtocol {
    
    associatedtype RawPixel
    
    var width: Int { get }
    
    var height: Int { get }
    
    var pixels: MappedBuffer<RawPixel> { get }
    
    var fileBacked: Bool { get set }
    
    func setMemoryAdvise(_ advise: MemoryAdvise)
    
    func memoryLock()
    
    func memoryUnlock()
    
    mutating func setOrientation(_ orientation: ImageOrientation)
    
    func transposed() -> Self
    
    func verticalFlipped() -> Self
    
    func horizontalFlipped() -> Self
    
    func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<RawPixel>) throws -> R) rethrows -> R
    
    mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<RawPixel>) throws -> R) rethrows -> R
    
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
    
    mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R
}

extension RawPixelProtocol {
    
    @inlinable
    @inline(__always)
    public mutating func setOrientation(_ orientation: ImageOrientation) {
        
        switch orientation {
        case .leftMirrored, .left, .rightMirrored, .right: self = self.transposed()
        default: break
        }
        
        let width = self.width
        let height = self.height
        
        guard width != 0 && height != 0 else { return }
        
        switch orientation {
        case .right, .upMirrored:
            
            self.withUnsafeMutableBufferPointer {
                
                guard let buffer = $0.baseAddress else { return }
                
                var buf1 = buffer
                var buf2 = buffer + width - 1
                
                for _ in 0..<width >> 1 {
                    Swap(height, buf1, width, buf2, width)
                    buf1 += 1
                    buf2 -= 1
                }
            }
            
        case .left, .downMirrored:
            
            self.withUnsafeMutableBufferPointer {
                
                guard let buffer = $0.baseAddress else { return }
                
                var buf1 = buffer
                var buf2 = buffer + width * (height - 1)
                
                for _ in 0..<height >> 1 {
                    Swap(width, buf1, 1, buf2, 1)
                    buf1 += width
                    buf2 -= width
                }
            }
            
        case .down, .rightMirrored:
            
            self.withUnsafeMutableBufferPointer {
                guard let buffer = $0.baseAddress else { return }
                Swap($0.count >> 1, buffer, 1, buffer + $0.count - 1, -1)
            }
            
        default: break
        }
    }
}

extension RawPixelProtocol {
    
    @inlinable
    @inline(__always)
    public func verticalFlipped() -> Self {
        var copy = self
        copy.setOrientation(.downMirrored)
        return copy
    }
    
    @inlinable
    @inline(__always)
    public func horizontalFlipped() -> Self {
        var copy = self
        copy.setOrientation(.upMirrored)
        return copy
    }
}
