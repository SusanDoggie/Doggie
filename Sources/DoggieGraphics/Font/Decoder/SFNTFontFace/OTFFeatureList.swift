//
//  OTFFeatureList.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

struct OTFFeatureList: ByteDecodable {
    
    var featureCount: BEUInt16
    var records: [Record]
    
    init(from data: inout Data) throws {
        let copy = data
        self.featureCount = try data.decode(BEUInt16.self)
        self.records = []
        self.records.reserveCapacity(Int(featureCount))
        for _ in 0..<Int(featureCount) {
            let featureTag = try data.decode(Signature<BEUInt32>.self)
            let featureOffset = try data.decode(BEUInt16.self)
            
            var record = copy.dropFirst(Int(featureOffset))
            
            let featureParams = try record.decode(BEUInt16.self)
            let lookupIndexCount = try record.decode(BEUInt16.self)
            let lookupListIndices = try (0..<Int(lookupIndexCount)).map { _ in try record.decode(BEUInt16.self) }
            
            self.records.append(Record(featureTag: featureTag, featureParams: featureParams, lookupIndexCount: lookupIndexCount, lookupListIndices: lookupListIndices))
        }
    }
    
    struct Record {
        
        var featureTag: Signature<BEUInt32>
        
        var featureParams: BEUInt16
        var lookupIndexCount: BEUInt16
        var lookupListIndices: [BEUInt16]
        
    }
}
