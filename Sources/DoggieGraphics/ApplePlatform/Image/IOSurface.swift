//
//  IOSurface.swift
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

#if canImport(IOSurface)

extension IOSurfaceRef {
    
    public class func propertyAlignment(forKey key: String) -> Int {
        return IOSurfaceGetPropertyAlignment(key as CFString)
    }
    
    public class func propertyMaximum(forKey key: String) -> Int {
        return IOSurfaceGetPropertyMaximum(key as CFString)
    }
}

extension IOSurfaceRef {
    
    public var allocationSize: Int {
        return IOSurfaceGetAllocSize(self)
    }
    
    public var width: Int {
        return IOSurfaceGetWidth(self)
    }
    
    public var height: Int {
        return IOSurfaceGetHeight(self)
    }
    
    public var baseAddress: UnsafeMutableRawPointer {
        return IOSurfaceGetBaseAddress(self)
    }
    
    public var pixelFormat: OSType {
        return IOSurfaceGetPixelFormat(self)
    }
    
    public var bytesPerRow: Int {
        return IOSurfaceGetBytesPerRow(self)
    }
    
    public var bytesPerElement: Int {
        return IOSurfaceGetBytesPerElement(self)
    }
    
    public var elementWidth: Int {
        return IOSurfaceGetElementWidth(self)
    }
    
    public var elementHeight: Int {
        return IOSurfaceGetElementHeight(self)
    }
    
    public var seed: UInt32 {
        return IOSurfaceGetSeed(self)
    }
    
    public var planeCount: Int {
        return IOSurfaceGetPlaneCount(self)
    }
    
    public func widthOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetWidthOfPlane(self, planeIndex)
    }
    
    public func heightOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetHeightOfPlane(self, planeIndex)
    }
    
    public func bytesPerRowOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetBytesPerRowOfPlane(self, planeIndex)
    }
    
    public func bytesPerElementOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetBytesPerElementOfPlane(self, planeIndex)
    }
    
    public func elementWidthOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetElementWidthOfPlane(self, planeIndex)
    }
    
    public func elementHeightOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetElementHeightOfPlane(self, planeIndex)
    }
    
    public func baseAddressOfPlane(at planeIndex: Int) -> UnsafeMutableRawPointer {
        return IOSurfaceGetBaseAddressOfPlane(self, planeIndex)
    }
    
    public var isInUse: Bool {
        return IOSurfaceIsInUse(self)
    }
    
    public func incrementUseCount() {
        IOSurfaceIncrementUseCount(self)
    }
    
    public func decrementUseCount() {
        IOSurfaceDecrementUseCount(self)
    }
    
    public var localUseCount: Int32 {
        return IOSurfaceGetUseCount(self)
    }
    
    public var allowsPixelSizeCasting: Bool {
        return IOSurfaceAllowsPixelSizeCasting(self)
    }
    
    public func setPurgeable(_ newState: IOSurfacePurgeabilityState, oldState: UnsafeMutablePointer<IOSurfacePurgeabilityState>?) -> kern_return_t {
        return IOSurfaceSetPurgeable(self, newState.rawValue, UnsafeMutableRawPointer(oldState)?.assumingMemoryBound(to: UInt32.self))
    }
    
    @discardableResult
    public func lock(options: IOSurfaceLockOptions = [], seed: UnsafeMutablePointer<UInt32>?) -> kern_return_t {
        return IOSurfaceLock(self, options, seed)
    }
    
    @discardableResult
    public func unlock(options: IOSurfaceLockOptions = [], seed: UnsafeMutablePointer<UInt32>?) -> kern_return_t {
        return IOSurfaceUnlock(self, options, seed)
    }
}

extension IOSurfaceRef {
    
    public func numberOfComponentsOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetNumberOfComponentsOfPlane(self, planeIndex)
    }
    
    public func nameOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> IOSurfaceComponentName {
        return IOSurfaceGetNameOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    public func rangeOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> IOSurfaceComponentRange {
        return IOSurfaceGetRangeOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    public func bitDepthOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> Int {
        return IOSurfaceGetBitDepthOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    public func bitOffsetOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> Int {
        return IOSurfaceGetBitOffsetOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    public func typeOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> IOSurfaceComponentType {
        return IOSurfaceGetTypeOfComponentOfPlane(self, planeIndex, componentIndex)
    }
}

#endif
