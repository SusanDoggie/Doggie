import Foundation
import Doggie

extension Polynomial {
    
    @_inlineable
    public func eval(_ x: Complex) -> Complex {
        return self.reversed().reduce(Complex(0)) { x * $0.0 + $0.1 }
    }
}

public func DurandKerner(_ polynomial: Polynomial, eps: Double = 1e-14) -> [Complex] {
    
    let poly = polynomial / polynomial.last!
    
    var result = (0..<poly.degree).dropFirst().scan(Complex(1)) { $0.0.0 * Complex(real: 0.4, imag: 0.9) }
    
    var _eps = eps
    var iter = 0
    
    while true {
        
        var flag = true
        
        func _eval(_ i: Int, _ x: Complex) -> Complex {
            
            let p = poly.eval(x)
            
            let q = result.prefix(upTo: i).reduce(Complex(1)) { $0.0 * (x - $0.1) }
            let r = result.suffix(from: i + 1).reduce(q) { $0.0 * (x - $0.1) }
            
            if r != Complex(0) {
                
                let s = p / r
                
                if !s.real.almostZero(epsilon: _eps, reference: x.real) || !s.imag.almostZero(epsilon: _eps, reference: x.imag) {
                    flag = false
                }
                
                return s
            }
            
            return Complex(0)
        }
        
        result = result.enumerated().map { $0.1 - _eval($0.0, $0.1) }
        
        if flag {
            print("DurandKerner:", iter)
            break
        }
        
        iter += 1
        if iter % 5000 == 0 {
            _eps *= 2
        }
    }
    
    return result
}
