//
//  SVGNoise.swift
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

public struct SVGNoise {

    private var uLatticeSelector: [Int]
    private var fGradient: [[Point]]

    public init(_ lSeed: Int) {

        let BSize = 0x100

        self.uLatticeSelector = Array(zeros: BSize + BSize + 2)
        self.fGradient = Array(repeating: Array(repeating: Point(), count: BSize + BSize + 2), count: 4)

        var RG = RandomGenerator(lSeed)

        for k in 0..<4 {
            for i in 0..<BSize {
                uLatticeSelector[i] = i
                fGradient[k][i].x = Double((RG.random() % (BSize + BSize)) - BSize) / Double(BSize)
                fGradient[k][i].y = Double((RG.random() % (BSize + BSize)) - BSize) / Double(BSize)
                fGradient[k][i] /= fGradient[k][i].magnitude
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
                fGradient[k][BSize + i] = fGradient[k][i]
            }
        }
    }
}

extension SVGNoise {

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

extension SVGNoise {

    private struct StitchInfo {

        var width: Int = 0
        var height: Int = 0
        var wrapX: Int = 0
        var wrapY: Int = 0
    }

    private static func s_curve(_ t: Double) -> Double {
        return t * t * (3.0 - 2.0 * t)
    }
    private static func lerp(_ t: Double, _ a: Double, _ b: Double) -> Double {
        return a + t * (b - a)
    }

    private func noise2(_ channel: Int, _ point: Point, _ stitchInfo: StitchInfo?) -> Double {

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

        if let stitchInfo = stitchInfo {
            if bx0 >= stitchInfo.wrapX {
                bx0 -= stitchInfo.width
            }
            if bx1 >= stitchInfo.wrapX {
                bx1 -= stitchInfo.width
            }
            if by0 >= stitchInfo.wrapY {
                by0 -= stitchInfo.height
            }
            if by1 >= stitchInfo.wrapY {
                by1 -= stitchInfo.height
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
        sx = SVGNoise.s_curve(rx0)
        sy = SVGNoise.s_curve(ry0)

        q = fGradient[channel][b00]
        u = rx0 * q.x + ry0 * q.y
        q = fGradient[channel][b10]
        v = rx1 * q.x + ry0 * q.y
        a = SVGNoise.lerp(sx, u, v)
        q = fGradient[channel][b01]
        u = rx0 * q.x + ry1 * q.y
        q = fGradient[channel][b11]
        v = rx1 * q.x + ry1 * q.y
        b = SVGNoise.lerp(sx, u, v)

        return SVGNoise.lerp(sy, a, b)
    }

    public func turbulence(_ channel: Int, _ point: Point, _ baseFreqX: Double, _ baseFreqY: Double, _ numOctaves: Int, _ fractalSum: Bool, _ stitchTile: Rect?) -> Double {

        var stitchInfo: StitchInfo?

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

            stitchInfo = StitchInfo()
            stitchInfo!.width = Int(stitchTile.width * baseFreqX + 0.5)
            stitchInfo!.wrapX = Int(stitchTile.x * baseFreqX + 4096 + Double(stitchInfo!.width))
            stitchInfo!.height = Int(stitchTile.height * baseFreqY + 0.5)
            stitchInfo!.wrapY = Int(stitchTile.y * baseFreqY + 4096 + Double(stitchInfo!.height))
        }

        var fSum = 0.0
        var point = point
        point.x *= baseFreqX
        point.y *= baseFreqY
        var ratio = 1.0

        for _ in 0..<numOctaves {

            if fractalSum {
                fSum += noise2(channel, point, stitchInfo) / ratio
            } else {
                fSum += fabs(noise2(channel, point, stitchInfo)) / ratio
            }

            point.x *= 2
            point.y *= 2
            ratio *= 2

            if stitchInfo != nil {
                stitchInfo!.width *= 2
                stitchInfo!.wrapX = 2 * stitchInfo!.wrapX - 0x1000
                stitchInfo!.height *= 2
                stitchInfo!.wrapY = 2 * stitchInfo!.wrapY - 0x1000
            }
        }
        return fSum
    }
}
