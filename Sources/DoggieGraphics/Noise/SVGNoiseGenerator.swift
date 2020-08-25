//
//  SVGNoiseGenerator.swift
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

@frozen
public struct SVGNoiseGenerator {
    
    public let seed: Int
    
    public private(set) var uLatticeSelector: [Int]
    
    public private(set) var fGradient: [Point]
    
    public init(_ seed: Int) {
        
        let BSize = 0x100
        let _BSize = BSize + BSize + 2
        
        self.seed = seed
        self.uLatticeSelector = Array(repeating: 0, count: _BSize)
        self.fGradient = Array(repeating: Point(), count: _BSize * 4)
        
        var RG = RandomGenerator(seed)
        
        for k in 0..<4 {
            for i in 0..<BSize {
                uLatticeSelector[i] = i
                fGradient[k * _BSize + i].x = Double((RG.random() % (BSize + BSize)) - BSize) / Double(BSize)
                fGradient[k * _BSize + i].y = Double((RG.random() % (BSize + BSize)) - BSize) / Double(BSize)
                fGradient[k * _BSize + i] /= fGradient[k * _BSize + i].magnitude
            }
        }
        
        for i in (1..<BSize).reversed() {
            let k = uLatticeSelector[i]
            let j = RG.random() % BSize
            uLatticeSelector[i] = uLatticeSelector[j]
            uLatticeSelector[j] = k
        }
        
        for i in 0..<BSize + 2 {
            uLatticeSelector[BSize + i] = uLatticeSelector[i]
            for k in 0..<4 {
                fGradient[k * _BSize + BSize + i] = fGradient[k * _BSize + i]
            }
        }
    }
}

extension SVGNoiseGenerator {
    
    private static let RAND_m = 2147483647
    private static let RAND_a = 16807
    private static let RAND_q = 127773
    private static let RAND_r = 2836
    
    private struct RandomGenerator {
        
        private var seed: Int
        
        init(_ lSeed: Int) {
            var lSeed = lSeed
            if lSeed <= 0 {
                lSeed = -(lSeed % (RAND_m - 1)) + 1
            }
            if lSeed > RAND_m - 1 {
                lSeed = RAND_m - 1
            }
            self.seed = lSeed
        }
        
        private mutating func _random() {
            var result = RAND_a * (seed % RAND_q) - RAND_r * (seed / RAND_q)
            if result <= 0 {
                result += RAND_m
            }
            self.seed = result
        }
        
        mutating func random() -> Int {
            self._random()
            return seed
        }
    }
}

extension SVGNoiseGenerator {
    
    @frozen
    @usableFromInline
    struct StitchInfo {
        
        @usableFromInline
        var width: Int
        
        @usableFromInline
        var height: Int
        
        @usableFromInline
        var wrapX: Int
        
        @usableFromInline
        var wrapY: Int
        
        @inlinable
        init() {
            self.width = 0
            self.height = 0
            self.wrapX = 0
            self.wrapY = 0
        }
    }
    
    @inlinable
    static func s_curve(_ t: Double) -> Double {
        return t * t * (3.0 - 2.0 * t)
    }
    
    @inlinable
    static func lerp(_ t: Double, _ a: Double, _ b: Double) -> Double {
        return a + t * (b - a)
    }
    
    @inlinable
    func noise2(_ uLatticeSelector: UnsafePointer<Int>, _ fGradient: UnsafePointer<Point>, _ point: Point, _ stitch: StitchInfo?) -> Double {
        
        var bx0, bx1, by0, by1, b00, b10, b01, b11: Int
        var rx0, rx1, ry0, ry1, sx, sy, a, b, t, u, v: Double
        var q: Point
        
        t = point.x + 4096
        bx0 = Int(t)
        bx1 = bx0 + 1
        rx0 = t - Double(Int(t))
        rx1 = rx0 - 1.0
        t = point.y + 4096
        by0 = Int(t)
        by1 = by0 + 1
        ry0 = t - Double(Int(t))
        ry1 = ry0 - 1.0
        
        if let stitch = stitch {
            if bx0 >= stitch.wrapX {
                bx0 -= stitch.width
            }
            if bx1 >= stitch.wrapX {
                bx1 -= stitch.width
            }
            if by0 >= stitch.wrapY {
                by0 -= stitch.height
            }
            if by1 >= stitch.wrapY {
                by1 -= stitch.height
            }
        }
        
        bx0 &= 0xFF
        bx1 &= 0xFF
        by0 &= 0xFF
        by1 &= 0xFF
        
        let i = uLatticeSelector[bx0]
        let j = uLatticeSelector[bx1]
        b00 = uLatticeSelector[i + by0]
        b10 = uLatticeSelector[j + by0]
        b01 = uLatticeSelector[i + by1]
        b11 = uLatticeSelector[j + by1]
        sx = SVGNoiseGenerator.s_curve(rx0)
        sy = SVGNoiseGenerator.s_curve(ry0)
        
        q = fGradient[b00]
        u = rx0 * q.x + ry0 * q.y
        q = fGradient[b10]
        v = rx1 * q.x + ry0 * q.y
        a = SVGNoiseGenerator.lerp(sx, u, v)
        q = fGradient[b01]
        u = rx0 * q.x + ry1 * q.y
        q = fGradient[b11]
        v = rx1 * q.x + ry1 * q.y
        b = SVGNoiseGenerator.lerp(sx, u, v)
        
        return SVGNoiseGenerator.lerp(sy, a, b)
    }
    
