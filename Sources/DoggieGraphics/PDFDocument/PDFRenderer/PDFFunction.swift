//
//  PDFFunction.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

public struct PDFFunction: Hashable {
    
    public let type: Int
    public let domain: [ClosedRange<Double>]
    
    let functions: [PDFFunction]
    let bounds: [Double]
    let encode: [Encode]
    
    let c0: [Double]
    let c1: [Double]
    let exponent: Double
    
    public let range: [ClosedRange<Double>]
    public let postscript: String
}

extension PDFFunction {
    
    public struct Encode: Hashable {
        
        public var t0: Double
        public var t1: Double
        
        public init(_ t0: Double, _ t1: Double) {
            self.t0 = t0
            self.t1 = t1
        }
    }
}

extension PDFFunction {
    
    public init(domain: ClosedRange<Double> = 0...1, c0: [Double], c1: [Double], exponent: Double = 1) {
        self.type = 2
        self.domain = [domain]
        self.functions = []
        self.bounds = []
        self.encode = []
        self.c0 = c0
        self.c1 = c1
        self.exponent = exponent
        self.range = []
        self.postscript = ""
    }
    
    public init(domain: ClosedRange<Double> = 0...1, functions: [PDFFunction], bounds: [Double], encode: [Encode]) {
        self.type = 3
        self.domain = [domain]
        self.functions = functions
        self.bounds = bounds
        self.encode = encode
        self.c0 = []
        self.c1 = []
        self.exponent = 0
        self.range = []
        self.postscript = ""
    }
    
    public init(domain: [ClosedRange<Double>], range: [ClosedRange<Double>], postscript: String) {
        self.type = 4
        self.domain = domain
        self.functions = []
        self.bounds = []
        self.encode = []
        self.c0 = []
        self.c1 = []
        self.exponent = 0
        self.range = range
        self.postscript = postscript
    }
}

extension PDFFunction {
    
    init?(_ object: PDFObject) {
        
        guard let type = object["FunctionType"].intValue else { return nil }
        guard let _domain = object["Domain"].array?.compactMap({ $0.doubleValue }), _domain.count & 1 == 0 else { return nil }
        
        let domain = _domain.chunked(by: 2)
        guard domain.allSatisfy({ $0.first! <= $0.last! }) else { return nil }
        
        self.type = type
        self.domain = domain.map { $0.first!...$0.last! }
        
        switch type {
            
        case 2:
            
            guard self.domain.count == 1 else { return nil }
            
            guard let n = object["N"].doubleValue else { return nil }
            let c0 = object["C0"].array?.compactMap { $0.doubleValue } ?? [0]
            let c1 = object["C1"].array?.compactMap { $0.doubleValue } ?? [1]
            
            self.exponent = n
            self.c0 = c0
            self.c1 = c1
            
            self.functions = []
            self.bounds = []
            self.encode = []
            self.range = []
            self.postscript = ""
            
        case 3:
            
            guard self.domain.count == 1 else { return nil }
            let domain = self.domain[0]
            
            guard let functions = object["Functions"].array?.compactMap({ PDFFunction($0) }) else { return nil }
            guard let bounds = object["Bounds"].array?.compactMap({ $0.doubleValue }) else { return nil }
            guard let encode = object["Encode"].array?.compactMap({ $0.doubleValue }) else { return nil }
            
            guard functions.allSatisfy({ $0.domain.count == 1 }) else { return nil }
            guard bounds.count + 1 == functions.count else { return nil }
            guard encode.count == functions.count * 2 else { return nil }
            
            guard zip(bounds, bounds.dropFirst()).allSatisfy({ $0 <= $1 }) else { return nil }
            guard bounds.allSatisfy({ domain ~= $0 }) else { return nil }
            
            self.functions = functions
            self.bounds = bounds
            self.encode = encode.chunked(by: 2).map { Encode($0.first!, $0.last!) }
            
            self.c0 = []
            self.c1 = []
            self.exponent = 0
            self.range = []
            self.postscript = ""
            
        default: return nil
        }
    }
}

extension PDFFunction {
    
    var pdf_object: PDFObject {
        
        switch type {
        case 2:
            
            return [
                "FunctionType": 2,
                "Domain": PDFObject(domain.flatMap { [$0.lowerBound, $0.upperBound] }),
                "C0": PDFObject(c0),
                "C1": PDFObject(c1),
                "N": PDFObject(exponent),
            ]
            
        case 3:
            
            return [
                "FunctionType": 3,
                "Domain": PDFObject(domain.flatMap { [$0.lowerBound, $0.upperBound] }),
                "Functions": PDFObject(functions.map { $0.pdf_object }),
                "Bounds": PDFObject(bounds),
                "Encode": PDFObject(encode.flatMap { [$0.t0, $0.t1] }),
            ]
            
        case 4:
            
            return PDFObject([
                "FunctionType": 4,
                "Domain": PDFObject(domain.flatMap { [$0.lowerBound, $0.upperBound] }),
                "Range": PDFObject(range.flatMap { [$0.lowerBound, $0.upperBound] }),
            ], postscript._utf8_data)
            
        default: return [:]
        }
    }
}
