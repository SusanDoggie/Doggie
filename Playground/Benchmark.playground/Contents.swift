//: Playground - noun: a place where people can play

import Cocoa
import Doggie

for n in 2...20 {
    
    let t1 = HalfRadix2CooleyTukey_Benchmark(n)
    let t2 = RealRadix2CooleyTukey_Benchmark(n)
    
    print("\(n) | \(t1) | \(t2)")
}


for n in 2...20 {
    
    let t1 = Radix2CooleyTukey_OutPlace_Benchmark(n)
    let t2 = Radix2CooleyTukey_InPlace_Benchmark(n)
    
    print("\(n) | \(t1) | \(t2)")
}

