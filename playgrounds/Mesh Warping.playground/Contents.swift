//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import PlaygroundSupport

private func BezierInflection(_ p: [Point]) -> [Double] {
    switch p.count {
    case 0, 1, 2, 3: return []
    case 4: return CubicBezierInflection(p[0], p[1], p[2], p[3])
    default:
        let x = Polynomial(Bezier(p.map { $0.x })).derivative
        let y = Polynomial(Bezier(p.map { $0.y })).derivative
        return (x * y.derivative - y * x.derivative).roots
    }
}
private func QuadBezierFitting(_ p: [Point], _ limit: Int, _ inflection_check: Bool) -> [[Point]] {
    
    if inflection_check {
        return Bezier(p).split(BezierInflection(p)).flatMap { QuadBezierFitting(Array($0), limit - 1, false) }
    }
    
    
    return [p]
}
public func QuadBezierFitting(_ p: [Point]) -> [[Point]] {
    
    return QuadBezierFitting(p, 8, true)
}

public func CoonsPatch(_ m00: Point, _ m01: Point, _ m02: Point, _ m03: Point,
                       _ m10: Point, _ m13: Point, _ m20: Point, _ m23: Point,
                       _ m30: Point, _ m31: Point, _ m32: Point, _ m33: Point,
                       _ p: Point ... ) -> [[Point]] {
    
    let u = Polynomial(Bezier(p.map { $0.x }))
    let v = Polynomial(Bezier(p.map { $0.y }))
    let u2 = u * u
    let v2 = v * v
    let u3 = u2 * u
    let v3 = v2 * v
    
    let _u = 1 - u
    let _v = 1 - v
    let _u2 = _u * _u
    let _v2 = _v * _v
    let _u3 = _u2 * _u
    let _v3 = _v2 * _v
    
    let bx = (m00.x * _u + m03.x * u) * _v + (m30.x * _u + m33.x * u) * v
    let by = (m00.y * _u + m03.y * u) * _v + (m30.y * _u + m33.y * u) * v
    
    let c0x = _u3 * m00.x + 3 * _u2 * u * m01.x + 3 * _u * u2 * m02.x + u3 * m03.x
    let c0y = _u3 * m00.y + 3 * _u2 * u * m01.y + 3 * _u * u2 * m02.y + u3 * m03.y
    let c1x = _u3 * m30.x + 3 * _u2 * u * m31.x + 3 * _u * u2 * m32.x + u3 * m33.x
    let c1y = _u3 * m30.y + 3 * _u2 * u * m31.y + 3 * _u * u2 * m32.y + u3 * m33.y
    let c2x = _v3 * m00.x + 3 * _v2 * v * m10.x + 3 * _v * v2 * m20.x + v3 * m30.x
    let c2y = _v3 * m00.y + 3 * _v2 * v * m10.y + 3 * _v * v2 * m20.y + v3 * m30.y
    let c3x = _v3 * m03.x + 3 * _v2 * v * m13.x + 3 * _v * v2 * m23.x + v3 * m33.x
    let c3y = _v3 * m03.y + 3 * _v2 * v * m13.y + 3 * _v * v2 * m23.y + v3 * m33.y
    
    let d0x = _v * c0x + v * c1x
    let d0y = _v * c0y + v * c1y
    let d1x = _u * c2x + u * c3x
    let d1y = _u * c2y + u * c3y
    
    var x = (d0x + d1x - bx).bezier
    var y = (d0y + d1y - by).bezier
    
    let degree = max(x.degree, y.degree)
    
    while x.degree != degree {
        x = x.elevated()
    }
    while y.degree != degree {
        y = y.elevated()
    }
    
    let points = zip(x, y).map { Point(x: $0, y: $1) }
    
    switch degree {
    case 1, 2, 3: return [points]
    default: return QuadBezierFitting(points)
    }
}

class _CoonsPatchView: CoonsPatchView {
    
    override func implement() -> SDPath? {
        
        if let shape = shape?.path {
            
            var path: [SDPath.Command] = []
            var flag = true
            
            path.reserveCapacity(shape.count)
            
            shape.identity.apply { commands, state in
                
                func addCurves(_ points: [[Point]]) {
                    if let first = points.first {
                        if flag {
                            path.append(.move(first[0]))
                            flag = false
                        }
                        for p in points {
                            switch p.count {
                            case 2: path.append(.line(p[1]))
                            case 3: path.append(.quad(p[1], p[2]))
                            case 4: path.append(.cubic(p[1], p[2], p[3]))
                            default: break
                            }
                        }
                    }
                }
                
                switch commands {
                case .move: flag = true
                case .close:
                    let z = state.start - state.last
                    if !z.x.almostZero() || !z.y.almostZero() {
                        addCurves(CoonsPatch(self.p0, self.p4, self.p5, self.p1, self.p6, self.p8, self.p7, self.p9, self.p2, self.p10, self.p11, self.p3, state.last, state.start))
                    }
                    if !flag {
                        path.append(.close)
                        flag = true
                    }
                case let .line(p1): addCurves(CoonsPatch(self.p0, self.p4, self.p5, self.p1, self.p6, self.p8, self.p7, self.p9, self.p2, self.p10, self.p11, self.p3, state.last, p1))
                case let .quad(p1, p2): addCurves(CoonsPatch(self.p0, self.p4, self.p5, self.p1, self.p6, self.p8, self.p7, self.p9, self.p2, self.p10, self.p11, self.p3, state.last, p1, p2))
                case let .cubic(p1, p2, p3): addCurves(CoonsPatch(self.p0, self.p4, self.p5, self.p1, self.p6, self.p8, self.p7, self.p9, self.p2, self.p10, self.p11, self.p3, state.last, p1, p2, p3))
                }
            }
            
            return SDPath(path)
        }
        
        return nil
    }
}

let CoonsPatch = _CoonsPatchView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

PlaygroundPage.current.liveView = CoonsPatch

var square = SDRectangle(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
//square.rotate = M_PI_4

CoonsPatch.shape = square

//let ellipse = SDEllipse(x: 240, y: 160, radius: 120)
//
//CoonsPatch.shape = ellipse
