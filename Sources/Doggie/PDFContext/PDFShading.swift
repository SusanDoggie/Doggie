//
//  PDFShading.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

struct PDFShading : Hashable {
    
    var type: Int
    
    var is_clip: Bool
    
    var coords: [Double]
    var function: PDFFunction
    var e0: Bool
    var e1: Bool
}

struct PDFFunction : Hashable {
    
    var type: Int
    var domain: ClosedRange<Double>
    
    var functions: [PDFFunction]
    var bounds: [Double]
    var encode: [Double]
    
    var c0: [Double]
    var c1: [Double]
    var n: Double
}

extension PDFFunction {
    
    init(domain: ClosedRange<Double> = 0...1, c0: [Double], c1: [Double], n: Double = 1) {
        self.type = 2
        self.domain = domain
        self.functions = []
        self.bounds = []
        self.encode = []
        self.c0 = c0
        self.c1 = c1
        self.n = n
    }
    
    init(domain: ClosedRange<Double> = 0...1, functions: [PDFFunction], bounds: [Double], encode: [Double]) {
        self.type = 3
        self.domain = domain
        self.functions = functions
        self.bounds = bounds
        self.encode = encode
        self.c0 = []
        self.c1 = []
        self.n = 0
    }
}

extension PDFFunction {
    
    var pdf_object: PDFDictionary {
        
        switch type {
        case 2: return [
            "FunctionType": 2 as PDFNumber,
            "Domain": [PDFNumber(domain.lowerBound), PDFNumber(domain.upperBound)] as PDFArray,
            "C0": PDFArray(c0.map { PDFNumber($0) }),
            "C1": PDFArray(c1.map { PDFNumber($0) }),
            "N": PDFNumber(n),
            ]
        case 3: return [
            "FunctionType": 3 as PDFNumber,
            "Domain": [PDFNumber(domain.lowerBound), PDFNumber(domain.upperBound)] as PDFArray,
            "Functions": PDFArray(functions.map { $0.pdf_object }),
            "Bounds": PDFArray(bounds.map { PDFNumber($0) }),
            "Encode": PDFArray(encode.map { PDFNumber($0) }),
            ]
        default: return [:]
        }
    }
}
