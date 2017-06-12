import Foundation
import Doggie

private func _Bairstow(_ poly: Polynomial, eps: Double = 1e-14) -> [(Double, Double?)] {
    
    switch poly.degree {
    case 2: return [(poly[0], poly[1])]
    case 3:
        let decompose = degree3decompose(poly[2], poly[1], poly[0])
        return [(decompose.0, nil), (decompose.1.1, decompose.1.0)]
        
    case 4:
        let decompose = degree4decompose(poly[3], poly[2], poly[1], poly[0])
        return [(decompose.0.1, decompose.0.0), (decompose.1.1, decompose.1.0)]
        
    default:
        
        var _eps = eps
        var iter = 0
        
        var r = poly[poly.count - 2].almostZero(reference: poly[poly.count - 3]) ? poly[poly.count - 3] : poly[poly.count - 3] / poly[poly.count - 2]
        var s = poly[poly.count - 2].almostZero(reference: poly[poly.count - 4]) ? poly[poly.count - 4] : poly[poly.count - 4] / poly[poly.count - 2]
        
        func reduce(_ p: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double, _ e: Double) -> (Double, Double, Double, Double, Double) {
            let v = b - r * e - s * d
            let u = p - r * b - s * a
            return (b, u, d, e, v)
        }
        
        while true {
            
            let (g, h, i, j, k) = poly.dropLast().reversed().reduce((0, 1, 0, 0, 0)) { reduce($1, $0.0, $0.1, $0.2, $0.3, $0.4) }
            
            let d = k * i - j * j
            
            if d == 0 {
                return _Bairstow(poly / [s, r, 1], eps: eps) + [(s, r)]
            }
            
            let dr = (h * i - g * j) / d
            let ds = (g * k - h * j) / d
            
            r += dr
            s += ds
            
            if dr.almostZero(epsilon: _eps, reference: r) && ds.almostZero(epsilon: _eps, reference: s) {
                return _Bairstow(poly / [s, r, 1], eps: eps) + [(s, r)]
            }
            
            iter += 1
            if iter % 5000 == 0 {
                _eps *= 2
            }
        }
    }
}

public func Bairstow(_ polynomial: Polynomial, eps: Double = 1e-14) -> [Double] {
    
    var result: [Double] = []
    result.reserveCapacity(polynomial.degree)
    
    for (s, r) in _Bairstow(polynomial / polynomial.last!, eps: eps) {
        if let r = r {
            result.append(contentsOf: degree2roots(r, s))
        } else {
            result.append(s)
        }
    }
    
    return result
}
