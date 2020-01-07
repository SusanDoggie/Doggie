//
//  CoreVideo.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

#if canImport(CoreVideo)

extension CVImageBuffer {
    
    open var encodedSize: CGSize {
        return CVImageBufferGetEncodedSize(self)
    }
    
    open var displaySize: CGSize {
        return CVImageBufferGetDisplaySize(self)
    }
    
    open var cleanRect: CGRect {
        return CVImageBufferGetCleanRect(self)
    }
    
    open var isFlipped: Bool {
        return CVImageBufferIsFlipped(self)
    }
}

extension CVPixelBuffer {
    
    open var width: Int {
        return CVPixelBufferGetWidth(self)
    }
    
    open var height: Int {
        return CVPixelBufferGetHeight(self)
    }
    
    open var pixelFormat: OSType {
        return CVPixelBufferGetPixelFormatType(self)
    }
    
    open var baseAddress: UnsafeMutableRawPointer? {
        return CVPixelBufferGetBaseAddress(self)
    }
    
    open var bytesPerRow: Int {
        return CVPixelBufferGetBytesPerRow(self)
    }
    
    open var dataSize: Int {
        return CVPixelBufferGetDataSize(self)
    }
    
    open var isPlanar: Bool {
        return CVPixelBufferIsPlanar(self)
    }
    
    open var planeCount: Int {
        return CVPixelBufferGetPlaneCount(self)
    }
    
    open var ioSurface: Unmanaged<IOSurfaceRef>? {
        return CVPixelBufferGetIOSurface(self)
    }
    
    open func widthOfPlane(_ planeIndex: Int) -> Int {
        return CVPixelBufferGetWidthOfPlane(self, planeIndex)
    }
    
    open func heightOfPlane(_ planeIndex: Int) -> Int {
        return CVPixelBufferGetHeightOfPlane(self, planeIndex)
    }
    
    open func baseAddressOfPlane(_ planeIndex: Int) -> UnsafeMutableRawPointer? {
        return CVPixelBufferGetBaseAddressOfPlane(self, planeIndex)
    }
    
    open func bytesPerRowOfPlane(_ planeIndex: Int) -> Int {
        return CVPixelBufferGetBytesPerRowOfPlane(self, planeIndex)
    }
    
    @frozen
    public struct ExtendedPixels: Hashable {
        
        public var top: Int
        
        public var left: Int
        
        public var right: Int
        
        public var bottom: Int
    }

    open var extendedPixels: ExtendedPixels {
        var extended = ExtendedPixels(top: 0, left: 0, right: 0, bottom: 0)
        CVPixelBufferGetExtendedPixels(self, &extended.left, &extended.right, &extended.top, &extended.bottom)
        return extended
    }
    
    open func fillExtendedPixels() -> CVReturn {
        return CVPixelBufferFillExtendedPixels(self)
    }
    
    @discardableResult
    open func lock(_ lockFlags: CVPixelBufferLockFlags = []) -> CVReturn {
        return CVPixelBufferLockBaseAddress(self, lockFlags)
    }
    
    @discardableResult
    open func unlock(_ unlockFlags: CVPixelBufferLockFlags = []) -> CVReturn {
        return CVPixelBufferUnlockBaseAddress(self, unlockFlags)
    }
    
}

extension CVMetalTexture {
    
    open var texture: MTLTexture? {
        return CVMetalTextureGetTexture(self)
    }
    
    open func cleanTexCoords(_ lowerLeft: UnsafeMutablePointer<Float>, _ lowerRight: UnsafeMutablePointer<Float>, _ upperRight: UnsafeMutablePointer<Float>, _ upperLeft: UnsafeMutablePointer<Float>) {
        return CVMetalTextureGetCleanTexCoords(self, lowerLeft, lowerRight, upperRight, upperLeft)
    }

}

#endif
