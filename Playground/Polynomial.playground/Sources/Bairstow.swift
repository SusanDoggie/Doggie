import Foundation
import Doggie

private func Bairstow(_ poly: Polynomial, eps: Double = 1e-14) -> [(Double, Double?)] {
    
    switch poly.degree {
    case 2: return [(poly[0], poly[1])]
    case 3:
        let decompose = degree3decompose(poly[2], poly[1], poly[0])
        return [(decompose.0, nil), (decompose.1.1, decompose.1.0)]
        
    case 4:
        let decompose = degree4decompose(poly[3], poly[2], poly[1], poly[0])
        return [(decompose.0.1, decompose.0.0), (decompose.1.1, decompose.1.0)]
        
    default:
        
        var eps = eps
        var iter = 0
        
        var r = poly[poly.count - 2].almostZero(reference: poly[poly.count - 3]) ? poly[poly.count - 3] : poly[poly.count - 3] / poly[poly.count - 2]
        var s = poly[poly.count - 2].almostZero(reference: poly[poly.count - 4]) ? poly[poly.count - 4] : poly[poly.count - 4] / poly[poly.count - 2]
        
        func reduce(_ p: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double) -> (Double, Double, Double, Double, Double, Double) {
            let u = p - r * b - s * a
            let v = u - r * f - s * e
            return (b, u, d, e, f, v)
        }
        
        while true {
            
            let (g, h, i, j, k, _) = poly.dropLast().reversed().reduce((0, 1, 0, 0, 0, 1)) { reduce($1, $0.0, $0.1, $0.2, $0.3, $0.4, $0.5) }
            
            let d = k * i - j * j
            
            if d == 0 {
                return Bairstow(poly / [s, r, 1], eps: eps) + [(s, r)]
            }
            
            let dr = (h * i - g * j) / d
            let ds = (g * k - h * j) / d
            
            r += dr
            s += ds
            
            if dr.almostZero(epsilon: eps, reference: r) && ds.almostZero(epsilon: eps, reference: s) {
                return Bairstow(poly / [s, r, 1], eps: eps) + [(s, r)]
            }
            
            iter += 1
            if iter % 5000 == 0 {
                eps *= 2
            }
        }
    }
}

public func roots(_ polynomial: Polynomial, eps: Double = 1e-14) -> [Double] {
    
    var result: [Double] = []
    result.reserveCapacity(polynomial.degree)
    
    for (s, r) in Bairstow(polynomial / polynomial.last!, eps: eps) {
        if let r = r {
            result.append(contentsOf: degree2roots(r, s))
        } else {
            result.append(s)
        }
    }
    
    return result
}

public func test1(_ polynomial: Polynomial) -> Double {
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        let _roots = polynomial.roots
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}

public func test2(_ polynomial: Polynomial, eps: Double = 1e-14) -> Double {
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        let _roots = roots(polynomial, eps: eps)
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
