//
//  CoreVideo.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

#if canImport(CoreVideo)

extension CVImageBuffer {
    
    public var encodedSize: CGSize {
        return CVImageBufferGetEncodedSize(self)
    }
    
    public var displaySize: CGSize {
        return CVImageBufferGetDisplaySize(self)
    }
    
    public var cleanRect: CGRect {
        return CVImageBufferGetCleanRect(self)
    }
    
    public var isFlipped: Bool {
        return CVImageBufferIsFlipped(self)
    }
}

extension CVPixelBuffer {
    
    public var width: Int {
        return CVPixelBufferGetWidth(self)
    }
    
    public var height: Int {
        return CVPixelBufferGetHeight(self)
    }
    
    public var pixelFormat: CVPixelFormat {
        return CVPixelFormat(rawValue: CVPixelBufferGetPixelFormatType(self))
    }
    
    public var baseAddress: UnsafeMutableRawPointer? {
        return CVPixelBufferGetBaseAddress(self)
    }
    
    public var bytesPerRow: Int {
        return CVPixelBufferGetBytesPerRow(self)
    }
    
    public var dataSize: Int {
        return CVPixelBufferGetDataSize(self)
    }
    
    public var isPlanar: Bool {
        return CVPixelBufferIsPlanar(self)
    }
    
    public var planeCount: Int {
        return CVPixelBufferGetPlaneCount(self)
    }
    
    public var ioSurface: Unmanaged<IOSurfaceRef>? {
        return CVPixelBufferGetIOSurface(self)
    }
    
    public func widthOfPlane(_ planeIndex: Int) -> Int {
        return CVPixelBufferGetWidthOfPlane(self, planeIndex)
    }
    
    public func heightOfPlane(_ planeIndex: Int) -> Int {
        return CVPixelBufferGetHeightOfPlane(self, planeIndex)
    }
    
    public func baseAddressOfPlane(_ planeIndex: Int) -> UnsafeMutableRawPointer? {
        return CVPixelBufferGetBaseAddressOfPlane(self, planeIndex)
    }
    
    public func bytesPerRowOfPlane(_ planeIndex: Int) -> Int {
        return CVPixelBufferGetBytesPerRowOfPlane(self, planeIndex)
    }
    
    @frozen
    public struct ExtendedPixels: Hashable {
        
        public var top: Int
        
        public var left: Int
        
        public var right: Int
        
        public var bottom: Int
    }

    public var extendedPixels: ExtendedPixels {
        var extended = ExtendedPixels(top: 0, left: 0, right: 0, bottom: 0)
        CVPixelBufferGetExtendedPixels(self, &extended.left, &extended.right, &extended.top, &extended.bottom)
        return extended
    }
    
    public func fillExtendedPixels() -> CVReturn {
        return CVPixelBufferFillExtendedPixels(self)
    }
    
    @discardableResult
    public func lock(_ lockFlags: CVPixelBufferLockFlags = []) -> CVReturn {
        return CVPixelBufferLockBaseAddress(self, lockFlags)
    }
    
    @discardableResult
    public func unlock(_ unlockFlags: CVPixelBufferLockFlags = []) -> CVReturn {
        return CVPixelBufferUnlockBaseAddress(self, unlockFlags)
    }
    
}

#endif
