//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let dataFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.negativeFormat = "#.##"
    formatter.positiveFormat = "#.##"
    return formatter
}()

func Radix2CooleyTukey(_ level: Int, _ real: UnsafeMutablePointer<Double>, _ imag: UnsafeMutablePointer<Double>, _ stride: Int) {
    
    switch level {
        
    case 0: break
        
    default:
        let count = 1 << level
        
        let offset = UIntMax(MemoryLayout<UIntMax>.size << 3) - log2(UIntMax(count))
        
        for i in 1..<count >> 1 {
            let _i = Int(UIntMax(i).reverse >> offset)
            if i != _i {
                swap(&real[i * stride], &real[_i * stride])
                swap(&imag[i * stride], &imag[_i * stride])
            }
        }
        
        for s in 0..<level {
            
            let m = 2 << s
            let n = 1 << s
            
            let angle = -Double.pi / Double(n)
            let _cos = cos(angle)
            let _sin = sin(angle)
            
            let m_stride = m * stride
            let n_stride = n * stride
            
            var r1 = real
            var i1 = imag
            
            for _ in Swift.stride(from: 0, to: count, by: m) {
                
                var _cos1 = 1.0
                var _sin1 = 0.0
                
                var _r1 = r1
                var _i1 = i1
                var _r2 = r1 + n_stride
                var _i2 = i1 + n_stride
                
                for _ in 0..<n {
                    
                    let ur = _r1.pointee
                    let ui = _i1.pointee
                    let vr = _r2.pointee
                    let vi = _i2.pointee
                    
                    let vrc = vr * _cos1
                    let vic = vi * _cos1
                    let vrs = vr * _sin1
                    let vis = vi * _sin1
                    
                    let _c = _cos * _cos1 - _sin * _sin1
                    let _s = _cos * _sin1 + _sin * _cos1
                    _cos1 = _c
                    _sin1 = _s
                    
                    _r1.pointee = ur + vrc - vis
                    _i1.pointee = ui + vrs + vic
                    _r2.pointee = ur - vrc + vis
                    _i2.pointee = ui - vrs - vic
                    
                    _r1 += stride
                    _i1 += stride
                    _r2 += stride
                    _i2 += stride
                }
                
                r1 += m_stride
                i1 += m_stride
            }
        }
    }
}

let n = 4

var sample = [Double](repeating: 0, count: 2 << n)
var result = [Double](repeating: 0, count: 2 << n)

for i in 0..<1 << n {
    sample[i * 2] = Double(i)
}

sample.withUnsafeBufferPointer { sample in
    result.withUnsafeMutableBufferPointer { result in
        Radix2CooleyTukey(n, sample.baseAddress!, sample.baseAddress! + 1, 2, 1 << n, result.baseAddress!, result.baseAddress! + 1, 2)
    }
}

let a = result.enumerated().filter { $0.0 & 1 == 0 }.map { dataFormatter.string(from: NSNumber(value: $0.1))! }.joined(separator: ", ")
let b = result.enumerated().filter { $0.0 & 1 == 1 }.map { dataFormatter.string(from: NSNumber(value: $0.1))! }.joined(separator: ", ")

result = sample

result.withUnsafeMutableBufferPointer { result in
    Radix2CooleyTukey(n, result.baseAddress!, result.baseAddress! + 1, 2)
}

let c = result.enumerated().filter { $0.0 & 1 == 0 }.map { dataFormatter.string(from: NSNumber(value: $0.1))! }.joined(separator: ", ")
let d = result.enumerated().filter { $0.0 & 1 == 1 }.map { dataFormatter.string(from: NSNumber(value: $0.1))! }.joined(separator: ", ")

print(a)
print(c)
print(b)
print(d)


