import XCTest

extension ArithmeticTest {
    static let __allTests = [
        ("testColorOperation", testColorOperation),
        ("testFloatComponentsOperation", testFloatComponentsOperation),
        ("testTensorOperation", testTensorOperation),
    ]
}

extension AtomicTest {
    static let __allTests = [
        ("testAtomicA", testAtomicA),
        ("testAtomicQueueA", testAtomicQueueA),
        ("testAtomicQueueB", testAtomicQueueB),
        ("testAtomicStackA", testAtomicStackA),
        ("testAtomicStackB", testAtomicStackB),
    ]
}

extension CollectionTest {
    static let __allTests = [
        ("testCollectionRangeOf", testCollectionRangeOf),
        ("testConcatCollection", testConcatCollection),
        ("testIndexedCollection", testIndexedCollection),
        ("testLazySequenceScan", testLazySequenceScan),
        ("testNextPermute1", testNextPermute1),
        ("testNextPermute2", testNextPermute2),
        ("testOptionOneCollection1", testOptionOneCollection1),
        ("testOptionOneCollection2", testOptionOneCollection2),
        ("testSequenceScan", testSequenceScan),
    ]
}

extension ColorSpaceTest {
    static let __allTests = [
        ("testLoadingColorSpace", testLoadingColorSpace),
    ]
}

extension CompressionTest {
    static let __allTests = [
        ("testDeflatePerformance", testDeflatePerformance),
        ("testGzip", testGzip),
        ("testInflatePerformance", testInflatePerformance),
        ("testZlib", testZlib),
    ]
}

extension FontTest {
    static let __allTests = [
        ("testLoadingFont", testLoadingFont),
    ]
}

extension FourierTest {
    static let __allTests = [
        ("testCircularConvolve", testCircularConvolve),
        ("testCircularConvolveComplex", testCircularConvolveComplex),
        ("testCircularConvolvePerformance", testCircularConvolvePerformance),
        ("testCircularConvolvePerformanceX2", testCircularConvolvePerformanceX2),
        ("testCircularConvolvePerformanceX3", testCircularConvolvePerformanceX3),
        ("testConvolve", testConvolve),
        ("testConvolveComplex", testConvolveComplex),
        ("testDCTII", testDCTII),
        ("testDCTIII", testDCTIII),
        ("testDCTIV", testDCTIV),
        ("testDSTII", testDSTII),
        ("testDSTIII", testDSTIII),
        ("testDSTIV", testDSTIV),
        ("testFourierBPerformance", testFourierBPerformance),
        ("testFourierBPerformanceX2", testFourierBPerformanceX2),
        ("testFourierCPerformance", testFourierCPerformance),
        ("testFourierCPerformanceX2", testFourierCPerformanceX2),
        ("testFourierCPerformanceX3", testFourierCPerformanceX3),
        ("testInverseRadix2CooleyTukeyA", testInverseRadix2CooleyTukeyA),
        ("testInverseRadix2CooleyTukeyB", testInverseRadix2CooleyTukeyB),
        ("testInverseRadix2CooleyTukeyComplexA", testInverseRadix2CooleyTukeyComplexA),
        ("testInverseRadix2CooleyTukeyComplexB", testInverseRadix2CooleyTukeyComplexB),
        ("testNegacyclicConvolve", testNegacyclicConvolve),
        ("testNegacyclicConvolveComplex", testNegacyclicConvolveComplex),
        ("testRadix2CooleyTukeyA", testRadix2CooleyTukeyA),
        ("testRadix2CooleyTukeyB", testRadix2CooleyTukeyB),
        ("testRadix2CooleyTukeyComplexA", testRadix2CooleyTukeyComplexA),
        ("testRadix2CooleyTukeyComplexB", testRadix2CooleyTukeyComplexB),
    ]
}

