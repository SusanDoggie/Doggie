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
        ("testPng2", testPng2),
        ("testTiff1", testTiff1),
        ("testTiff2", testTiff2),
        ("testTiff3", testTiff3),
        ("testTiff4", testTiff4),
    ]
}

extension ImageTest {
    static let __allTests = [
        ("testClipPerformance", testClipPerformance),
        ("testColorSpaceConversionPerformance", testColorSpaceConversionPerformance),
        ("testDrawing", testDrawing),
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
