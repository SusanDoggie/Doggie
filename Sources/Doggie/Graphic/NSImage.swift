//
//  NSImage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

import Foundation

public enum SDImageInterpolation {
    
    case `default`
    case none
    
    /// Low quality
    case low
    
    /// Medium quality
    case medium
    
    /// Highest quality
    case high
}

#if os(iOS)
    
    import UIKit
    
    public extension UIImage {
        
        static func create(size: CGSize, scale: CGFloat = 0, command: (CGContext!) -> Void) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            command(UIGraphicsGetCurrentContext())
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
    }
    
    public extension UIImage {
        
        func resize(size: CGSize, scale: CGFloat = 0, interpolation: SDImageInterpolation) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            let context = UIGraphicsGetCurrentContext()
            switch interpolation {
            case .default:
                context!.interpolationQuality = .default
            case .none:
                context!.interpolationQuality = .none
            case .low:
                context!.interpolationQuality = .low
            case .medium:
                context!.interpolationQuality = .medium
            case .high:
                context!.interpolationQuality = .high
            }
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .copy, alpha: 1.0)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
    }
    
#endif

#if os(OSX)
    
    import AppKit
    
    public extension NSImage {
        
        static func create(size: CGSize, command: (CGContext!) -> ()) -> NSImage {
            let offscreenRep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(size.width),
                pixelsHigh: Int(size.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: NSDeviceRGBColorSpace,
                bitmapFormat: .alphaFirst,
                bytesPerRow: 0, bitsPerPixel: 0)
            let gctx = NSGraphicsContext(bitmapImageRep: offscreenRep!)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(gctx)
            command(gctx!.cgContext)
            NSGraphicsContext.restoreGraphicsState()
            
            return NSImage(cgImage: offscreenRep!.cgImage!, size: size)
        }
    }
    
    public extension NSImage {
        
        func resize(_ size: CGSize, interpolation: SDImageInterpolation) -> NSImage {
            let newImage = NSImage(size: CGSize(width: size.width, height: size.height))
            
            newImage.lockFocus()
            
            let hints: [String : AnyObject]
            
            switch interpolation {
            case .default:
                hints = [NSImageHintInterpolation: NSImageInterpolation.default.rawValue as AnyObject]
            case .none:
                hints = [NSImageHintInterpolation: NSImageInterpolation.none.rawValue as AnyObject]
            case .low:
                hints = [NSImageHintInterpolation: NSImageInterpolation.low.rawValue as AnyObject]
            case .medium:
                hints = [NSImageHintInterpolation: NSImageInterpolation.medium.rawValue as AnyObject]
            case .high:
                hints = [NSImageHintInterpolation: NSImageInterpolation.high.rawValue as AnyObject]
            }
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
            let imageRep = self.bestRepresentation(for: rect, context: nil, hints: nil)
            imageRep?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), from: rect, operation: NSCompositingOperation.copy, fraction: 1.0, respectFlipped: true, hints: hints)
            newImage.unlockFocus()
            return newImage
        }
    }
    
#endif