extension ImageCodecTest {
    static let __allTests = [
        ("testBmp1", testBmp1),
        ("testBmp2", testBmp2),
        ("testPng1", testPng1),
        ("testPng1Interlaced", testPng1Interlaced),
        ("testPng2", testPng2),
        ("testPng2Interlaced", testPng2Interlaced),
        ("testPng3", testPng3),
        ("testPng3Interlaced", testPng3Interlaced),
        ("testPng4", testPng4),
        ("testPng4Interlaced", testPng4Interlaced),
        ("testPngSuite", testPngSuite),
        ("testRGB555Big", testRGB555Big),
        ("testRGB555Little", testRGB555Little),
        ("testRGB8816Big", testRGB8816Big),
        ("testRGBA32Big", testRGBA32Big),
        ("testRGBA32Little", testRGBA32Little),
        ("testRGBA64Big", testRGBA64Big),
        ("testRGBA64Little", testRGBA64Little),
        ("testRGBFloat32Big", testRGBFloat32Big),
        ("testRGBFloat32Little", testRGBFloat32Little),
        ("testRGBFloat64Big", testRGBFloat64Big),
        ("testRGBFloat64Little", testRGBFloat64Little),
        ("testTiff1", testTiff1),
        ("testTiff1Deflate", testTiff1Deflate),
        ("testTiff2", testTiff2),
        ("testTiff2Deflate", testTiff2Deflate),
        ("testTiff3", testTiff3),
        ("testTiff3Deflate", testTiff3Deflate),
        ("testTiff4", testTiff4),
        ("testTiff4Deflate", testTiff4Deflate),
        ("testTiff5", testTiff5),
        ("testTiff5Deflate", testTiff5Deflate),
        ("testTiff6", testTiff6),
        ("testTiff6Deflate", testTiff6Deflate),
        ("testTiffOrientation1", testTiffOrientation1),
        ("testTiffOrientation2", testTiffOrientation2),
    ]
}

extension ImageTest {
    static let __allTests = [
        ("testClipPerformance", testClipPerformance),
        ("testColorSpaceConversionPerformance", testColorSpaceConversionPerformance),
        ("testDrawing", testDrawing),
        ("testImageGaussianBlur", testImageGaussianBlur),
        ("testLinearGradientPerformance", testLinearGradientPerformance),
        ("testRadialGradientPerformance", testRadialGradientPerformance),
        ("testResamplingCosineAntialiasPerformance", testResamplingCosineAntialiasPerformance),
        ("testResamplingCosinePerformance", testResamplingCosinePerformance),
        ("testResamplingCubicAntialiasPerformance", testResamplingCubicAntialiasPerformance),
        ("testResamplingCubicPerformance", testResamplingCubicPerformance),
        ("testResamplingHermiteAntialiasPerformance", testResamplingHermiteAntialiasPerformance),
        ("testResamplingHermitePerformance", testResamplingHermitePerformance),
        ("testResamplingLanczosAntialiasPerformance", testResamplingLanczosAntialiasPerformance),
        ("testResamplingLanczosPerformance", testResamplingLanczosPerformance),
        ("testResamplingLinearAntialiasPerformance", testResamplingLinearAntialiasPerformance),
        ("testResamplingLinearPerformance", testResamplingLinearPerformance),
        ("testResamplingMitchellAntialiasPerformance", testResamplingMitchellAntialiasPerformance),
        ("testResamplingMitchellPerformance", testResamplingMitchellPerformance),
        ("testResamplingNoneAntialiasPerformance", testResamplingNoneAntialiasPerformance),
        ("testResamplingNonePerformance", testResamplingNonePerformance),
        ("testStencilTextureConvolutionA", testStencilTextureConvolutionA),
        ("testStencilTextureConvolutionB", testStencilTextureConvolutionB),
        ("testStencilTextureConvolutionC", testStencilTextureConvolutionC),
    ]
}

extension PolynomialTest {
    static let __allTests = [
        ("testPolynomialDivPerformance", testPolynomialDivPerformance),
        ("testPolynomialModPerformance", testPolynomialModPerformance),
        ("testPolynomialMulPerformance", testPolynomialMulPerformance),
        ("testPolynomialPowPerformance", testPolynomialPowPerformance),
    ]
}

extension ShapeRegionTest {
    static let __allTests = [
        ("testShapeRegionEvenOdd", testShapeRegionEvenOdd),
        ("testShapeRegionIntersection", testShapeRegionIntersection),
        ("testShapeRegionNonZero", testShapeRegionNonZero),
        ("testShapeRegionSubtracting", testShapeRegionSubtracting),
        ("testShapeRegionSymmetricDifference", testShapeRegionSymmetricDifference),
        ("testShapeRegionUnion", testShapeRegionUnion),
    ]
}

extension XMLTest {
    static let __allTests = [
        ("testXMLA", testXMLA),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArithmeticTest.__allTests),
        testCase(AtomicTest.__allTests),
        testCase(CollectionTest.__allTests),
        testCase(ColorSpaceTest.__allTests),
        testCase(CompressionTest.__allTests),
        testCase(FontTest.__allTests),
        testCase(FourierTest.__allTests),
        testCase(ImageCodecTest.__allTests),
        testCase(ImageTest.__allTests),
        testCase(PolynomialTest.__allTests),
        testCase(ShapeRegionTest.__allTests),
        testCase(XMLTest.__allTests),
    ]
}
#endif
