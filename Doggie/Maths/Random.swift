//
//  Random.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

@warn_unused_result
public func normal_distribution(mean mean: Double, variance: Double) -> Double {
    let u: Double = 1 - random(0.0..<1.0)
    let v: Double = 1 - random(0.0..<1.0)
    
    let r: Double = -2 * log(u)
    let theta: Double = 2 * M_PI * v
    
    return sqrt(variance * r) * cos(theta) + mean
}
@warn_unused_result
public func normal_distribution(mean mean: Complex, variance: Double) -> Complex {
    let u: Double = 1 - random(0.0..<1.0)
    let v: Double = 1 - random(0.0..<1.0)
    
    let r: Double = -2 * log(u)
    let theta: Double = 2 * M_PI * v
    
    return polar(rho: sqrt(variance * r), theta: theta) + mean
}
