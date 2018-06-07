//
//  BezierArc.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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
let BezierCircle: [Point] = {
    
    //
    // root of 18225 x^12 + 466560 x^11 - 28977264 x^10 + 63288000 x^9 + 96817248 x^8
    //         - 515232000 x^7 + 883891456 x^6 - 921504768 x^5 + 668905728 x^4
    //         - 342814720 x^3 + 117129216 x^2 - 23592960 x + 2097152
    // reference: http://spencermortensen.com/articles/bezier-circle/
    //
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    return [
        Point(x: 1, y: 0),
        Point(x: 1, y: c),
        Point(x: c, y: 1),
        Point(x: 0, y: 1),
        Point(x: -c, y: 1),
        Point(x: -1, y: c),
        Point(x: -1, y: 0),
        Point(x: -1, y: -c),
        Point(x: -c, y: -1),
        Point(x: 0, y: -1),
        Point(x: c, y: -1),
        Point(x: 1, y: -c),
        Point(x: 1, y: 0)
    ]
}()

@inlinable
public func BezierArc(_ angle: Double) -> [Point] {
    
    //
    // root of 18225 x^12 + 466560 x^11 - 28977264 x^10 + 63288000 x^9 + 96817248 x^8
    //         - 515232000 x^7 + 883891456 x^6 - 921504768 x^5 + 668905728 x^4
    //         - 342814720 x^3 + 117129216 x^2 - 23592960 x + 2097152
    // reference: http://spencermortensen.com/articles/bezier-circle/
    //
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    var counter = 0
    var _angle = abs(angle)
    var result = [Point(x: 1, y: 0)]
    
    while _angle > 0 && !_angle.almostZero() {
        switch counter & 3 {
        case 0:
            result.append(Point(x: 1, y: c))
            result.append(Point(x: c, y: 1))
            result.append(Point(x: 0, y: 1))
        case 1:
            result.append(Point(x: -c, y: 1))
            result.append(Point(x: -1, y: c))
            result.append(Point(x: -1, y: 0))
        case 2:
            result.append(Point(x: -1, y: -c))
            result.append(Point(x: -c, y: -1))
            result.append(Point(x: 0, y: -1))
        case 3:
            result.append(Point(x: c, y: -1))
            result.append(Point(x: 1, y: -c))
            result.append(Point(x: 1, y: 0))
        default: break
        }
        if _angle < 0.5 * Double.pi {
            let offset = Double(counter & 3) * 0.5 * Double.pi
            let s = _angle + offset
            let _a = result.count - 4
            let _b = result.count - 3
            let _c = result.count - 2
            let _d = result.count - 1
            let end = Point(x: cos(s), y: sin(s))
            let t = Bezier(result[_a], result[_b], result[_c], result[_d]).closest(end).first!
            let split = Bezier(result[_a], result[_b], result[_c], result[_d]).split(t).0
            result[_b] = split[1]
            result[_c] = split[2]
            result[_d] = end
        }
        _angle -= 0.5 * Double.pi
        counter += 1
    }
    return angle.sign == .minus ? result.map { Point(x: $0.x, y: -$0.y) } : result
}
