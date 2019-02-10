//
//  iccCurve.swift
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

@usableFromInline
enum iccCurve {

    case identity
    case gamma(Double)
    case parametric1(Double, Double, Double)
    case parametric2(Double, Double, Double, Double)
    case parametric3(Double, Double, Double, Double, Double)
    case parametric4(Double, Double, Double, Double, Double, Double, Double)
    case table([Double])
}

extension iccCurve : ByteCodable {

    init(from data: inout Data) throws {

        guard data.count > 8 else { throw AnyColorSpace.ICCError.endOfData }

        let type = try data.decode(iccProfile.TagType.self)

        data.removeFirst(4)

        switch type {
        case .curve:

            let count = Int(try data.decode(BEUInt32.self))

            switch count {
            case 0: self = .identity
            case 1: self = .gamma(try data.decode(Fixed8Number<BEUInt16>.self).representingValue)
            default:
                var table = [Double]()
                table.reserveCapacity(count)
                for _ in 0..<count {
                    table.append(Double(try data.decode(BEUInt16.self)) / 65535)
                }
                self = .table(table)
            }

        case .parametricCurve:

            let curve = try data.decode(ParametricCurve.self)

            switch curve.funcType {
            case 0: self = .gamma(curve.gamma.representingValue)
            case 1: self = .parametric1(curve.gamma.representingValue, curve.a.representingValue, curve.b.representingValue)
            case 2: self = .parametric2(curve.gamma.representingValue, curve.a.representingValue, curve.b.representingValue, curve.c.representingValue)
            case 3: self = .parametric3(curve.gamma.representingValue, curve.a.representingValue, curve.b.representingValue, curve.c.representingValue, curve.d.representingValue)
            case 4: self = .parametric4(curve.gamma.representingValue, curve.a.representingValue, curve.b.representingValue, curve.c.representingValue, curve.d.representingValue, curve.e.representingValue, curve.f.representingValue)
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid parametricCurve.")
            }

        default: throw AnyColorSpace.ICCError.invalidFormat(message: "Unknown curve type.")
        }
    }

    func write<Target: ByteOutputStream>(to stream: inout Target) {

        switch self {
        case .identity:

            stream.encode(iccProfile.TagType.curve)
            stream.encode(0 as BEUInt32)
            stream.encode(0 as BEUInt32)

        case let .gamma(gamma):

            stream.encode(iccProfile.TagType.parametricCurve)
            stream.encode(0 as BEUInt32)
            stream.encode(ParametricCurve(funcType: 0, gamma: Fixed16Number(gamma), a: 0, b: 0, c: 0, d: 0, e: 0, f: 0))

        case let .parametric1(gamma, a, b):

            stream.encode(iccProfile.TagType.parametricCurve)
            stream.encode(0 as BEUInt32)
            stream.encode(ParametricCurve(funcType: 1, gamma: Fixed16Number(gamma), a: Fixed16Number(a), b: Fixed16Number(b), c: 0, d: 0, e: 0, f: 0))

        case let .parametric2(gamma, a, b, c):

            stream.encode(iccProfile.TagType.parametricCurve)
            stream.encode(0 as BEUInt32)
            stream.encode(ParametricCurve(funcType: 2, gamma: Fixed16Number(gamma), a: Fixed16Number(a), b: Fixed16Number(b), c: Fixed16Number(c), d: 0, e: 0, f: 0))

        case let .parametric3(gamma, a, b, c, d):

            stream.encode(iccProfile.TagType.parametricCurve)
            stream.encode(0 as BEUInt32)
            stream.encode(ParametricCurve(funcType: 3, gamma: Fixed16Number(gamma), a: Fixed16Number(a), b: Fixed16Number(b), c: Fixed16Number(c), d: Fixed16Number(d), e: 0, f: 0))

        case let .parametric4(gamma, a, b, c, d, e, f):

            stream.encode(iccProfile.TagType.parametricCurve)
            stream.encode(0 as BEUInt32)
            stream.encode(ParametricCurve(funcType: 4, gamma: Fixed16Number(gamma), a: Fixed16Number(a), b: Fixed16Number(b), c: Fixed16Number(c), d: Fixed16Number(d), e: Fixed16Number(e), f: Fixed16Number(f)))

        case let .table(points):

            stream.encode(iccProfile.TagType.curve)
            stream.encode(0 as BEUInt32)
            stream.encode(BEUInt32(points.count))
            for point in points {
                stream.encode(BEUInt16((point * 65535).clamped(to: 0...65535)))
            }
        }
    }
}

