import Foundation
import Doggie

public func Aberth(_ polynomial: Polynomial, eps: Double = 1e-14) -> [Complex] {
    
    var result = (0..<polynomial.degree).dropFirst().scan(Complex(1)) { $0.0 * Complex(real: 0.4, imag: 0.9) }
    
    let derivative = polynomial.derivative
    
    var _eps = eps
    var iter = 0
    
    while true {
        
        var flag = true
        
        func _eval(_ i: Int, _ x: Complex) -> Complex {
            
            let p = polynomial.eval(x)
            let q = derivative.eval(x)
            
            let r = result.prefix(upTo: i).reduce(Complex(0)) { $0 + 1 / (x - $1) }
            let s = result.suffix(from: i + 1).reduce(r) { $0 + 1 / (x - $1) }
            
            let t = p / q
            
            let u = t / (1 - t * s)
            
            if !u.real.almostZero(epsilon: _eps, reference: x.real) || !u.imag.almostZero(epsilon: _eps, reference: x.imag) {
                flag = false
            }
            
            return u
        }
        
        result = result.enumerated().map { $1 - _eval($0, $1) }
        
        if flag {
            print("Aberth:", iter)
            break
        }
        
        iter += 1
        if iter % 5000 == 0 {
            _eps *= 2
        }
    }
    
    return result
}
