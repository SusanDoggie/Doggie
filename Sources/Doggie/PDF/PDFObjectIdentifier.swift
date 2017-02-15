//
//  PDFObjectIdentifier.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

extension PDFDocument {
    
    public struct ObjectIdentifier {
        
        public var identifier: Int
        public var generation: Int
        
        public init(identifier: Int, generation: Int) {
            self.identifier = identifier
            self.generation = generation
        }
    }
}

extension PDFDocument.ObjectIdentifier : Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, identifier, generation)
    }
}

public func ==(lhs: PDFDocument.ObjectIdentifier, rhs: PDFDocument.ObjectIdentifier) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.generation == rhs.generation
}