extension iccCurve {

    struct ParametricCurve : ByteCodable {

        var funcType: BEUInt16
        var padding: BEUInt16
        var gamma: Fixed16Number<BEInt32>
        var a: Fixed16Number<BEInt32>
        var b: Fixed16Number<BEInt32>
        var c: Fixed16Number<BEInt32>
        var d: Fixed16Number<BEInt32>
        var e: Fixed16Number<BEInt32>
        var f: Fixed16Number<BEInt32>

        init(funcType: BEUInt16,
             gamma: Fixed16Number<BEInt32>,
             a: Fixed16Number<BEInt32>,
             b: Fixed16Number<BEInt32>,
             c: Fixed16Number<BEInt32>,
             d: Fixed16Number<BEInt32>,
             e: Fixed16Number<BEInt32>,
             f: Fixed16Number<BEInt32>) {

            self.funcType = funcType
            self.padding = 0
            self.gamma = gamma
            self.a = a
            self.b = b
            self.c = c
            self.d = d
            self.e = e
            self.f = f
        }

        init(from data: inout Data) throws {

            self.funcType = try data.decode(BEUInt16.self)
            self.padding = try data.decode(BEUInt16.self)

            switch funcType {
            case 0:
                self.gamma = try data.decode(Fixed16Number.self)
                self.a = 0
                self.b = 0
                self.c = 0
                self.d = 0
                self.e = 0
                self.f = 0
            case 1:
                self.gamma = try data.decode(Fixed16Number.self)
                self.a = try data.decode(Fixed16Number.self)
                self.b = try data.decode(Fixed16Number.self)
                self.c = 0
                self.d = 0
                self.e = 0
                self.f = 0
            case 2:
                self.gamma = try data.decode(Fixed16Number.self)
                self.a = try data.decode(Fixed16Number.self)
                self.b = try data.decode(Fixed16Number.self)
                self.c = try data.decode(Fixed16Number.self)
                self.d = 0
                self.e = 0
                self.f = 0
            case 3:
                self.gamma = try data.decode(Fixed16Number.self)
                self.a = try data.decode(Fixed16Number.self)
                self.b = try data.decode(Fixed16Number.self)
                self.c = try data.decode(Fixed16Number.self)
                self.d = try data.decode(Fixed16Number.self)
                self.e = 0
                self.f = 0
            case 4:
                self.gamma = try data.decode(Fixed16Number.self)
                self.a = try data.decode(Fixed16Number.self)
                self.b = try data.decode(Fixed16Number.self)
                self.c = try data.decode(Fixed16Number.self)
                self.d = try data.decode(Fixed16Number.self)
                self.e = try data.decode(Fixed16Number.self)
                self.f = try data.decode(Fixed16Number.self)
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid parametricCurve.")
            }
        }

        func write<Target: ByteOutputStream>(to stream: inout Target) {
            switch funcType {
            case 0:
                stream.encode(funcType)
                stream.encode(padding)
                stream.encode(gamma)
            case 1:
                stream.encode(funcType)
                stream.encode(padding)
                stream.encode(gamma)
                stream.encode(a)
                stream.encode(b)
            case 2:
                stream.encode(funcType)
                stream.encode(padding)
                stream.encode(gamma)
                stream.encode(a)
                stream.encode(b)
                stream.encode(c)
            case 3:
                stream.encode(funcType)
                stream.encode(padding)
                stream.encode(gamma)
                stream.encode(a)
                stream.encode(b)
                stream.encode(c)
                stream.encode(d)
            case 4:
                stream.encode(funcType)
                stream.encode(padding)
                stream.encode(gamma)
                stream.encode(a)
                stream.encode(b)
                stream.encode(c)
                stream.encode(d)
                stream.encode(e)
                stream.encode(f)
            default: break
            }
        }
    }
}

extension iccCurve {

