//
//  CoreImage.swift
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

#if canImport(CoreImage)

extension CIImage {
    
    public func sharpenLuminance(sharpness: Float = 0.4,
                               radius: Float = 1.69) -> CIImage {
        
        guard let filter = CIFilter(name: "CISharpenLuminance") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(sharpness, forKey: "inputSharpness")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func unsharpMask(radius: Float = 2.5,
                          intensity: Float = 0.5) -> CIImage {
        
        guard let filter = CIFilter(name: "CIUnsharpMask") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func circularScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                             width: Float = 6,
                             sharpness: Float = 0.7) -> CIImage {
        
        guard let filter = CIFilter(name: "CICircularScreen") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public func cmykHalftone(center: CGPoint = CGPoint(x: 150, y: 150),
                           width: Float = 6,
                           angle: Float = 0,
                           sharpness: Float = 0.7,
                           grayComponentReplacement: Float = 1,
                           underColorRemoval: Float = 0.5) -> CIImage {
        
        guard let filter = CIFilter(name: "CICMYKHalftone") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(sharpness, forKey: "inputSharpness")
        filter.setValue(grayComponentReplacement, forKey: "inputGCR")
        filter.setValue(underColorRemoval, forKey: "inputUCR")
        
        return filter.outputImage ?? .empty()
    }
    
    public func dotScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                        angle: Float = 0,
                        width: Float = 6,
                        sharpness: Float = 0.7) -> CIImage {
        
        guard let filter = CIFilter(name: "CIDotScreen") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public func hatchedScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                            angle: Float = 0,
                            width: Float = 6,
                            sharpness: Float = 0.7) -> CIImage {
        
        guard let filter = CIFilter(name: "CIHatchedScreen") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public func lineScreen(center: CGPoint = CGPoint(x: 150, y: 150),
                         angle: Float = 0,
                         width: Float = 6,
                         sharpness: Float = 0.7) -> CIImage {
        
        guard let filter = CIFilter(name: "CILineScreen") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public func bicubicScaleTransform(scale: Float = 1,
                                    aspectRatio: Float = 1,
                                    b: Float = 0,
                                    c: Float = 0.75) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBicubicScaleTransform") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(scale, forKey: "inputScale")
        filter.setValue(aspectRatio, forKey: "inputAspectRatio")
        filter.setValue(b, forKey: "inputB")
        filter.setValue(c, forKey: "inputC")
        
        return filter.outputImage ?? .empty()
    }
    
    public func edgePreserveUpsample(smallImage: CIImage,
                                   spatialSigma: Float = 3,
                                   lumaSigma: Float = 0.15) -> CIImage {
        
        guard let filter = CIFilter(name: "CIEdgePreserveUpsampleFilter") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(smallImage, forKey: "inputSmallImage")
        filter.setValue(spatialSigma, forKey: "inputSpatialSigma")
        filter.setValue(lumaSigma, forKey: "inputLumaSigma")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func keystoneCorrectionCombined(focalLength: Float = 28) -> CIImage {
        
        let filter = CIFilter.keystoneCorrectionCombined()
        
        filter.setValue(self, forKey: "inputImage")
        filter.focalLength = focalLength
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func keystoneCorrectionHorizontal(focalLength: Float = 28) -> CIImage {
        
        let filter = CIFilter.keystoneCorrectionHorizontal()
        
        filter.setValue(self, forKey: "inputImage")
        filter.focalLength = focalLength
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func keystoneCorrectionVertical(focalLength: Float = 28) -> CIImage {
        
        let filter = CIFilter.keystoneCorrectionVertical()
        
        filter.setValue(self, forKey: "inputImage")
        filter.focalLength = focalLength
        
        return filter.outputImage ?? .empty()
    }
    
    public func lanczosScaleTransform(scale: Float = 1,
                                    aspectRatio: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(scale, forKey: "inputScale")
        filter.setValue(aspectRatio, forKey: "inputAspectRatio")
        
        return filter.outputImage ?? .empty()
    }
    
    public func perspectiveCorrection(topLeft: CGPoint = CGPoint(x: 118, y: 484),
                                    topRight: CGPoint = CGPoint(x: 646, y: 507),
                                    bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                                    bottomLeft: CGPoint = CGPoint(x: 155, y: 153),
                                    crop: Bool = true) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        filter.setValue(crop, forKey: "inputCrop")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func perspectiveRotate(focalLength: Float = 28,
                                pitch: Float = 0,
                                yaw: Float = 0,
                                roll: Float = 0) -> CIImage {
        
        let filter = CIFilter.perspectiveRotate()
        
        filter.setValue(self, forKey: "inputImage")
        filter.focalLength = focalLength
        filter.pitch = pitch
        filter.yaw = yaw
        filter.roll = roll
        
        return filter.outputImage ?? .empty()
    }
    
    public func perspectiveTransform(topLeft: CGPoint = CGPoint(x: 118, y: 484),
                                   topRight: CGPoint = CGPoint(x: 646, y: 507),
                                   bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                                   bottomLeft: CGPoint = CGPoint(x: 155, y: 153)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPerspectiveTransform") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        
        return filter.outputImage ?? .empty()
    }
    
    public func perspectiveTransformWithExtent(extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                                             topLeft: CGPoint = CGPoint(x: 118, y: 484),
                                             topRight: CGPoint = CGPoint(x: 646, y: 507),
                                             bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                                             bottomLeft: CGPoint = CGPoint(x: 155, y: 153)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPerspectiveTransformWithExtent") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        
        return filter.outputImage ?? .empty()
    }
    
    public func straighten(angle: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIStraightenFilter") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(angle, forKey: "inputAngle")
        
        return filter.outputImage ?? .empty()
    }
    
    public func accordionFoldTransition(targetImage: CIImage,
                                      bottomHeight: Float = 0,
                                      numberOfFolds: Float = 3,
                                      foldShadowAmount: Float = 0.1,
                                      time: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIAccordionFoldTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(bottomHeight, forKey: "inputBottomHeight")
        filter.setValue(numberOfFolds, forKey: "inputNumberOfFolds")
        filter.setValue(foldShadowAmount, forKey: "inputFoldShadowAmount")
        filter.setValue(time, forKey: "inputTime")
        
        return filter.outputImage ?? .empty()
    }
    
    public func barsSwipeTransition(targetImage: CIImage,
                                  angle: Float = 3.141592653589793,
                                  width: Float = 30,
                                  barOffset: Float = 10,
                                  time: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBarsSwipeTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(barOffset, forKey: "inputBarOffset")
        filter.setValue(time, forKey: "inputTime")
        
        return filter.outputImage ?? .empty()
    }
    
    public func copyMachineTransition(targetImage: CIImage,
                                    extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                                    color: CIColor = CIColor(red: 0.6, green: 1, blue: 0.8, alpha: 1),
                                    time: Float = 0,
                                    angle: Float = 0,
                                    width: Float = 200,
                                    opacity: Float = 1.3) -> CIImage {
        
        guard let filter = CIFilter(name: "CICopyMachineTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(opacity, forKey: "inputOpacity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func disintegrateWithMaskTransition(targetImage: CIImage,
                                             maskImage: CIImage,
                                             time: Float = 0,
                                             shadowRadius: Float = 8,
                                             shadowDensity: Float = 0.65,
                                             shadowOffset: CGPoint = CGPoint(x: 0, y: -10)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIDisintegrateWithMaskTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(maskImage, forKey: "inputMaskImage")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(shadowRadius, forKey: "inputShadowRadius")
        filter.setValue(shadowDensity, forKey: "inputShadowDensity")
        filter.setValue(shadowOffset, forKey: "inputShadowOffset")
        
        return filter.outputImage ?? .empty()
    }
    
    public func dissolveTransition(targetImage: CIImage,
                                 time: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIDissolveTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(time, forKey: "inputTime")
        
        return filter.outputImage ?? .empty()
    }
    
    public func flashTransition(targetImage: CIImage,
                              center: CGPoint = CGPoint(x: 150, y: 150),
                              extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                              color: CIColor = CIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1),
                              time: Float = 0,
                              maxStriationRadius: Float = 2.58,
                              striationStrength: Float = 0.5,
                              striationContrast: Float = 1.375,
                              fadeThreshold: Float = 0.85) -> CIImage {
        
        guard let filter = CIFilter(name: "CIFlashTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(maxStriationRadius, forKey: "inputMaxStriationRadius")
        filter.setValue(striationStrength, forKey: "inputStriationStrength")
        filter.setValue(striationContrast, forKey: "inputStriationContrast")
        filter.setValue(fadeThreshold, forKey: "inputFadeThreshold")
        
        return filter.outputImage ?? .empty()
    }
    
    public func modTransition(targetImage: CIImage,
                            center: CGPoint = CGPoint(x: 150, y: 150),
                            time: Float = 0,
                            angle: Float = 2,
                            radius: Float = 150,
                            compression: Float = 300) -> CIImage {
        
        guard let filter = CIFilter(name: "CIModTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(compression, forKey: "inputCompression")
        
        return filter.outputImage ?? .empty()
    }
    
    public func pageCurlTransition(targetImage: CIImage,
                                 backsideImage: CIImage,
                                 shadingImage: CIImage,
                                 extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                                 time: Float = 0,
                                 angle: Float = 0,
                                 radius: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPageCurlTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(backsideImage, forKey: "inputBacksideImage")
        filter.setValue(shadingImage, forKey: "inputShadingImage")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func pageCurlWithShadowTransition(targetImage: CIImage,
                                           backsideImage: CIImage,
                                           extent: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0),
                                           time: Float = 0,
                                           angle: Float = 0,
                                           radius: Float = 100,
                                           shadowSize: Float = 0.5,
                                           shadowAmount: Float = 0.7,
                                           shadowExtent: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPageCurlWithShadowTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(backsideImage, forKey: "inputBacksideImage")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(shadowSize, forKey: "inputShadowSize")
        filter.setValue(shadowAmount, forKey: "inputShadowAmount")
        filter.setValue(CIVector(cgRect: shadowExtent), forKey: "inputShadowExtent")
        
        return filter.outputImage ?? .empty()
    }
    
    public func rippleTransition(targetImage: CIImage,
                               shadingImage: CIImage,
                               center: CGPoint = CGPoint(x: 150, y: 150),
                               extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                               time: Float = 0,
                               width: Float = 100,
                               scale: Float = 50) -> CIImage {
        
        guard let filter = CIFilter(name: "CIRippleTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(shadingImage, forKey: "inputShadingImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(scale, forKey: "inputScale")
        
        return filter.outputImage ?? .empty()
    }
    
    public func swipeTransition(targetImage: CIImage,
                              extent: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300),
                              color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                              time: Float = 0,
                              angle: Float = 0,
                              width: Float = 300,
                              opacity: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CISwipeTransition") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(targetImage, forKey: "inputTargetImage")
        filter.setValue(CIVector(cgRect: extent), forKey: "inputExtent")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(time, forKey: "inputTime")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(opacity, forKey: "inputOpacity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorClamp(minComponents: CIVector = CIVector(x: 0, y: 0, z: 0, w: 0),
                         maxComponents: CIVector = CIVector(x: 1, y: 1, z: 1, w: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorClamp") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(minComponents, forKey: "inputMinComponents")
        filter.setValue(maxComponents, forKey: "inputMaxComponents")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorControls(saturation: Float = 1,
                            brightness: Float = 0,
                            contrast: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorControls") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(saturation, forKey: "inputSaturation")
        filter.setValue(brightness, forKey: "inputBrightness")
        filter.setValue(contrast, forKey: "inputContrast")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorMatrix(rVector: CIVector = CIVector(x: 1, y: 0, z: 0, w: 0),
                          gVector: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                          bVector: CIVector = CIVector(x: 0, y: 0, z: 1, w: 0),
                          aVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: 1),
                          biasVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: 0)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorMatrix") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(rVector, forKey: "inputRVector")
        filter.setValue(gVector, forKey: "inputGVector")
        filter.setValue(bVector, forKey: "inputBVector")
        filter.setValue(aVector, forKey: "inputAVector")
        filter.setValue(biasVector, forKey: "inputBiasVector")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorPolynomial(redCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                              greenCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                              blueCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0),
                              alphaCoefficients: CIVector = CIVector(x: 0, y: 1, z: 0, w: 0)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorPolynomial") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(redCoefficients, forKey: "inputRedCoefficients")
        filter.setValue(greenCoefficients, forKey: "inputGreenCoefficients")
        filter.setValue(blueCoefficients, forKey: "inputBlueCoefficients")
        filter.setValue(alphaCoefficients, forKey: "inputAlphaCoefficients")
        
        return filter.outputImage ?? .empty()
    }
    
    public func depthToDisparity() -> CIImage {
        return self.applyingFilter("CIDepthToDisparity", parameters: [:])
    }
    
    public func disparityToDepth() -> CIImage {
        return self.applyingFilter("CIDisparityToDepth", parameters: [:])
    }
    
    public func exposureAdjust(ev: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIExposureAdjust") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(ev, forKey: "inputEV")
        
        return filter.outputImage ?? .empty()
    }
    
    public func gammaAdjust(power: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIGammaAdjust") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(power, forKey: "inputPower")
        
        return filter.outputImage ?? .empty()
    }
    
    public func hueAdjust(angle: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIHueAdjust") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(angle, forKey: "inputAngle")
        
        return filter.outputImage ?? .empty()
    }
    
    public func linearToSRGBToneCurve() -> CIImage {
        return self.applyingFilter("CILinearToSRGBToneCurve", parameters: [:])
    }
    
    public func sRGBToneCurveToLinear() -> CIImage {
        return self.applyingFilter("CISRGBToneCurveToLinear", parameters: [:])
    }
    
    public func temperatureAndTint(neutral: CIVector = CIVector(x: 6500, y: 0),
                                 targetNeutral: CIVector = CIVector(x: 6500, y: 0)) -> CIImage {
        
        guard let filter = CIFilter(name: "CITemperatureAndTint") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(neutral, forKey: "inputNeutral")
        filter.setValue(targetNeutral, forKey: "inputTargetNeutral")
        
        return filter.outputImage ?? .empty()
    }
    
    public func toneCurve(point0: CGPoint = CGPoint(x: 0, y: 0),
                        point1: CGPoint = CGPoint(x: 0.25, y: 0.25),
                        point2: CGPoint = CGPoint(x: 0.5, y: 0.5),
                        point3: CGPoint = CGPoint(x: 0.75, y: 0.75),
                        point4: CGPoint = CGPoint(x: 1, y: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIToneCurve") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
        filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
        filter.setValue(CIVector(cgPoint: point2), forKey: "inputPoint2")
        filter.setValue(CIVector(cgPoint: point3), forKey: "inputPoint3")
        filter.setValue(CIVector(cgPoint: point4), forKey: "inputPoint4")
        
        return filter.outputImage ?? .empty()
    }
    
    public func vibrance(amount: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIVibrance") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(amount, forKey: "inputAmount")
        
        return filter.outputImage ?? .empty()
    }
    
    public func whitePointAdjust(color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIWhitePointAdjust") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(color, forKey: "inputColor")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorCrossPolynomial(redCoefficients: CIVector = CIVector([1, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
                                   greenCoefficients: CIVector = CIVector([0, 1, 0, 0, 0, 0, 0, 0, 0, 0]),
                                   blueCoefficients: CIVector = CIVector([0, 0, 1, 0, 0, 0, 0, 0, 0, 0])) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorCrossPolynomial") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(redCoefficients, forKey: "inputRedCoefficients")
        filter.setValue(greenCoefficients, forKey: "inputGreenCoefficients")
        filter.setValue(blueCoefficients, forKey: "inputBlueCoefficients")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorInvert() -> CIImage {
        return self.applyingFilter("CIColorInvert", parameters: [:])
    }
    
    public func colorMap(gradientImage: CIImage) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorMap") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(gradientImage, forKey: "inputGradientImage")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorMonochrome(color: CIColor = CIColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 1),
                              intensity: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorMonochrome") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func colorPosterize(levels: Float = 6) -> CIImage {
        
        guard let filter = CIFilter(name: "CIColorPosterize") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(levels, forKey: "inputLevels")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
    public func dither(intensity: Float = 0.1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIDither") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func documentEnhancer(amount: Float = 1) -> CIImage {
        
        let filter = CIFilter.documentEnhancer()
        
        filter.setValue(self, forKey: "inputImage")
        filter.amount = amount
        
        return filter.outputImage ?? .empty()
    }
    
    public func falseColor(color0: CIColor = CIColor(red: 0.3, green: 0, blue: 0, alpha: 1),
                         color1: CIColor = CIColor(red: 1, green: 0.9, blue: 0.8, alpha: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIFalseColor") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        
        return filter.outputImage ?? .empty()
    }
    
    public func labDeltaE(image2: CIImage) -> CIImage {
        
        guard let filter = CIFilter(name: "CILabDeltaE") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(image2, forKey: "inputImage2")
        
        return filter.outputImage ?? .empty()
    }
    
    public func maskToAlpha() -> CIImage {
        return self.applyingFilter("CIMaskToAlpha", parameters: [:])
    }
    
    public func maximumComponent() -> CIImage {
        return self.applyingFilter("CIMaximumComponent", parameters: [:])
    }
    
    public func minimumComponent() -> CIImage {
        return self.applyingFilter("CIMinimumComponent", parameters: [:])
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func paletteCentroid(paletteImage: CIImage,
                              perceptual: Bool = false) -> CIImage {
        
        let filter = CIFilter.paletteCentroid()
        
        filter.setValue(self, forKey: "inputImage")
        filter.paletteImage = paletteImage
        filter.perceptual = perceptual
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func palettize(paletteImage: CIImage,
                        perceptual: Bool = false) -> CIImage {
        
        let filter = CIFilter.palettize()
        
        filter.setValue(self, forKey: "inputImage")
        filter.paletteImage = paletteImage
        filter.perceptual = perceptual
        
        return filter.outputImage ?? .empty()
    }
    
    public func photoEffectChrome() -> CIImage {
        return self.applyingFilter("CIPhotoEffectChrome", parameters: [:])
    }
    
    public func photoEffectFade() -> CIImage {
        return self.applyingFilter("CIPhotoEffectFade", parameters: [:])
    }
    
    public func photoEffectInstant() -> CIImage {
        return self.applyingFilter("CIPhotoEffectInstant", parameters: [:])
    }
    
    public func photoEffectMono() -> CIImage {
        return self.applyingFilter("CIPhotoEffectMono", parameters: [:])
    }
    
    public func photoEffectNoir() -> CIImage {
        return self.applyingFilter("CIPhotoEffectNoir", parameters: [:])
    }
    
    public func photoEffectProcess() -> CIImage {
        return self.applyingFilter("CIPhotoEffectProcess", parameters: [:])
    }
    
    public func photoEffectTonal() -> CIImage {
        return self.applyingFilter("CIPhotoEffectTonal", parameters: [:])
    }
    
    public func photoEffectTransfer() -> CIImage {
        return self.applyingFilter("CIPhotoEffectTransfer", parameters: [:])
    }
    
    public func sepiaTone(intensity: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CISepiaTone") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func thermal() -> CIImage {
        return self.applyingFilter("CIThermal", parameters: [:])
    }
    
    public func vignette(intensity: Float = 0,
                       radius: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIVignette") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(intensity, forKey: "inputIntensity")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func vignetteEffect(center: CGPoint = CGPoint(x: 150, y: 150),
                             radius: Float = 150,
                             intensity: Float = 1,
                             falloff: Float = 0.5) -> CIImage {
        
        guard let filter = CIFilter(name: "CIVignetteEffect") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(intensity, forKey: "inputIntensity")
        filter.setValue(falloff, forKey: "inputFalloff")
        
        return filter.outputImage ?? .empty()
    }
    
    public func xRay() -> CIImage {
        return self.applyingFilter("CIXRay", parameters: [:])
    }
    
    public func affineClamp(transform: CGAffineTransform = .identity) -> CIImage {
        
        guard let filter = CIFilter(name: "CIAffineClamp") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        
        #if os(macOS)
        
        let _transform = AffineTransform(m11: transform.a, m12: transform.b, m21: transform.c, m22: transform.d, tX: transform.tx, tY: transform.ty)
        filter.setValue(_transform as NSAffineTransform, forKey: "inputTransform")
        
        #else
        
        filter.setValue(NSValue(cgAffineTransform: transform), forKey: "inputTransform")
        
        #endif
        
        return filter.outputImage ?? .empty()
    }
    
    public func affineTile(transform: CGAffineTransform = .identity) -> CIImage {
        
        guard let filter = CIFilter(name: "CIAffineTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        
        #if os(macOS)
        
        let _transform = AffineTransform(m11: transform.a, m12: transform.b, m21: transform.c, m22: transform.d, tX: transform.tx, tY: transform.ty)
        filter.setValue(_transform as NSAffineTransform, forKey: "inputTransform")
        
        #else
        
        filter.setValue(NSValue(cgAffineTransform: transform), forKey: "inputTransform")
        
        #endif
        
        
        return filter.outputImage ?? .empty()
    }
    
    public func eightfoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                     angle: Float = 0,
                                     width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CIEightfoldReflectedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func fourfoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                    angle: Float = 0,
                                    width: Float = 100,
                                    acuteAngle: Float = 1.570796326794897) -> CIImage {
        
        guard let filter = CIFilter(name: "CIFourfoldReflectedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(acuteAngle, forKey: "inputAcuteAngle")
        
        return filter.outputImage ?? .empty()
    }
    
    public func fourfoldRotatedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                  angle: Float = 0,
                                  width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CIFourfoldRotatedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func fourfoldTranslatedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                     angle: Float = 0,
                                     width: Float = 100,
                                     acuteAngle: Float = 1.570796326794897) -> CIImage {
        
        guard let filter = CIFilter(name: "CIFourfoldTranslatedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(acuteAngle, forKey: "inputAcuteAngle")
        
        return filter.outputImage ?? .empty()
    }
    
    public func glideReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                 angle: Float = 0,
                                 width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CIGlideReflectedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func kaleidoscope(count: Int = 6,
                           center: CGPoint = CGPoint(x: 150, y: 150),
                           angle: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIKaleidoscope") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(count, forKey: "inputCount")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        
        return filter.outputImage ?? .empty()
    }
    
    public func opTile(center: CGPoint = CGPoint(x: 150, y: 150),
                     scale: Float = 2.8,
                     angle: Float = 0,
                     width: Float = 65) -> CIImage {
        
        guard let filter = CIFilter(name: "CIOpTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(scale, forKey: "inputScale")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func parallelogramTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                angle: Float = 0,
                                acuteAngle: Float = 1.570796326794897,
                                width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CIParallelogramTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(acuteAngle, forKey: "inputAcuteAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func perspectiveTile(topLeft: CGPoint = CGPoint(x: 118, y: 484),
                              topRight: CGPoint = CGPoint(x: 646, y: 507),
                              bottomRight: CGPoint = CGPoint(x: 548, y: 140),
                              bottomLeft: CGPoint = CGPoint(x: 155, y: 153)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPerspectiveTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        
        return filter.outputImage ?? .empty()
    }
    
    public func sixfoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                   angle: Float = 0,
                                   width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CISixfoldReflectedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func sixfoldRotatedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                 angle: Float = 0,
                                 width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CISixfoldRotatedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func triangleKaleidoscope(point: CGPoint = CGPoint(x: 150, y: 150),
                                   size: Float = 700,
                                   rotation: Float = 5.924285296593801,
                                   decay: Float = 0.85) -> CIImage {
        
        guard let filter = CIFilter(name: "CITriangleKaleidoscope") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: point), forKey: "inputPoint")
        filter.setValue(size, forKey: "inputSize")
        filter.setValue(rotation, forKey: "inputRotation")
        filter.setValue(decay, forKey: "inputDecay")
        
        return filter.outputImage ?? .empty()
    }
    
    public func triangleTile(center: CGPoint = CGPoint(x: 150, y: 150),
                           angle: Float = 0,
                           width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CITriangleTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func twelvefoldReflectedTile(center: CGPoint = CGPoint(x: 150, y: 150),
                                      angle: Float = 0,
                                      width: Float = 100) -> CIImage {
        
        guard let filter = CIFilter(name: "CITwelvefoldReflectedTile") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(angle, forKey: "inputAngle")
        filter.setValue(width, forKey: "inputWidth")
        
        return filter.outputImage ?? .empty()
    }
    
    public func blendWithAlphaMask(backgroundImage: CIImage,
                                 maskImage: CIImage) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBlendWithAlphaMask") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(backgroundImage, forKey: "inputBackgroundImage")
        filter.setValue(maskImage, forKey: "inputMaskImage")
        
        return filter.outputImage ?? .empty()
    }
    
    public func blendWithBlueMask(backgroundImage: CIImage,
                                maskImage: CIImage) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBlendWithBlueMask") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(backgroundImage, forKey: "inputBackgroundImage")
        filter.setValue(maskImage, forKey: "inputMaskImage")
        
        return filter.outputImage ?? .empty()
    }
    
    public func blendWithMask(backgroundImage: CIImage,
                            maskImage: CIImage) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBlendWithMask") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(backgroundImage, forKey: "inputBackgroundImage")
        filter.setValue(maskImage, forKey: "inputMaskImage")
        
        return filter.outputImage ?? .empty()
    }
    
    public func blendWithRedMask(backgroundImage: CIImage,
                               maskImage: CIImage) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBlendWithRedMask") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(backgroundImage, forKey: "inputBackgroundImage")
        filter.setValue(maskImage, forKey: "inputMaskImage")
        
        return filter.outputImage ?? .empty()
    }
    
    public func bloom(radius: Float = 10,
                    intensity: Float = 0.5) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBloom") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func comicEffect() -> CIImage {
        return self.applyingFilter("CIComicEffect", parameters: [:])
    }
    
    public func crystallize(radius: Float = 20,
                          center: CGPoint = CGPoint(x: 150, y: 150)) -> CIImage {
        
        guard let filter = CIFilter(name: "CICrystallize") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        
        return filter.outputImage ?? .empty()
    }
    
    public func depthOfField(point0: CGPoint = CGPoint(x: 0, y: 300),
                           point1: CGPoint = CGPoint(x: 300, y: 300),
                           saturation: Float = 1.5,
                           unsharpMaskRadius: Float = 2.5,
                           unsharpMaskIntensity: Float = 0.5,
                           radius: Float = 6) -> CIImage {
        
        guard let filter = CIFilter(name: "CIDepthOfField") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
        filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
        filter.setValue(saturation, forKey: "inputSaturation")
        filter.setValue(unsharpMaskRadius, forKey: "inputUnsharpMaskRadius")
        filter.setValue(unsharpMaskIntensity, forKey: "inputUnsharpMaskIntensity")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func edges(intensity: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIEdges") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func edgeWork(radius: Float = 3) -> CIImage {
        
        guard let filter = CIFilter(name: "CIEdgeWork") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func gaborGradients() -> CIImage {
        
        let filter = CIFilter.gaborGradients()
        
        filter.setValue(self, forKey: "inputImage")
        
        return filter.outputImage ?? .empty()
    }
    
    public func gloom(radius: Float = 10,
                    intensity: Float = 0.5) -> CIImage {
        
        guard let filter = CIFilter(name: "CIGloom") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(intensity, forKey: "inputIntensity")
        
        return filter.outputImage ?? .empty()
    }
    
    public func heightFieldFromMask(radius: Float = 10) -> CIImage {
        
        guard let filter = CIFilter(name: "CIHeightFieldFromMask") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func hexagonalPixellate(center: CGPoint = CGPoint(x: 150, y: 150),
                                 scale: Float = 8) -> CIImage {
        
        guard let filter = CIFilter(name: "CIHexagonalPixellate") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(scale, forKey: "inputScale")
        
        return filter.outputImage ?? .empty()
    }
    
    public func highlightShadowAdjust(radius: Float = 0,
                                    shadowAmount: Float = 0,
                                    highlightAmount: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(shadowAmount, forKey: "inputShadowAmount")
        filter.setValue(highlightAmount, forKey: "inputHighlightAmount")
        
        return filter.outputImage ?? .empty()
    }
    
    public func lineOverlay(nrNoiseLevel: Float = 0.07000000000000001,
                          nrSharpness: Float = 0.71,
                          edgeIntensity: Float = 1,
                          threshold: Float = 0.1,
                          contrast: Float = 50) -> CIImage {
        
        guard let filter = CIFilter(name: "CILineOverlay") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(nrNoiseLevel, forKey: "inputNRNoiseLevel")
        filter.setValue(nrSharpness, forKey: "inputNRSharpness")
        filter.setValue(edgeIntensity, forKey: "inputEdgeIntensity")
        filter.setValue(threshold, forKey: "inputThreshold")
        filter.setValue(contrast, forKey: "inputContrast")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
    public func mix(backgroundImage: CIImage,
                  amount: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIMix") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(backgroundImage, forKey: "inputBackgroundImage")
        filter.setValue(amount, forKey: "inputAmount")
        
        return filter.outputImage ?? .empty()
    }
    
    public func pixellate(center: CGPoint = CGPoint(x: 150, y: 150),
                        scale: Float = 8) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPixellate") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(scale, forKey: "inputScale")
        
        return filter.outputImage ?? .empty()
    }
    
    public func pointillize(radius: Float = 20,
                          center: CGPoint = CGPoint(x: 150, y: 150)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIPointillize") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, *)
    public func saliencyMap() -> CIImage {
        return self.applyingFilter("CISaliencyMapFilter", parameters: [:])
    }
    
    public func shadedMaterial(shadingImage: CIImage,
                             scale: Float = 10) -> CIImage {
        
        guard let filter = CIFilter(name: "CIShadedMaterial") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(shadingImage, forKey: "inputShadingImage")
        filter.setValue(scale, forKey: "inputScale")
        
        return filter.outputImage ?? .empty()
    }
    
    public func spotColor(centerColor1: CIColor = CIColor(red: 0.0784, green: 0.0627, blue: 0.0706, alpha: 1),
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
        
        guard let filter = CIFilter(name: "CISpotColor") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
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
        
        return filter.outputImage ?? .empty()
    }
    
    public func spotLight(lightPosition: CIVector = CIVector(x: 400, y: 600, z: 150),
                        lightPointsAt: CIVector = CIVector(x: 200, y: 200, z: 0),
                        brightness: Float = 3,
                        concentration: Float = 0.1,
                        color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CISpotLight") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(lightPosition, forKey: "inputLightPosition")
        filter.setValue(lightPointsAt, forKey: "inputLightPointsAt")
        filter.setValue(brightness, forKey: "inputBrightness")
        filter.setValue(concentration, forKey: "inputConcentration")
        filter.setValue(color, forKey: "inputColor")
        
        return filter.outputImage ?? .empty()
    }
    
    public func bokehBlur(radius: Float = 20,
                        ringAmount: Float = 0,
                        ringSize: Float = 0.1,
                        softness: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBokehBlur") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(ringAmount, forKey: "inputRingAmount")
        filter.setValue(ringSize, forKey: "inputRingSize")
        filter.setValue(softness, forKey: "inputSoftness")
        
        return filter.outputImage ?? .empty()
    }
    
    public func boxBlur(radius: Float = 10) -> CIImage {
        
        guard let filter = CIFilter(name: "CIBoxBlur") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func discBlur(radius: Float = 8) -> CIImage {
        
        guard let filter = CIFilter(name: "CIDiscBlur") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func maskedVariableBlur(mask: CIImage,
                                 radius: Float = 5) -> CIImage {
        
        guard let filter = CIFilter(name: "CIMaskedVariableBlur") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(mask, forKey: "inputMask")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func median() -> CIImage {
        return self.applyingFilter("CIMedianFilter", parameters: [:])
    }
    
    public func morphologyGradient(radius: Float = 5) -> CIImage {
        
        guard let filter = CIFilter(name: "CIMorphologyGradient") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func morphologyMaximum(radius: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIMorphologyMaximum") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public func morphologyMinimum(radius: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIMorphologyMinimum") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func morphologyRectangleMaximum(width: Float = 5,
                                         height: Float = 5) -> CIImage {
        
        let filter = CIFilter.morphologyRectangleMaximum()
        
        filter.setValue(self, forKey: "inputImage")
        filter.width = width
        filter.height = height
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public func morphologyRectangleMinimum(width: Float = 5,
                                         height: Float = 5) -> CIImage {
        
        let filter = CIFilter.morphologyRectangleMinimum()
        
        filter.setValue(self, forKey: "inputImage")
        filter.width = width
        filter.height = height
        
        return filter.outputImage ?? .empty()
    }
    
    public func motionBlur(radius: Float = 20,
                         angle: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CIMotionBlur") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(angle, forKey: "inputAngle")
        
        return filter.outputImage ?? .empty()
    }
    
    public func noiseReduction(noiseLevel: Float = 0.02,
                             sharpness: Float = 0.4) -> CIImage {
        
        guard let filter = CIFilter(name: "CINoiseReduction") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(noiseLevel, forKey: "inputNoiseLevel")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public func zoomBlur(center: CGPoint = CGPoint(x: 150, y: 150),
                       amount: Float = 20) -> CIImage {
        
        guard let filter = CIFilter(name: "CIZoomBlur") else { return .empty() }
        
        filter.setValue(self, forKey: "inputImage")
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(amount, forKey: "inputAmount")
        
        return filter.outputImage ?? .empty()
    }
    
}

extension CIImage {
    
    public class func GaussianGradient(center: CGPoint = CGPoint(x: 150, y: 150),
                                     color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                     color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                                     radius: Float = 300) -> CIImage {
        
        guard let filter = CIFilter(name: "CIGaussianGradient") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        filter.setValue(radius, forKey: "inputRadius")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func HueSaturationValueGradient(value: Float = 1,
                                               radius: Float = 300,
                                               softness: Float = 1,
                                               dither: Float = 1,
                                               colorSpace: CGColorSpace? = CGColorSpace(name: CGColorSpace.sRGB)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIHueSaturationValueGradient") else { return .empty() }
        
        filter.setValue(value, forKey: "inputValue")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(softness, forKey: "inputSoftness")
        filter.setValue(dither, forKey: "inputDither")
        filter.setValue(colorSpace, forKey: "inputColorSpace")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func LinearGradient(point0: CGPoint = CGPoint(x: 0, y: 0),
                                   point1: CGPoint = CGPoint(x: 200, y: 200),
                                   color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                   color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CILinearGradient") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
        filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func RadialGradient(center: CGPoint = CGPoint(x: 150, y: 150),
                                   radius0: Float = 5,
                                   radius1: Float = 100,
                                   color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                   color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CIRadialGradient") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(radius0, forKey: "inputRadius0")
        filter.setValue(radius1, forKey: "inputRadius1")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func SmoothLinearGradient(point0: CGPoint = CGPoint(x: 0, y: 0),
                                         point1: CGPoint = CGPoint(x: 200, y: 200),
                                         color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                         color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1)) -> CIImage {
        
        guard let filter = CIFilter(name: "CISmoothLinearGradient") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: point0), forKey: "inputPoint0")
        filter.setValue(CIVector(cgPoint: point1), forKey: "inputPoint1")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        
        return filter.outputImage ?? .empty()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    public class func RoundedRectangleGenerator(extent: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100),
                                              radius: Float = 10,
                                              color: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1)) -> CIImage {
        
        let filter = CIFilter.roundedRectangleGenerator()
        
        filter.extent = extent
        filter.radius = radius
        filter.color = color
        
        return filter.outputImage ?? .empty()
    }
    
    public class func StarShineGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                       color: CIColor = CIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1),
                                       radius: Float = 50,
                                       crossScale: Float = 15,
                                       crossAngle: Float = 0.6,
                                       crossOpacity: Float = -2,
                                       crossWidth: Float = 2.5,
                                       epsilon: Float = -2) -> CIImage {
        
        guard let filter = CIFilter(name: "CIStarShineGenerator") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(crossScale, forKey: "inputCrossScale")
        filter.setValue(crossAngle, forKey: "inputCrossAngle")
        filter.setValue(crossOpacity, forKey: "inputCrossOpacity")
        filter.setValue(crossWidth, forKey: "inputCrossWidth")
        filter.setValue(epsilon, forKey: "inputEpsilon")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func StripesGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                     color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                     color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1),
                                     width: Float = 80,
                                     sharpness: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CIStripesGenerator") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func SunbeamsGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                      color: CIColor = CIColor(red: 1, green: 0.5, blue: 0, alpha: 1),
                                      sunRadius: Float = 40,
                                      maxStriationRadius: Float = 2.58,
                                      striationStrength: Float = 0.5,
                                      striationContrast: Float = 1.375,
                                      time: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CISunbeamsGenerator") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(sunRadius, forKey: "inputSunRadius")
        filter.setValue(maxStriationRadius, forKey: "inputMaxStriationRadius")
        filter.setValue(striationStrength, forKey: "inputStriationStrength")
        filter.setValue(striationContrast, forKey: "inputStriationContrast")
        filter.setValue(time, forKey: "inputTime")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func AztecCodeGenerator(message: String,
                                       correction level: Float = 23,
                                       layers: Float? = nil,
                                       compact: Bool = false) -> CIImage {
        
        guard let data = message.data(using: .isoLatin1) else { return .empty() }
        
        guard let filter = CIFilter(name: "CIAztecCodeGenerator") else { return .empty() }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(level, forKey: "inputCorrectionLevel")
        filter.setValue(layers, forKey: "inputLayers")
        filter.setValue(compact, forKey: "inputCompactStyle")
        
        return filter.outputImage ?? .empty()
    }
    
    public enum QRCorrectionLevel: String, CaseIterable {
        
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
    }
    
    public class func QRCodeGenerator(message: String,
                                    correction level: QRCorrectionLevel = .medium) -> CIImage {
        
        guard let data = message.data(using: .isoLatin1) else { return .empty() }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return .empty() }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(level.rawValue, forKey: "inputCorrectionLevel")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func Code128BarcodeGenerator(message: String,
                                            quietSpace: Float = 7,
                                            barcodeHeight: Float = 32) -> CIImage {
        
        guard let data = message.data(using: .ascii) else { return .empty() }
        
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return .empty() }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(quietSpace, forKey: "inputQuietSpace")
        filter.setValue(barcodeHeight, forKey: "inputBarcodeHeight")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func CheckerboardGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                          color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 1),
                                          color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 1),
                                          width: Float = 80,
                                          sharpness: Float = 1) -> CIImage {
        
        guard let filter = CIFilter(name: "CICheckerboardGenerator") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(color0, forKey: "inputColor0")
        filter.setValue(color1, forKey: "inputColor1")
        filter.setValue(width, forKey: "inputWidth")
        filter.setValue(sharpness, forKey: "inputSharpness")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func LenticularHaloGenerator(center: CGPoint = CGPoint(x: 150, y: 150),
                                            color: CIColor = CIColor(red: 1, green: 0.9, blue: 0.8, alpha: 1),
                                            haloRadius: Float = 70,
                                            haloWidth: Float = 87,
                                            haloOverlap: Float = 0.77,
                                            striationStrength: Float = 0.5,
                                            striationContrast: Float = 1,
                                            time: Float = 0) -> CIImage {
        
        guard let filter = CIFilter(name: "CILenticularHaloGenerator") else { return .empty() }
        
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(color, forKey: "inputColor")
        filter.setValue(haloRadius, forKey: "inputHaloRadius")
        filter.setValue(haloWidth, forKey: "inputHaloWidth")
        filter.setValue(haloOverlap, forKey: "inputHaloOverlap")
        filter.setValue(striationStrength, forKey: "inputStriationStrength")
        filter.setValue(striationContrast, forKey: "inputStriationContrast")
        filter.setValue(time, forKey: "inputTime")
        
        return filter.outputImage ?? .empty()
    }
    
    public class func PDF417BarcodeGenerator(message: String,
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
                                           alwaysSpecifyCompaction: Float) -> CIImage {
        
        guard let data = message.data(using: .isoLatin1) else { return .empty() }
        
        guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else { return .empty() }
        
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
        
        return filter.outputImage ?? .empty()
    }
    
    public class func RandomGenerator() -> CIImage {
        return CIFilter(name: "CIRandomGenerator")?.outputImage ?? .empty()
    }
    
}

#endif
