//
//  CoreImage.swift
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

#if canImport(CoreImage)

extension CIImage {
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func sharpenLuminance(sharpness: Float = 0.4,
                               radius: Float = 1.69) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.sharpenLuminance()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.sharpness = sharpness
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISharpenLuminance") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func unsharpMask(radius: Float = 2.5,
                          intensity: Float = 0.5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.unsharpMask()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIUnsharpMask") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func circularScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                             width: Float = 6,
                             sharpness: Float = 0.7) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.circularScreen()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.width = width
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CICircularScreen") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func cmykHalftone(center: CGPoint = CGPoint(x: 150, y: 150),
                           width: Float = 6,
                           angle: Float = 0,
                           sharpness: Float = 0.7,
                           grayComponentReplacement: Float = 1,
                           underColorRemoval: Float = 0.5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.cmykHalftone()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.width = width
            filter.angle = angle
            filter.sharpness = sharpness
            filter.setValue(grayComponentReplacement, forKey: "inputGCR")
            filter.setValue(underColorRemoval, forKey: "inputUCR")
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CICMYKHalftone") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            filter.setValue(grayComponentReplacement, forKey: "inputGCR")
            filter.setValue(underColorRemoval, forKey: "inputUCR")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func dotScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                        angle: Float = 0,
                        width: Float = 6,
                        sharpness: Float = 0.7) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.dotScreen()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIDotScreen") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func hatchedScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                            angle: Float = 0,
                            width: Float = 6,
                            sharpness: Float = 0.7) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.hatchedScreen()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIHatchedScreen") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func lineScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                         angle: Float = 0,
                         width: Float = 6,
                         sharpness: Float = 0.7) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.lineScreen()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CILineScreen") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func bicubicScaleTransform(scale: Float = 1,
                                    aspectRatio: Float = 1,
                                    b: Float = 0,
                                    c: Float = 0.75) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.bicubicScaleTransform()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.scale = scale
            filter.aspectRatio = aspectRatio
            filter.setValue(b, forKey: "inputB")
            filter.setValue(c, forKey: "inputC")
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBicubicScaleTransform") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            filter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            filter.setValue(b, forKey: "inputB")
            filter.setValue(c, forKey: "inputC")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open func edgePreserveUpsample(smallImage: CIImage,
                                   spatialSigma: Float = 3,
                                   lumaSigma: Float = 0.15) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.edgePreserveUpsample()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.smallImage = smallImage
            filter.spatialSigma = spatialSigma
            filter.lumaSigma = lumaSigma
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIEdgePreserveUpsampleFilter") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(smallImage, forKey: "inputSmallImage")
            filter.setValue(spatialSigma, forKey: "inputSpatialSigma")
            filter.setValue(lumaSigma, forKey: "inputLumaSigma")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func keystoneCorrectionCombined(focalLength: Float = 28) -> CIImage {
        
        let filter = CIFilter.keystoneCorrectionCombined()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.focalLength = focalLength
        
        return filter.outputImage
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func keystoneCorrectionHorizontal(focalLength: Float = 28) -> CIImage {
        
        let filter = CIFilter.keystoneCorrectionHorizontal()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.focalLength = focalLength
        
        return filter.outputImage
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func keystoneCorrectionVertical(focalLength: Float = 28) -> CIImage {
        
        let filter = CIFilter.keystoneCorrectionVertical()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.focalLength = focalLength
        
        return filter.outputImage
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func lanczosScaleTransform(scale: Float = 1,
                                    aspectRatio: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.lanczosScaleTransform()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.scale = scale
            filter.aspectRatio = aspectRatio
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            filter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 8.0, tvOS 8.0, *)
    open func perspectiveCorrection(topLeft: CGPoint = CGPoint(x: 118, y: 484),
                                    topRight: CGPoint = CGPoint(x: 646, y: 507),
                                    bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                                    bottomLeft: CGPoint = CGPoint(x: 155, y: 153),
                                    crop: Bool = true) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.perspectiveCorrection()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.topLeft = topLeft
            filter.topRight = topRight
            filter.bottomRight = bottomRight
            filter.bottomLeft = bottomLeft
            filter.crop = crop
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
            filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
            filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
            filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
            filter.setValue(crop, forKey: "inputCrop")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func perspectiveRotate(focalLength: Float = 28,
                                pitch: Float = 0,
                                yaw: Float = 0,
                                roll: Float = 0) -> CIImage {
        
        let filter = CIFilter.perspectiveRotate()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.focalLength = focalLength
        filter.pitch = pitch
        filter.yaw = yaw
        filter.roll = roll
        
        return filter.outputImage
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func perspectiveTransform(topLeft: CGPoint = CGPoint(x: 118, y: 484),
                                   topRight: CGPoint = CGPoint(x: 646, y: 507),
                                   bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                                   bottomLeft: CGPoint = CGPoint(x: 155, y: 153)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.perspectiveTransform()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.topLeft = topLeft
            filter.topRight = topRight
            filter.bottomRight = bottomRight
            filter.bottomLeft = bottomLeft
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPerspectiveTransform") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
            filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
            filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
            filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func perspectiveTransformWithExtent(extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                                             topLeft: CGPoint = CGPoint(x: 118, y: 484),
                                             topRight: CGPoint = CGPoint(x: 646, y: 507),
                                             bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                                             bottomLeft: CGPoint = CGPoint(x: 155, y: 153)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.perspectiveTransformWithExtent()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.extent = extent
            filter.topLeft = topLeft
            filter.topRight = topRight
            filter.bottomRight = bottomRight
            filter.bottomLeft = bottomLeft
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPerspectiveTransformWithExtent") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
            filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
            filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
            filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.7, iOS 5.0, tvOS 5.0, *)
    open func straighten(angle: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.straighten()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.angle = angle
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIStraightenFilter") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 8.0, tvOS 8.0, *)
    open func accordionFoldTransition(targetImage: CIImage,
                                      bottomHeight: Float = 0,
                                      numberOfFolds: Float = 3,
                                      foldShadowAmount: Float = 0.1,
                                      time: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.accordionFoldTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.bottomHeight = bottomHeight
            filter.numberOfFolds = numberOfFolds
            filter.foldShadowAmount = foldShadowAmount
            filter.time = time
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIAccordionFoldTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(bottomHeight, forKey: "inputBottomHeight")
            filter.setValue(numberOfFolds, forKey: "inputNumberOfFolds")
            filter.setValue(foldShadowAmount, forKey: "inputFoldShadowAmount")
            filter.setValue(time, forKey: kCIInputTimeKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func barsSwipeTransition(targetImage: CIImage,
                                  angle: Float = 3.141592653589793,
                                  width: Float = 30,
                                  barOffset: Float = 10,
                                  time: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.barsSwipeTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.angle = angle
            filter.width = width
            filter.barOffset = barOffset
            filter.time = time
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBarsSwipeTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(barOffset, forKey: "inputBarOffset")
            filter.setValue(time, forKey: kCIInputTimeKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func copyMachineTransition(targetImage: CIImage,
                                    extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                                    color: CIColor = CIColor(red: 0.6, green: 1, blue: 0.8, alpha: 1),
                                    time: Float = 0,
                                    angle: Float = 0,
                                    width: Float = 200,
                                    opacity: Float = 1.3) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.copyMachineTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.extent = extent
            filter.color = color
            filter.time = time
            filter.angle = angle
            filter.width = width
            filter.opacity = opacity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CICopyMachineTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(opacity, forKey: "inputOpacity")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func disintegrateWithMaskTransition(targetImage: CIImage,
                                             maskImage: CIImage,
                                             time: Float = 0,
                                             shadowRadius: Float = 8,
                                             shadowDensity: Float = 0.65,
                                             shadowOffset: CGPoint = CGPoint(x: 0, y: -10)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.disintegrateWithMaskTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.maskImage = maskImage
            filter.time = time
            filter.shadowRadius = shadowRadius
            filter.shadowDensity = shadowDensity
            filter.shadowOffset = shadowOffset
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIDisintegrateWithMaskTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(shadowRadius, forKey: "inputShadowRadius")
            filter.setValue(shadowDensity, forKey: "inputShadowDensity")
            filter.setValue(shadowOffset, forKey: "inputShadowOffset")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func dissolveTransition(targetImage: CIImage,
                                 time: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.dissolveTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.time = time
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIDissolveTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func flashTransition(targetImage: CIImage,
                              center: CGPoint = CGPoint(x: 150, y: 150),
                              extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                              color: CIColor = CIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1),
                              time: Float = 0,
                              maxStriationRadius: Float = 2.58,
                              striationStrength: Float = 0.5,
                              striationContrast: Float = 1.375,
                              fadeThreshold: Float = 0.85) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.flashTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.center = center
            filter.extent = extent
            filter.color = color
            filter.time = time
            filter.maxStriationRadius = maxStriationRadius
            filter.striationStrength = striationStrength
            filter.striationContrast = striationContrast
            filter.fadeThreshold = fadeThreshold
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIFlashTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(maxStriationRadius, forKey: "inputMaxStriationRadius")
            filter.setValue(striationStrength, forKey: "inputStriationStrength")
            filter.setValue(striationContrast, forKey: "inputStriationContrast")
            filter.setValue(fadeThreshold, forKey: "inputFadeThreshold")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func modTransition(targetImage: CIImage,
                            center: CGPoint = CGPoint(x: 150, y: 150),
                            time: Float = 0,
                            angle: Float = 2,
                            radius: Float = 150,
                            compression: Float = 300) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.modTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.center = center
            filter.time = time
            filter.angle = angle
            filter.radius = radius
            filter.compression = compression
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIModTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(compression, forKey: "inputCompression")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func pageCurlTransition(targetImage: CIImage,
                                 backsideImage: CIImage,
                                 shadingImage: CIImage,
                                 extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                                 time: Float = 0,
                                 angle: Float = 0,
                                 radius: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.pageCurlTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.backsideImage = backsideImage
            filter.shadingImage = shadingImage
            filter.extent = extent
            filter.time = time
            filter.angle = angle
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPageCurlTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(backsideImage, forKey: "inputBacksideImage")
            filter.setValue(shadingImage, forKey: kCIInputShadingImageKey)
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 9.0, tvOS 9.0, *)
    open func pageCurlWithShadowTransition(targetImage: CIImage,
                                           backsideImage: CIImage,
                                           extent: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0),
                                           time: Float = 0,
                                           angle: Float = 0,
                                           radius: Float = 100,
                                           shadowSize: Float = 0.5,
                                           shadowAmount: Float = 0.7,
                                           shadowExtent: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.pageCurlWithShadowTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.backsideImage = backsideImage
            filter.extent = extent
            filter.time = time
            filter.angle = angle
            filter.radius = radius
            filter.shadowSize = shadowSize
            filter.shadowAmount = shadowAmount
            filter.shadowExtent = shadowExtent
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPageCurlWithShadowTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(backsideImage, forKey: "inputBacksideImage")
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(shadowSize, forKey: "inputShadowSize")
            filter.setValue(shadowAmount, forKey: "inputShadowAmount")
            filter.setValue(CIVector(cgRect: shadowExtent), forKey: "inputShadowExtent")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func rippleTransition(targetImage: CIImage,
                               shadingImage: CIImage,
                               center: CGPoint = CGPoint(x: 150, y: 150),
                               extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                               time: Float = 0,
                               width: Float = 100,
                               scale: Float = 50) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.rippleTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.shadingImage = shadingImage
            filter.center = center
            filter.extent = extent
            filter.time = time
            filter.width = width
            filter.scale = scale
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIRippleTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(shadingImage, forKey: kCIInputShadingImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func swipeTransition(targetImage: CIImage,
                              extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                              color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                              time: Float = 0,
                              angle: Float = 0,
                              width: Float = 300,
                              opacity: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.swipeTransition()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.targetImage = targetImage
            filter.extent = extent
            filter.color = color
            filter.time = time
            filter.angle = angle
            filter.width = width
            filter.opacity = opacity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISwipeTransition") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(targetImage, forKey: kCIInputTargetImageKey)
            filter.setValue(CIVector(cgRect: extent), forKey: kCIInputExtentKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(time, forKey: kCIInputTimeKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(opacity, forKey: "inputOpacity")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func colorClamp(minComponents: CIVector = CIVector(x: 0, y: 0, z: 0, w: 0),
                         maxComponents: CIVector = CIVector(x: 1, y: 1, z: 1, w: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorClamp()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.minComponents = minComponents
            filter.maxComponents = maxComponents
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorClamp") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(minComponents, forKey: "inputMinComponents")
            filter.setValue(maxComponents, forKey: "inputMaxComponents")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func colorControls(saturation: Float = 1,
                            brightness: Float = 0,
                            contrast: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorControls()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.saturation = saturation
            filter.brightness = brightness
            filter.contrast = contrast
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorControls") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(saturation, forKey: kCIInputSaturationKey)
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func colorMatrix(rVector: CIVector = CIVector(x: 1, y: 0, z: 0, w: 0),
                          gVector: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                          bVector: CIVector = CIVector(x: 0, y: 0, z: 1, w: 0),
                          aVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: 1),
                          biasVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: 0)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorMatrix()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.rVector = rVector
            filter.gVector = gVector
            filter.bVector = bVector
            filter.aVector = aVector
            filter.biasVector = biasVector
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorMatrix") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(rVector, forKey: "inputRVector")
            filter.setValue(gVector, forKey: "inputGVector")
            filter.setValue(bVector, forKey: "inputBVector")
            filter.setValue(aVector, forKey: "inputAVector")
            filter.setValue(biasVector, forKey: "inputBiasVector")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func colorPolynomial(redCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                              greenCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                              blueCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                              alphaCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorPolynomial()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.redCoefficients = redCoefficients
            filter.greenCoefficients = greenCoefficients
            filter.blueCoefficients = blueCoefficients
            filter.alphaCoefficients = alphaCoefficients
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorPolynomial") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(redCoefficients, forKey: "inputRedCoefficients")
            filter.setValue(greenCoefficients, forKey: "inputGreenCoefficients")
            filter.setValue(blueCoefficients, forKey: "inputBlueCoefficients")
            filter.setValue(alphaCoefficients, forKey: "inputAlphaCoefficients")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func depthToDisparity() -> CIImage {
        return self.applyingFilter("CIDepthToDisparity", parameters: [:])
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func disparityToDepth() -> CIImage {
        return self.applyingFilter("CIDisparityToDepth", parameters: [:])
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func exposureAdjust(ev: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.exposureAdjust()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.ev = ev
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIExposureAdjust") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(ev, forKey: kCIInputEVKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func gammaAdjust(power: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.gammaAdjust()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.power = power
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIGammaAdjust") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(power, forKey: "inputPower")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func hueAdjust(angle: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.hueAdjust()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.angle = angle
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIHueAdjust") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 7.0, tvOS 7.0, *)
    open func linearToSRGBToneCurve() -> CIImage {
        return self.applyingFilter("CILinearToSRGBToneCurve", parameters: [:])
    }
    
    @available(macOS 10.10, iOS 7.0, tvOS 7.0, *)
    open func sRGBToneCurveToLinear() -> CIImage {
        return self.applyingFilter("CISRGBToneCurveToLinear", parameters: [:])
    }
    
    @available(macOS 10.7, iOS 5.0, tvOS 5.0, *)
    open func temperatureAndTint(neutral: CIVector = CIVector(x: 6500, y: 0),
                                 targetNeutral: CIVector = CIVector(x: 6500, y: 0)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.temperatureAndTint()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.neutral = neutral
            filter.targetNeutral = targetNeutral
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CITemperatureAndTint") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(neutral, forKey: "inputNeutral")
            filter.setValue(targetNeutral, forKey: "inputTargetNeutral")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.7, iOS 5.0, tvOS 5.0, *)
    open func toneCurve(point0: CGPoint = CGPoint(x: 0, y: 0),
                        point1: CGPoint = CGPoint(x: 0.25, y: 0.25),
                        point2: CGPoint = CGPoint(x: 0.5, y: 0.5),
                        point3: CGPoint = CGPoint(x: 0.75, y: 0.75),
                        point4: CGPoint = CGPoint(x: 1, y: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.toneCurve()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.point0 = point0
            filter.point1 = point1
            filter.point2 = point2
            filter.point3 = point3
            filter.point4 = point4
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIToneCurve") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
            filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
            filter.setValue(CIVector(cgPoint: point2), forKey: "inputPoint2")
            filter.setValue(CIVector(cgPoint: point3), forKey: "inputPoint3")
            filter.setValue(CIVector(cgPoint: point4), forKey: "inputPoint4")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.7, iOS 5.0, tvOS 5.0, *)
    open func vibrance(amount: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.vibrance()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.amount = amount
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIVibrance") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(amount, forKey: "inputAmount")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func whitePointAdjust(color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.whitePointAdjust()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.color = color
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIWhitePointAdjust") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func colorCrossPolynomial(redCoefficients: CIVector = CIVector([1, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
                                   greenCoefficients: CIVector = CIVector([0, 1, 0, 0, 0, 0, 0, 0, 0, 0]),
                                   blueCoefficients: CIVector = CIVector([0, 0, 1, 0, 0, 0, 0, 0, 0, 0])) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorCrossPolynomial()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.redCoefficients = redCoefficients
            filter.greenCoefficients = greenCoefficients
            filter.blueCoefficients = blueCoefficients
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorCrossPolynomial") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(redCoefficients, forKey: "inputRedCoefficients")
            filter.setValue(greenCoefficients, forKey: "inputGreenCoefficients")
            filter.setValue(blueCoefficients, forKey: "inputBlueCoefficients")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func colorInvert() -> CIImage {
        return self.applyingFilter("CIColorInvert", parameters: [:])
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func colorMap(gradientImage: CIImage) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorMap()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.gradientImage = gradientImage
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorMap") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(gradientImage, forKey: kCIInputGradientImageKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func colorMonochrome(color: CIColor = CIColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 1),
                              intensity: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorMonochrome()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.color = color
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorMonochrome") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func colorPosterize(levels: Float = 6) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.colorPosterize()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.levels = levels
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIColorPosterize") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(levels, forKey: "inputLevels")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
    open func dither(intensity: Float = 0.1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.dither()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIDither") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func documentEnhancer(amount: Float = 1) -> CIImage {
        
        let filter = CIFilter.documentEnhancer()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.amount = amount
        
        return filter.outputImage
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func falseColor(color0: CIColor = CIColor(red: 0.3, green: 0, blue: 0, alpha: 1),
                         color1: CIColor = CIColor(red: 1, green: 0.9, blue: 0.8, alpha: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.falseColor()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.color0 = color0
            filter.color1 = color1
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIFalseColor") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func labDeltaE(image2: CIImage) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.labDeltaE()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.image2 = image2
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CILabDeltaE") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(image2, forKey: "inputImage2")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func maskToAlpha() -> CIImage {
        return self.applyingFilter("CIMaskToAlpha", parameters: [:])
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func maximumComponent() -> CIImage {
        return self.applyingFilter("CIMaximumComponent", parameters: [:])
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func minimumComponent() -> CIImage {
        return self.applyingFilter("CIMinimumComponent", parameters: [:])
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func paletteCentroid(paletteImage: CIImage,
                              perceptual: Bool = false) -> CIImage {
        
        let filter = CIFilter.paletteCentroid()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.paletteImage = paletteImage
        filter.perceptual = perceptual
        
        return filter.outputImage
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func palettize(paletteImage: CIImage,
                        perceptual: Bool = false) -> CIImage {
        
        let filter = CIFilter.palettize()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.paletteImage = paletteImage
        filter.perceptual = perceptual
        
        return filter.outputImage
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectChrome() -> CIImage {
        return self.applyingFilter("CIPhotoEffectChrome", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectFade() -> CIImage {
        return self.applyingFilter("CIPhotoEffectFade", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectInstant() -> CIImage {
        return self.applyingFilter("CIPhotoEffectInstant", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectMono() -> CIImage {
        return self.applyingFilter("CIPhotoEffectMono", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectNoir() -> CIImage {
        return self.applyingFilter("CIPhotoEffectNoir", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectProcess() -> CIImage {
        return self.applyingFilter("CIPhotoEffectProcess", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectTonal() -> CIImage {
        return self.applyingFilter("CIPhotoEffectTonal", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func photoEffectTransfer() -> CIImage {
        return self.applyingFilter("CIPhotoEffectTransfer", parameters: [:])
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open func sepiaTone(intensity: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.sepiaTone()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.11, iOS 10.0, tvOS 10.0, *)
    open func thermal() -> CIImage {
        return self.applyingFilter("CIThermal", parameters: [:])
    }
    
    @available(macOS 10.9, iOS 5.0, tvOS 5.0, *)
    open func vignette(intensity: Float = 0,
                       radius: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.vignette()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.intensity = intensity
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIVignette") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func vignetteEffect(center: CGPoint = CGPoint(x: 150, y: 150),
                             radius: Float = 150,
                             intensity: Float = 1,
                             falloff: Float = 0.5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.vignetteEffect()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.radius = radius
            filter.intensity = intensity
            filter.falloff = falloff
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIVignetteEffect") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            filter.setValue(falloff, forKey: "inputFalloff")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.11, iOS 10.0, tvOS 10.0, *)
    open func xRay() -> CIImage {
        return self.applyingFilter("CIXRay", parameters: [:])
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func affineClamp(transform: CGAffineTransform = .identity) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.affineClamp()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.transform = transform
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIAffineClamp") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            
            #if os(macOS)
            
            let _transform = AffineTransform(m11: transform.a, m12: transform.b, m21: transform.c, m22: transform.d, tX: transform.tx, tY: transform.ty)
            filter.setValue(_transform as NSAffineTransform, forKey: kCIInputTransformKey)
            
            #else
            
            filter.setValue(NSValue(cgAffineTransform: transform), forKey: kCIInputTransformKey)
            
            #endif
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func affineTile(transform: CGAffineTransform = .identity) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.affineTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.transform = transform
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIAffineTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            
            #if os(macOS)
            
            let _transform = AffineTransform(m11: transform.a, m12: transform.b, m21: transform.c, m22: transform.d, tX: transform.tx, tY: transform.ty)
            filter.setValue(_transform as NSAffineTransform, forKey: kCIInputTransformKey)
            
            #else
            
            filter.setValue(NSValue(cgAffineTransform: transform), forKey: kCIInputTransformKey)
            
            #endif
            
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func eightfoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                     angle: Float = 0,
                                     width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.eightfoldReflectedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIEightfoldReflectedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func fourfoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                    angle: Float = 0,
                                    width: Float = 100,
                                    acuteAngle: Float = 1.570796326794897) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.fourfoldReflectedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            filter.acuteAngle = acuteAngle
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIFourfoldReflectedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(acuteAngle, forKey: "inputAcuteAngle")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func fourfoldRotatedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                  angle: Float = 0,
                                  width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.fourfoldRotatedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIFourfoldRotatedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func fourfoldTranslatedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                     angle: Float = 0,
                                     width: Float = 100,
                                     acuteAngle: Float = 1.570796326794897) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.fourfoldTranslatedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            filter.acuteAngle = acuteAngle
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIFourfoldTranslatedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(acuteAngle, forKey: "inputAcuteAngle")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func glideReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                 angle: Float = 0,
                                 width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.glideReflectedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIGlideReflectedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func kaleidoscope(count: Int = 6,
                           center: CGPoint = CGPoint(x: 150, y: 150),
                           angle: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.kaleidoscope()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.count = count
            filter.center = center
            filter.angle = angle
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIKaleidoscope") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(count, forKey: "inputCount")
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func opTile(center: CGPoint = CGPoint(x: 150, y: 150),
                     scale: Float = 2.8,
                     angle: Float = 0,
                     width: Float = 65) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.opTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.scale = scale
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIOpTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func parallelogramTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                angle: Float = 0,
                                acuteAngle: Float = 1.570796326794897,
                                width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.parallelogramTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.acuteAngle = acuteAngle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIParallelogramTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(acuteAngle, forKey: "inputAcuteAngle")
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func perspectiveTile(topLeft: CGPoint = CGPoint(x: 118, y: 484),
                              topRight: CGPoint = CGPoint(x: 646, y: 507),
                              bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                              bottomLeft: CGPoint = CGPoint(x: 155, y: 153)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.perspectiveTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.topLeft = topLeft
            filter.topRight = topRight
            filter.bottomRight = bottomRight
            filter.bottomLeft = bottomLeft
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPerspectiveTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
            filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
            filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
            filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func sixfoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                   angle: Float = 0,
                                   width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.sixfoldReflectedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISixfoldReflectedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func sixfoldRotatedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                 angle: Float = 0,
                                 width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.sixfoldRotatedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISixfoldRotatedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 6.0, tvOS 6.0, *)
    open func triangleKaleidoscope(point: CGPoint = CGPoint(x: 150, y: 150),
                                   size: Float = 700,
                                   rotation: Float = 5.924285296593801,
                                   decay: Float = 0.85) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.triangleKaleidoscope()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.point = point
            filter.size = size
            filter.rotation = rotation
            filter.decay = decay
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CITriangleKaleidoscope") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: point), forKey: "inputPoint")
            filter.setValue(size, forKey: "inputSize")
            filter.setValue(rotation, forKey: "inputRotation")
            filter.setValue(decay, forKey: "inputDecay")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func triangleTile(center: CGPoint = CGPoint(x: 150, y: 150),
                           angle: Float = 0,
                           width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.triangleTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CITriangleTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 6.0, tvOS 6.0, *)
    open func twelvefoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                      angle: Float = 0,
                                      width: Float = 100) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.twelvefoldReflectedTile()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.angle = angle
            filter.width = width
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CITwelvefoldReflectedTile") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            filter.setValue(width, forKey: kCIInputWidthKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open func blendWithAlphaMask(backgroundImage: CIImage,
                                 maskImage: CIImage) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.blendWithAlphaMask()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.backgroundImage = backgroundImage
            filter.maskImage = maskImage
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBlendWithAlphaMask") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func blendWithBlueMask(backgroundImage: CIImage,
                                maskImage: CIImage) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.blendWithBlueMask()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.backgroundImage = backgroundImage
            filter.maskImage = maskImage
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBlendWithBlueMask") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func blendWithMask(backgroundImage: CIImage,
                            maskImage: CIImage) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.blendWithMask()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.backgroundImage = backgroundImage
            filter.maskImage = maskImage
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBlendWithMask") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func blendWithRedMask(backgroundImage: CIImage,
                               maskImage: CIImage) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.blendWithRedMask()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.backgroundImage = backgroundImage
            filter.maskImage = maskImage
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBlendWithRedMask") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func bloom(radius: Float = 10,
                    intensity: Float = 0.5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.bloom()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBloom") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 9.0, tvOS 9.0, *)
    open func comicEffect() -> CIImage {
        return self.applyingFilter("CIComicEffect", parameters: [:])
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func crystallize(radius: Float = 20,
                          center: CGPoint = CGPoint(x: 150, y: 150)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.crystallize()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.center = center
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CICrystallize") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.6, iOS 9.0, tvOS 9.0, *)
    open func depthOfField(point0: CGPoint = CGPoint(x: 0, y: 300),
                           point1: CGPoint = CGPoint(x: 300, y: 300),
                           saturation: Float = 1.5,
                           unsharpMaskRadius: Float = 2.5,
                           unsharpMaskIntensity: Float = 0.5,
                           radius: Float = 6) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.depthOfField()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.point0 = point0
            filter.point1 = point1
            filter.saturation = saturation
            filter.unsharpMaskRadius = unsharpMaskRadius
            filter.unsharpMaskIntensity = unsharpMaskIntensity
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIDepthOfField") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
            filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
            filter.setValue(saturation, forKey: kCIInputSaturationKey)
            filter.setValue(unsharpMaskRadius, forKey: "inputUnsharpMaskRadius")
            filter.setValue(unsharpMaskIntensity, forKey: "inputUnsharpMaskIntensity")
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func edges(intensity: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.edges()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIEdges") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func edgeWork(radius: Float = 3) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.edgeWork()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIEdgeWork") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func gaborGradients() -> CIImage {
        
        let filter = CIFilter.gaborGradients()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        
        return filter.outputImage
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func gloom(radius: Float = 10,
                    intensity: Float = 0.5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.gloom()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.intensity = intensity
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIGloom") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func heightFieldFromMask(radius: Float = 10) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.heightFieldFromMask()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIHeightFieldFromMask") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 9.0, tvOS 9.0, *)
    open func hexagonalPixellate(center: CGPoint = CGPoint(x: 150, y: 150),
                                 scale: Float = 8) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.hexagonalPixellate()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.scale = scale
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIHexagonalPixellate") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.7, iOS 5.0, tvOS 5.0, *)
    open func highlightShadowAdjust(radius: Float = 0,
                                    shadowAmount: Float = 0,
                                    highlightAmount: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.highlightShadowAdjust()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.shadowAmount = shadowAmount
            filter.highlightAmount = highlightAmount
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(shadowAmount, forKey: "inputShadowAmount")
            filter.setValue(highlightAmount, forKey: "inputHighlightAmount")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 9.0, tvOS 9.0, *)
    open func lineOverlay(nrNoiseLevel: Float = 0.07000000000000001,
                          nrSharpness: Float = 0.71,
                          edgeIntensity: Float = 1,
                          threshold: Float = 0.1,
                          contrast: Float = 50) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.lineOverlay()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.nrNoiseLevel = nrNoiseLevel
            filter.nrSharpness = nrSharpness
            filter.edgeIntensity = edgeIntensity
            filter.threshold = threshold
            filter.contrast = contrast
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CILineOverlay") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(nrNoiseLevel, forKey: "inputNRNoiseLevel")
            filter.setValue(nrSharpness, forKey: "inputNRSharpness")
            filter.setValue(edgeIntensity, forKey: "inputEdgeIntensity")
            filter.setValue(threshold, forKey: "inputThreshold")
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
    open func mix(backgroundImage: CIImage,
                  amount: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.mix()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.backgroundImage = backgroundImage
            filter.amount = amount
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIMix") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(amount, forKey: "inputAmount")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func pixellate(center: CGPoint = CGPoint(x: 150, y: 150),
                        scale: Float = 8) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.pixellate()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.scale = scale
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPixellate") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func pointillize(radius: Float = 20,
                          center: CGPoint = CGPoint(x: 150, y: 150)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.pointillize()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.center = center
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPointillize") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
    open func saliencyMap() -> CIImage {
        return self.applyingFilter("CISaliencyMapFilter", parameters: [:])
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func shadedMaterial(shadingImage: CIImage,
                             scale: Float = 10) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.shadedMaterial()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.shadingImage = shadingImage
            filter.scale = scale
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIShadedMaterial") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(shadingImage, forKey: kCIInputShadingImageKey)
            filter.setValue(scale, forKey: kCIInputScaleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 9.0, tvOS 9.0, *)
    open func spotColor(centerColor1: CIColor = CIColor(red: 0.0784, green: 0.0627, blue: 0.0706, alpha: 1),
                        replacementColor1: CIColor = CIColor(red: 0.4392, green: 0.1922, blue: 0.1961, alpha: 1),
                        closeness1: Float = 0.22,
                        contrast1: Float = 0.98,
                        centerColor2: CIColor = CIColor(red: 0.5255, green: 0.3059, blue: 0.3451, alpha: 1),
                        replacementColor2: CIColor = CIColor(red: 0.9137, green: 0.5608, blue: 0.5059, alpha: 1),
                        closeness2: Float = 0.15,
                        contrast2: Float = 0.98,
                        centerColor3: CIColor = CIColor(red: 0.9216, green: 0.4549, blue: 0.3333, alpha: 1),
                        replacementColor3: CIColor = CIColor(red: 0.9098, green: 0.7529, blue: 0.6078, alpha: 1),
                        closeness3: Float = 0.5,
                        contrast3: Float = 0.99) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.spotColor()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.centerColor1 = centerColor1
            filter.replacementColor1 = replacementColor1
            filter.closeness1 = closeness1
            filter.contrast1 = contrast1
            filter.centerColor2 = centerColor2
            filter.replacementColor2 = replacementColor2
            filter.closeness2 = closeness2
            filter.contrast2 = contrast2
            filter.centerColor3 = centerColor3
            filter.replacementColor3 = replacementColor3
            filter.closeness3 = closeness3
            filter.contrast3 = contrast3
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISpotColor") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(centerColor1, forKey: "inputCenterColor1")
            filter.setValue(replacementColor1, forKey: "inputReplacementColor1")
            filter.setValue(closeness1, forKey: "inputCloseness1")
            filter.setValue(contrast1, forKey: "inputContrast1")
            filter.setValue(centerColor2, forKey: "inputCenterColor2")
            filter.setValue(replacementColor2, forKey: "inputReplacementColor2")
            filter.setValue(closeness2, forKey: "inputCloseness2")
            filter.setValue(contrast2, forKey: "inputContrast2")
            filter.setValue(centerColor3, forKey: "inputCenterColor3")
            filter.setValue(replacementColor3, forKey: "inputReplacementColor3")
            filter.setValue(closeness3, forKey: "inputCloseness3")
            filter.setValue(contrast3, forKey: "inputContrast3")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func spotLight(lightPosition: CIVector = CIVector(x: 400, y: 600, z: 150),
                        lightPointsAt: CIVector = CIVector(x: 200, y: 200, z: 0),
                        brightness: Float = 3,
                        concentration: Float = 0.1,
                        color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.spotLight()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.lightPosition = lightPosition
            filter.lightPointsAt = lightPointsAt
            filter.brightness = brightness
            filter.concentration = concentration
            filter.color = color
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISpotLight") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(lightPosition, forKey: "inputLightPosition")
            filter.setValue(lightPointsAt, forKey: "inputLightPointsAt")
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(concentration, forKey: "inputConcentration")
            filter.setValue(color, forKey: kCIInputColorKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func bokehBlur(radius: Float = 20,
                        ringAmount: Float = 0,
                        ringSize: Float = 0.1,
                        softness: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.bokehBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.ringAmount = ringAmount
            filter.ringSize = ringSize
            filter.softness = softness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBokehBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(ringAmount, forKey: "inputRingAmount")
            filter.setValue(ringSize, forKey: "inputRingSize")
            filter.setValue(softness, forKey: "inputSoftness")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 9.0, tvOS 9.0, *)
    open func boxBlur(radius: Float = 10) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.boxBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIBoxBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.5, iOS 9.0, tvOS 9.0, *)
    open func discBlur(radius: Float = 8) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.discBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIDiscBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open func gaussianBlur(radius: Float = 10) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.gaussianBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 8.0, tvOS 8.0, *)
    open func maskedVariableBlur(mask: CIImage,
                                 radius: Float = 5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.maskedVariableBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.mask = mask
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIMaskedVariableBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(mask, forKey: "inputMask")
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func median() -> CIImage {
        return self.applyingFilter("CIMedianFilter", parameters: [:])
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func morphologyGradient(radius: Float = 5) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.morphologyGradient()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIMorphologyGradient") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func morphologyMaximum(radius: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.morphologyMaximum()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIMorphologyMaximum") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open func morphologyMinimum(radius: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.morphologyMinimum()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIMorphologyMinimum") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func morphologyRectangleMaximum(width: Float = 5,
                                         height: Float = 5) -> CIImage {
        
        let filter = CIFilter.morphologyRectangleMaximum()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.width = width
        filter.height = height
        
        return filter.outputImage
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open func morphologyRectangleMinimum(width: Float = 5,
                                         height: Float = 5) -> CIImage {
        
        let filter = CIFilter.morphologyRectangleMinimum()
        
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.width = width
        filter.height = height
        
        return filter.outputImage
    }
    
    @available(macOS 10.4, iOS 8.3, tvOS 8.3, *)
    open func motionBlur(radius: Float = 20,
                         angle: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.motionBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.radius = radius
            filter.angle = angle
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIMotionBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(angle, forKey: kCIInputAngleKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open func noiseReduction(noiseLevel: Float = 0.02,
                             sharpness: Float = 0.4) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.noiseReduction()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.noiseLevel = noiseLevel
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CINoiseReduction") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(noiseLevel, forKey: "inputNoiseLevel")
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 8.3, tvOS 8.3, *)
    open func zoomBlur(center: CGPoint = CGPoint(x: 150, y: 150),
                       amount: Float = 20) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.zoomBlur()
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.center = center
            filter.amount = amount
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIZoomBlur") else { return nil }
            
            filter.setValue(self, forKey: kCIInputImageKey)
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(amount, forKey: "inputAmount")
            
            return filter.outputImage
        }
    }
    
}

extension CIImage {
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open class func GaussianGradient(center: CGPoint = CGPoint(x: 150, y: 150),
                                     color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                     color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                     radius: Float = 300) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.gaussianGradient()
            
            filter.center = center
            filter.color0 = color0
            filter.color1 = color1
            filter.radius = radius
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIGaussianGradient") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.12, iOS 10.0, tvOS 10.0, *)
    open class func HueSaturationValueGradient(value: Float = 1,
                                               radius: Float = 300,
                                               softness: Float = 1,
                                               dither: Float = 1,
                                               colorSpace: CGColorSpace? = CGColorSpace(name: CGColorSpace.sRGB)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.hueSaturationValueGradient()
            
            filter.value = value
            filter.radius = radius
            filter.softness = softness
            filter.dither = dither
            filter.colorSpace = colorSpace
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIHueSaturationValueGradient") else { return nil }
            
            filter.setValue(value, forKey: "inputValue")
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(softness, forKey: "inputSoftness")
            filter.setValue(dither, forKey: "inputDither")
            filter.setValue(colorSpace, forKey: "inputColorSpace")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open class func LinearGradient(point0: CGPoint = CGPoint(x: 0, y: 0),
                                   point1: CGPoint = CGPoint(x: 200, y: 200),
                                   color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                   color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.linearGradient()
            
            filter.point0 = point0
            filter.point1 = point1
            filter.color0 = color0
            filter.color1 = color1
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CILinearGradient") else { return nil }
            
            filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
            filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open class func RadialGradient(center: CGPoint = CGPoint(x: 150, y: 150),
                                   radius0: Float = 5,
                                   radius1: Float = 100,
                                   color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                   color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.radialGradient()
            
            filter.center = center
            filter.radius0 = radius0
            filter.radius1 = radius1
            filter.color0 = color0
            filter.color1 = color1
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIRadialGradient") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(radius0, forKey: "inputRadius0")
            filter.setValue(radius1, forKey: "inputRadius1")
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 6.0, tvOS 6.0, *)
    open class func SmoothLinearGradient(point0: CGPoint = CGPoint(x: 0, y: 0),
                                         point1: CGPoint = CGPoint(x: 200, y: 200),
                                         color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                         color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.smoothLinearGradient()
            
            filter.point0 = point0
            filter.point1 = point1
            filter.color0 = color0
            filter.color1 = color1
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return nil }
            
            filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
            filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    open class func RoundedRectangleGenerator(extent: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100),
                                              radius: Float = 10,
                                              color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CIImage {
        
        let filter = CIFilter.roundedRectangleGenerator()
        
        filter.extent = extent
        filter.radius = radius
        filter.color = color
        
        return filter.outputImage
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open class func StarShineGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                       color: CIColor = CIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1),
                                       radius: Float = 50,
                                       crossScale: Float = 15,
                                       crossAngle: Float = 0.6,
                                       crossOpacity: Float = -2,
                                       crossWidth: Float = 2.5,
                                       epsilon: Float = -2) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.starShineGenerator()
            
            filter.center = center
            filter.color = color
            filter.radius = radius
            filter.crossScale = crossScale
            filter.crossAngle = crossAngle
            filter.crossOpacity = crossOpacity
            filter.crossWidth = crossWidth
            filter.epsilon = epsilon
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIStarShineGenerator") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            filter.setValue(crossScale, forKey: "inputCrossScale")
            filter.setValue(crossAngle, forKey: "inputCrossAngle")
            filter.setValue(crossOpacity, forKey: "inputCrossOpacity")
            filter.setValue(crossWidth, forKey: "inputCrossWidth")
            filter.setValue(epsilon, forKey: "inputEpsilon")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open class func StripesGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                     color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                     color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1),
                                     width: Float = 80,
                                     sharpness: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.stripesGenerator()
            
            filter.center = center
            filter.color0 = color0
            filter.color1 = color1
            filter.width = width
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIStripesGenerator") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open class func SunbeamsGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                      color: CIColor = CIColor(red: 1, green: 0.5, blue: 0, alpha: 1),
                                      sunRadius: Float = 40,
                                      maxStriationRadius: Float = 2.58,
                                      striationStrength: Float = 0.5,
                                      striationContrast: Float = 1.375,
                                      time: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.sunbeamsGenerator()
            
            filter.center = center
            filter.color = color
            filter.sunRadius = sunRadius
            filter.maxStriationRadius = maxStriationRadius
            filter.striationStrength = striationStrength
            filter.striationContrast = striationContrast
            filter.time = time
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CISunbeamsGenerator") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(sunRadius, forKey: "inputSunRadius")
            filter.setValue(maxStriationRadius, forKey: "inputMaxStriationRadius")
            filter.setValue(striationStrength, forKey: "inputStriationStrength")
            filter.setValue(striationContrast, forKey: "inputStriationContrast")
            filter.setValue(time, forKey: kCIInputTimeKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 8.0, tvOS 8.0, *)
    open class func AztecCodeGenerator(message: String,
                                       correction level: Float = 23,
                                       layers: Float? = nil,
                                       compact: Bool = false,
                                       encoding: String.Encoding = String.Encoding.isoLatin1) -> CIImage {
        
        guard let data = message.data(using: encoding) else { return nil }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.aztecCodeGenerator()
            
            filter.message = data
            filter.correctionLevel = level
            if let layers = layers {
                filter.layers = layers
            }
            filter.compactStyle = compact ? 1 : 0
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIAztecCodeGenerator") else { return nil }
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(level, forKey: "inputCorrectionLevel")
            filter.setValue(layers, forKey: "inputLayers")
            filter.setValue(compact, forKey: "inputCompactStyle")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    public enum QRCorrectionLevel: String, CaseIterable {
        
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
    }
    
    @available(macOS 10.9, iOS 7.0, tvOS 7.0, *)
    open class func QRCodeGenerator(message: String,
                                    correction level: QRCorrectionLevel = .medium,
                                    encoding: String.Encoding = String.Encoding.utf8) -> CIImage {
        
        guard let data = message.data(using: encoding) else { return nil }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.qrCodeGenerator()
            
            filter.message = data
            filter.correctionLevel = level.rawValue
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(level.rawValue, forKey: "inputCorrectionLevel")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.10, iOS 8.0, tvOS 8.0, *)
    open class func Code128BarcodeGenerator(message: String,
                                            quietSpace: Float = 7,
                                            barcodeHeight: Float = 32) -> CIImage {
        
        guard let data = message.data(using: String.Encoding.ascii) else { return nil }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.code128BarcodeGenerator()
            
            filter.message = data
            filter.quietSpace = quietSpace
            filter.barcodeHeight = barcodeHeight
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(quietSpace, forKey: "inputQuietSpace")
            filter.setValue(barcodeHeight, forKey: "inputBarcodeHeight")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 5.0, tvOS 5.0, *)
    open class func CheckerboardGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                          color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                          color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1),
                                          width: Float = 80,
                                          sharpness: Float = 1) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.checkerboardGenerator()
            
            filter.center = center
            filter.color0 = color0
            filter.color1 = color1
            filter.width = width
            filter.sharpness = sharpness
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CICheckerboardGenerator") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(color0, forKey: "inputColor0")
            filter.setValue(color1, forKey: "inputColor1")
            filter.setValue(width, forKey: kCIInputWidthKey)
            filter.setValue(sharpness, forKey: kCIInputSharpnessKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 9.0, tvOS 9.0, *)
    open class func LenticularHaloGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                            color: CIColor = CIColor(red: 1, green: 0.9, blue: 0.8, alpha: 1),
                                            haloRadius: Float = 70,
                                            haloWidth: Float = 87,
                                            haloOverlap: Float = 0.77,
                                            striationStrength: Float = 0.5,
                                            striationContrast: Float = 1,
                                            time: Float = 0) -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.lenticularHaloGenerator()
            
            filter.center = center
            filter.color = color
            filter.haloRadius = haloRadius
            filter.haloWidth = haloWidth
            filter.haloOverlap = haloOverlap
            filter.striationStrength = striationStrength
            filter.striationContrast = striationContrast
            filter.time = time
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CILenticularHaloGenerator") else { return nil }
            
            filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
            filter.setValue(color, forKey: kCIInputColorKey)
            filter.setValue(haloRadius, forKey: "inputHaloRadius")
            filter.setValue(haloWidth, forKey: "inputHaloWidth")
            filter.setValue(haloOverlap, forKey: "inputHaloOverlap")
            filter.setValue(striationStrength, forKey: "inputStriationStrength")
            filter.setValue(striationContrast, forKey: "inputStriationContrast")
            filter.setValue(time, forKey: kCIInputTimeKey)
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.11, iOS 9.0, tvOS 9.0, *)
    open class func PDF417BarcodeGenerator(message: String,
                                           minWidth: Float,
                                           maxWidth: Float,
                                           minHeight: Float,
                                           maxHeight: Float,
                                           dataColumns: Float,
                                           rows: Float,
                                           preferredAspectRatio: Float,
                                           compactionMode: Float,
                                           compactStyle: Float,
                                           correctionLevel: Float,
                                           alwaysSpecifyCompaction: Float,
                                           encoding: String.Encoding = String.Encoding.isoLatin1) -> CIImage {
        
        guard let data = message.data(using: String.Encoding.ascii) else { return nil }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.pdf417BarcodeGenerator()
            
            filter.message = data
            filter.minWidth = minWidth
            filter.maxWidth = maxWidth
            filter.minHeight = minHeight
            filter.maxHeight = maxHeight
            filter.dataColumns = dataColumns
            filter.rows = rows
            filter.preferredAspectRatio = preferredAspectRatio
            filter.compactionMode = compactionMode
            filter.compactStyle = compactStyle
            filter.correctionLevel = correctionLevel
            filter.alwaysSpecifyCompaction = alwaysSpecifyCompaction
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else { return nil }
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(minWidth, forKey: "inputMinWidth")
            filter.setValue(maxWidth, forKey: "inputMaxWidth")
            filter.setValue(minHeight, forKey: "inputMinHeight")
            filter.setValue(maxHeight, forKey: "inputMaxHeight")
            filter.setValue(dataColumns, forKey: "inputDataColumns")
            filter.setValue(rows, forKey: "inputRows")
            filter.setValue(preferredAspectRatio, forKey: "inputPreferredAspectRatio")
            filter.setValue(compactionMode, forKey: "inputCompactionMode")
            filter.setValue(compactStyle, forKey: "inputCompactStyle")
            filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
            filter.setValue(alwaysSpecifyCompaction, forKey: "inputAlwaysSpecifyCompaction")
            
            return filter.outputImage
        }
    }
    
    @available(macOS 10.4, iOS 6.0, tvOS 6.0, *)
    open class func RandomGenerator() -> CIImage {
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            
            let filter = CIFilter.randomGenerator()
            
            return filter.outputImage
            
        } else {
            
            guard let filter = CIFilter(name: "CIRandomGenerator") else { return nil }
            
            return filter.outputImage
        }
    }
    
}

#endif
