//: Playground - noun: a place where people can play

import Cocoa
import Doggie

for n in 2...20 {
    
    let t1 = HalfRadix2CooleyTukey_OutPlace_Benchmark(n)
    let t2 = HalfRadix2CooleyTukey_InPlace_Benchmark(n)
    let t3 = RealRadix2CooleyTukey_Benchmark(n)
    let t4 = vDSP_fft_zropD_Benchmark(n)
    let t5 = vDSP_fft_zripD_Benchmark(n)
    
    print("\(n) | \(t1) | \(t2) | \(t3) | \(t4) | \(t5)")
}


for n in 2...20 {
    
    let t1 = Radix2CooleyTukey_OutPlace_Benchmark(n)
    let t2 = Radix2CooleyTukey_InPlace_Benchmark(n)
    let t3 = vDSP_fft_zopD_Benchmark(n)
    let t4 = vDSP_fft_zipD_Benchmark(n)
    
    print("\(n) | \(t1) | \(t2) | \(t3) | \(t4)")
}

