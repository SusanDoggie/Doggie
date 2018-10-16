
import Foundation
import Doggie


public func HalfRadix2CooleyTukey_Benchmark(_ n: Int) -> Double {
    
    let real = [Double](repeating: 0.0, count: 1 << n)
    var _real = [Double](repeating: 0.0, count: 1 << (n - 1))
    var _imag = [Double](repeating: 0.0, count: 1 << (n - 1))
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        HalfRadix2CooleyTukey(n, real, 1, 1 << n, &_real, &_imag, 1)
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
public func RealRadix2CooleyTukey_Benchmark(_ n: Int) -> Double {
    
    let real = [Double](repeating: 0.0, count: 1 << n)
    var _real = [Double](repeating: 0.0, count: 1 << n)
    var _imag = [Double](repeating: 0.0, count: 1 << n)
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        Radix2CooleyTukey(n, real, 1, 1 << n, &_real, &_imag, 1)
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}

public func Radix2CooleyTukey_OutPlace_Benchmark(_ n: Int) -> Double {
    
    let real = [Double](repeating: 0.0, count: 1 << n)
    let imag = [Double](repeating: 0.0, count: 1 << n)
    var _real = [Double](repeating: 0.0, count: 1 << n)
    var _imag = [Double](repeating: 0.0, count: 1 << n)
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        Radix2CooleyTukey(n, real, imag, 1, 1 << n, &_real, &_imag, 1)
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}

public func Radix2CooleyTukey_InPlace_Benchmark(_ n: Int) -> Double {
    
    var real = [Double](repeating: 0.0, count: 1 << n)
    var imag = [Double](repeating: 0.0, count: 1 << n)
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        Radix2CooleyTukey(n, &real, &imag, 1)
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
