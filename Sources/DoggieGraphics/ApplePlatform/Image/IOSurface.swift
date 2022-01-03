//
//  IOSurface.swift
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

#if canImport(IOSurface)

extension IOSurfaceRef {
    
    @available(iOS 11.0, tvOS 11.0, *)
    open class func propertyAlignment(forKey key: String) -> Int {
        return IOSurfaceGetPropertyAlignment(key as CFString)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open class func propertyMaximum(forKey key: String) -> Int {
        return IOSurfaceGetPropertyMaximum(key as CFString)
    }
}

extension IOSurfaceRef {
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var allocationSize: Int {
        return IOSurfaceGetAllocSize(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var width: Int {
        return IOSurfaceGetWidth(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var height: Int {
        return IOSurfaceGetHeight(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var baseAddress: UnsafeMutableRawPointer {
        return IOSurfaceGetBaseAddress(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var pixelFormat: OSType {
        return IOSurfaceGetPixelFormat(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var bytesPerRow: Int {
        return IOSurfaceGetBytesPerRow(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var bytesPerElement: Int {
        return IOSurfaceGetBytesPerElement(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var elementWidth: Int {
        return IOSurfaceGetElementWidth(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var elementHeight: Int {
        return IOSurfaceGetElementHeight(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var seed: UInt32 {
        return IOSurfaceGetSeed(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var planeCount: Int {
        return IOSurfaceGetPlaneCount(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func widthOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetWidthOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func heightOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetHeightOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func bytesPerRowOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetBytesPerRowOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func bytesPerElementOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetBytesPerElementOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func elementWidthOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetElementWidthOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func elementHeightOfPlane(at planeIndex: Int) -> Int {
        return IOSurfaceGetElementHeightOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func baseAddressOfPlane(at planeIndex: Int) -> UnsafeMutableRawPointer {
        return IOSurfaceGetBaseAddressOfPlane(self, planeIndex)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var isInUse: Bool {
        return IOSurfaceIsInUse(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func incrementUseCount() {
        IOSurfaceIncrementUseCount(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func decrementUseCount() {
        IOSurfaceDecrementUseCount(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var localUseCount: Int32 {
        return IOSurfaceGetUseCount(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open var allowsPixelSizeCasting: Bool {
        return IOSurfaceAllowsPixelSizeCasting(self)
    }
    
    @available(iOS 11.0, tvOS 11.0, *)
    open func setPurgeable(_ newState: IOSurfacePurgeabilityState, oldState: UnsafeMutablePointer<IOSurfacePurgeabilityState>?) -> kern_return_t {
        return IOSurfaceSetPurgeable(self, newState.rawValue, UnsafeMutableRawPointer(oldState)?.assumingMemoryBound(to: UInt32.self))
    }
    
    @discardableResult
    @available(iOS 11.0, tvOS 11.0, *)
    open func lock(options: IOSurfaceLockOptions = [], seed: UnsafeMutablePointer<UInt32>?) -> kern_return_t {
        return IOSurfaceLock(self, options, seed)
    }
    
    @discardableResult
    @available(iOS 11.0, tvOS 11.0, *)
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