    @inlinable
    func _turbulence(_ uLatticeSelector: UnsafeBufferPointer<Int>, _ fGradient: UnsafeBufferPointer<Point>, _ channel: Int, _ point: Point, _ baseFreqX: Double, _ baseFreqY: Double, _ numOctaves: Int, _ fractalSum: Bool, _ stitchTile: Rect?) -> Double {
        
        var stitch = StitchInfo()
        
        var baseFreqX = baseFreqX
        var baseFreqY = baseFreqY
        
        if let stitchTile = stitchTile {
            
            if baseFreqX != 0.0 {
                let fLoFreq = floor(stitchTile.width * baseFreqX) / stitchTile.width
                let fHiFreq = ceil(stitchTile.width * baseFreqX) / stitchTile.width
                if baseFreqX / fLoFreq < fHiFreq / baseFreqX {
                    baseFreqX = fLoFreq
                } else {
                    baseFreqX = fHiFreq
                }
            }
            if baseFreqY != 0.0 {
                let fLoFreq = floor(stitchTile.height * baseFreqY) / stitchTile.height
                let fHiFreq = ceil(stitchTile.height * baseFreqY) / stitchTile.height
                if baseFreqY / fLoFreq < fHiFreq / baseFreqY {
                    baseFreqY = fLoFreq
                } else {
                    baseFreqY = fHiFreq
                }
            }
            
            stitch.width = Int(stitchTile.width * baseFreqX + 0.5)
            stitch.wrapX = Int(stitchTile.minX * baseFreqX + 4096 + Double(stitch.width))
            stitch.height = Int(stitchTile.height * baseFreqY + 0.5)
            stitch.wrapY = Int(stitchTile.minY * baseFreqY + 4096 + Double(stitch.height))
        }
        
        var fSum = 0.0
        var point = point
        point.x *= baseFreqX
        point.y *= baseFreqY
        var ratio = 1.0
        
        let BSize = 0x100
        let _BSize = BSize + BSize + 2
        
        let uLatticeSelector = uLatticeSelector.baseAddress!
        let fGradient = fGradient.baseAddress! + channel * _BSize
        
        for _ in 0..<numOctaves {
            
            if fractalSum {
                fSum += noise2(uLatticeSelector, fGradient, point, stitchTile == nil ? nil : stitch) / ratio
            } else {
                fSum += fabs(noise2(uLatticeSelector, fGradient, point, stitchTile == nil ? nil : stitch)) / ratio
            }
            
            point.x *= 2
            point.y *= 2
            ratio *= 2
            
            if stitchTile != nil {
                stitch.width *= 2
                stitch.wrapX = 2 * stitch.wrapX - 0x1000
                stitch.height *= 2
                stitch.wrapY = 2 * stitch.wrapY - 0x1000
            }
        }
        
        return fSum
        
    }
    
    @inlinable
    public func turbulence(_ channel: Int, _ point: Point, _ baseFreqX: Double, _ baseFreqY: Double, _ numOctaves: Int, _ fractalSum: Bool, _ stitchTile: Rect?) -> Double {
        return uLatticeSelector.withUnsafeBufferPointer { uLatticeSelector in fGradient.withUnsafeBufferPointer { fGradient in self._turbulence(uLatticeSelector, fGradient, channel, point, baseFreqX, baseFreqY, numOctaves, fractalSum, stitchTile) } }
    }
}