    @inlinable
    var inverse: iccCurve {
        switch self {
        case .identity: return .identity
        case let .gamma(gamma): return .gamma(1 / gamma)
        case let .parametric1(gamma, a, b): return iccCurve.parametric4(gamma, a, b, 0, -b / a, 0, 0).inverse
        case let .parametric2(gamma, a, b, c): return iccCurve.parametric4(gamma, a, b, 0, -b / a, c, c).inverse
        case let .parametric3(gamma, a, b, c, d): return iccCurve.parametric4(gamma, a, b, c, d, 0, 0).inverse
        case let .parametric4(gamma, a, b, c, d, e, f):

            let _a = pow(a, -gamma)
            let _b = -e * _a
            let _c = c == 0 ? 0 : 1 / c
            let _d = c * d + f
            let _e = a == 0 ? 0 : -b / a
            let _f = c == 0 ? 0 : -f / c
            return .parametric4(1 / gamma, _a, _b, _c, _d, _e, _f)

        case let .table(points):

            var inversed: [Double] = []
            inversed.reserveCapacity(points.count << 1)

            let N = Double(points.count - 1)

            var hint = 0

            func __interpolate<C : RandomAccessCollection>(_ y: Double, _ points: C) -> Double? where C.Element == Double, C.Index == Int {

                for (lhs, rhs) in zip(points.indexed(), points.dropFirst().indexed()) {
                    let _min: Double
                    let _max: Double
                    let _min_idx: Int
                    let _max_idx: Int
                    if lhs.element <= rhs.element {
                        _min = lhs.element
                        _max = rhs.element
                        _min_idx = lhs.index
                        _max_idx = rhs.index
                    } else {
                        _min = rhs.element
                        _max = lhs.element
                        _min_idx = rhs.index
                        _max_idx = lhs.index
                    }
                    if _min..._max ~= y {
                        hint = lhs.index
                        let m = (y - _min) / (_max - _min)
                        let a = (1 - m) * Double(_min_idx) / N
                        let b = m * Double(_max_idx) / N
                        return a + b
                    }
                }

                return nil
            }

            func _interpolate(_ y: Double) -> Double {

                if y == 0 && points.first?.almostZero() == true {
                    return 0
                } else if y == 1 && points.last?.almostEqual(1) == true {
                    return 1
                }

                if hint != points.count - 1 {
                    if let value = __interpolate(y, points.suffix(from: hint)) {
                        return value
                    }
                }
                if let value = __interpolate(y, points) {
                    return value
                }
                if let idx = points.suffix(from: hint).indexed().min(by: { abs($0.1 - y) })?.0 ?? points.indexed().min(by: { abs($0.1 - y) })?.0 {
                    return Double(idx) / N
                }
                return 0
            }

            let N2 = Double((points.count << 1) - 1)

            for i in 0..<points.count << 1 {
                inversed.append(_interpolate(Double(i) / N2))
            }

            return .table(inversed)
        }
    }
}

extension iccCurve {

    @inlinable
    func eval(_ x: Double) -> Double {

        @inline(__always)
        func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
            return x.sign == .plus ? gamma(x) : -gamma(-x)
        }

        switch self {
        case .identity: return x
        case let .gamma(gamma): return exteneded(x) { pow($0, gamma) }
        case let .parametric1(gamma, a, b):
            return exteneded(x) {
                if $0 < -b / a {
                    return 0
                } else {
                    return pow(a * $0 + b, gamma)
                }
            }
        case let .parametric2(gamma, a, b, c):
            return exteneded(x) {
                if $0 < -b / a {
                    return c
                } else {
                    return pow(a * $0 + b, gamma) + c
                }
            }
        case let .parametric3(gamma, a, b, c, d):
            return exteneded(x) {
                if $0 < d {
                    return c * $0
                } else {
                    return pow(a * $0 + b, gamma)
                }
            }
        case let .parametric4(gamma, a, b, c, d, e, f):
            return exteneded(x) {
                if $0 < d {
                    return c * $0 + f
                } else {
                    return pow(a * $0 + b, gamma) + e
                }
            }
        case let .table(points): return points.withUnsafeBufferPointer { interpolate(x, table: $0) }
        }
    }
}
