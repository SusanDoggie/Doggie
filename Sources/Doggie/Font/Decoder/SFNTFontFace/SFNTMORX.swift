//
//  SFNTMORX.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

struct SFNTMORX {
    
    var version: BEUInt16
    var unused: BEUInt16
    var nChains: BEUInt32
    
    var data: Data
    
    init(_ data: Data) throws {
        
        var data = data
        
        self.version = try data.decode(BEUInt16.self)
        self.unused = try data.decode(BEUInt16.self)
        self.nChains = try data.decode(BEUInt32.self)
        self.data = data
        
//        self.forEach {
//            
//            print("defaultFlags:", $0.defaultFlags)
//            print("chainLength:", $0.chainLength)
//            print("nFeatureEntries:", $0.nFeatureEntries)
//            print("nSubtables:", $0.nSubtables)
//            
//            return true
//        }
    }
}

extension SFNTMORX {
    
    func forEach(_ body: (Chain) -> Bool) {
        
        var data = self.data
        
        for _ in 0..<Int(nChains) {
            
            guard let defaultFlags = try? data.decode(BEUInt32.self) else { return }
            guard let chainLength = try? data.decode(BEUInt32.self) else { return }
            guard let nFeatureEntries = try? data.decode(BEUInt32.self) else { return }
            guard let nSubtables = try? data.decode(BEUInt32.self) else { return }
            
            let _data = data.popFirst(Int(chainLength) - 16)
            
            guard _data.count + 16 == chainLength else { return }
            
            let chain = Chain(defaultFlags: defaultFlags, chainLength: chainLength, nFeatureEntries: nFeatureEntries, nSubtables: nSubtables, data: _data)
            
            guard body(chain) else { return }
        }
    }
}

extension SFNTMORX {
    
    struct Chain {
        
        var defaultFlags: BEUInt32
        var chainLength: BEUInt32
        var nFeatureEntries: BEUInt32
        var nSubtables: BEUInt32
        
        var data: Data
    }
}
