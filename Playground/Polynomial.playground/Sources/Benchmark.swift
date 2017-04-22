import Foundation
import Doggie

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
        
        let _roots = Bairstow(polynomial, eps: eps)
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
