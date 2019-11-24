//
//  CGImageAnimation.swift
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

#if canImport(CoreGraphics) && canImport(ImageIO)

public struct CGImageAnimationFrame {
    
    public var image: CGImage
    public var delay: Double
    
    public init(image: CGImage, delay: Double) {
        self.image = image
        self.delay = delay
    }
}

extension CGImage {
    
    public static func animatedGIFRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImageRep.withImageDestination(kUTTypeGIF, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(destination, frame.image, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    public static func animatedPNGRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImageRep.withImageDestination(kUTTypePNG, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(destination, frame.image, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    #if canImport(AVFoundation)
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func animatedHEICRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImageRep.withImageDestination(AVFileType.heic as CFString, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyHEICSDictionary: [kCGImagePropertyHEICSLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(destination, frame.image, [kCGImagePropertyHEICSDictionary: [kCGImagePropertyHEICSDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    #endif
    
}

extension CGImage {
    
    public static func animatedGIFRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedGIFRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    public static func animatedPNGRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedPNGRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    #if canImport(AVFoundation)
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func animatedHEICRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedHEICRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    #endif
    
}

#endif
