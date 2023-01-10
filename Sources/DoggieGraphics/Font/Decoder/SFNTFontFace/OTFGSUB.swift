//
//  OTFGSUB.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

struct OTFGSUB: ByteDecodable {
    
    var version: Fixed16Number<BEInt32>
    var scriptListOffset: BEUInt16
    var featureListOffset: BEUInt16
    var lookupListOffset: BEUInt16
    
    var scriptList: OTFScriptList
    var featureList: OTFFeatureList
    var lookupList: OTFLookupList
    
    init(from data: inout Data) throws {
        let copy = data
        self.version = try data.decode(Fixed16Number<BEInt32>.self)
        self.scriptListOffset = try data.decode(BEUInt16.self)
        self.featureListOffset = try data.decode(BEUInt16.self)
        self.lookupListOffset = try data.decode(BEUInt16.self)
        self.scriptList = try OTFScriptList(copy.dropFirst(Int(scriptListOffset)))
        self.featureList = try OTFFeatureList(copy.dropFirst(Int(featureListOffset)))
        self.lookupList = try OTFLookupList(copy.dropFirst(Int(lookupListOffset)))
    }
}

