//
//  IOSurface.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(IOSurface)

extension IOSurfaceRef {
    
    open class func propertyAlignment(forKey key: String) -> Int {
        return IOSurfaceGetPropertyAlignment(key as CFString)
    }
    
    open class func propertyMaximum(forKey key: String) -> Int {
        return IOSurfaceGetPropertyMaximum(key as CFString)
    }
}

extension IOSurfaceRef {
    
    open var allocationSize: Int {
        return IOSurfaceGetAllocSize(self)
    }
    
    open var width: Int {
        return IOSurfaceGetWidth(self)
    }
    
    open var height: Int {
        return IOSurfaceGetHeight(self)
    }
    
    open var baseAddress: UnsafeMutableRawPointer {
        return IOSurfaceGetBaseAddress(self)
    }
    
    open var pixelFormat: OSType {
        return IOSurfaceGetPixelFormat(self)
    }
    
    open var bytesPerRow: Int {
        return IOSurfaceGetBytesPerRow(self)
    }
    
    open var bytesPerElement: Int {
        return IOSurfaceGetBytesPerElement(self)
    }
    
    open var elementWidth: Int {
        return IOSurfaceGetElementWidth(self)
    }
    
    open var elementHeight: Int {
        return IOSurfaceGetElementHeight(self)
    }
    
    open var seed: UInt32 {
        return IOSurfaceGetSeed(self)
    }
    
    open var planeCount: Int {
        return IOSurfaceGetPlaneCount(self)
    }
    
    open func widthOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetWidthOfPlane(self, planeIndex)
    }
    
    open func heightOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetHeightOfPlane(self, planeIndex)
    }
    
    open func bytesPerRowOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetBytesPerRowOfPlane(self, planeIndex)
    }
    
    open func bytesPerElementOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetBytesPerElementOfPlane(self, planeIndex)
    }
    
    open func elementWidthOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetElementWidthOfPlane(self, planeIndex)
    }
    
    open func elementHeightOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetElementHeightOfPlane(self, planeIndex)
    }
    
    open func baseAddressOfPlane(at planeIndex: Int) -> UnsafeMutableRawPointer {
        return IOSurfaceGetBaseAddressOfPlane(self, planeIndex)
    }
    
    open var isInUse: Bool {
        return IOSurfaceIsInUse(self)
    }
    
    open func incrementUseCount() {
        IOSurfaceIncrementUseCount(self)
    }
    
    open func decrementUseCount() {
        IOSurfaceDecrementUseCount(self)
    }
    
    open var localUseCount: Int32 {
        return IOSurfaceGetUseCount(self)
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open var allowsPixelSizeCasting: Bool {
        return IOSurfaceAllowsPixelSizeCasting(self)
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open func setPurgeable(_ newState: IOSurfacePurgeabilityState, oldState: UnsafeMutablePointer<IOSurfacePurgeabilityState>?) -> kern_return_t {
        return IOSurfaceSetPurgeable(self, newState.rawValue, UnsafeMutableRawPointer(oldState)?.assumingMemoryBound(to: UInt32.self))
    }
    
    @discardableResult
    open func lock(options: IOSurfaceLockOptions = [], seed: UnsafeMutablePointer<UInt32>?) -> kern_return_t {
        return IOSurfaceLock(self, options, seed)
    }
    
    @discardableResult
    open func unlock(options: IOSurfaceLockOptions = [], seed: UnsafeMutablePointer<UInt32>?) -> kern_return_t {
        return IOSurfaceUnlock(self, options, seed)
    }
}

extension IOSurfaceRef {
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func numberOfComponentsOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetNumberOfComponentsOfPlane(self, planeIndex)
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func nameOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> IOSurfaceComponentName {
        return IOSurfaceGetNameOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func rangeOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> IOSurfaceComponentRange {
        return IOSurfaceGetRangeOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func bitDepthOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> Int {
        return IOSurfaceGetBitDepthOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func bitOffsetOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> Int {
        return IOSurfaceGetBitOffsetOfComponentOfPlane(self, planeIndex, componentIndex)
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func typeOfComponentOfPlane(_ componentIndex: Int, at planeIndex: Int) -> IOSurfaceComponentType {
        return IOSurfaceGetTypeOfComponentOfPlane(self, planeIndex, componentIndex)
    }
}

#endif
