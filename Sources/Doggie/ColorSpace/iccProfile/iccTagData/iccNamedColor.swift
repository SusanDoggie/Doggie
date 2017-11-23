//
//  iccNamedColor.swift
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

import Foundation

@_versioned
@_fixed_layout
struct iccNamedColor : ByteDecodable {
    
    @_versioned
    var flag: BEUInt32
    
    @_versioned
    var prefix: String
    
    @_versioned
    var suffix: String
    
    @_versioned
    var named: [String] = []
    
    @_versioned
    var pcs: [(Double, Double, Double)] = []
    
    @_versioned
    var device: [Double] = []
    
    init(from data: inout Data) throws {
        
        guard data.count > 8 else { throw AnyColorSpace.ICCError.endOfData }
        
        guard try data.decode(iccProfile.TagType.self) == .namedColor2 else { throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid namedColor2.") }
        
        data.removeFirst(4)
        
        self.flag = try data.decode(BEUInt32.self)
        
        let count = Int(try data.decode(BEUInt32.self))
        let deviceCoords = Int(try data.decode(BEUInt32.self))
        
        let _prefix = data.popFirst(32)
        let _suffix = data.popFirst(32)
        
        guard _prefix.count == 32 else { throw AnyColorSpace.ICCError.endOfData }
        guard _suffix.count == 32 else { throw AnyColorSpace.ICCError.endOfData }
        
        self.prefix = String(bytes: _prefix, encoding: .ascii) ?? ""
        self.suffix = String(bytes: _suffix, encoding: .ascii) ?? ""
        
        self.named.reserveCapacity(count)
        self.pcs.reserveCapacity(count)
        self.device.reserveCapacity(count * deviceCoords)
        
        for _ in 0..<count {
            
            let _named = data.popFirst(32)
            
            guard _named.count == 32 else { throw AnyColorSpace.ICCError.endOfData }
            
            named.append(String(bytes: _prefix, encoding: .ascii) ?? "")
            
            let x = Double(try data.decode(BEUInt16.self).representingValue) / 65535
            let y = Double(try data.decode(BEUInt16.self).representingValue) / 65535
            let z = Double(try data.decode(BEUInt16.self).representingValue) / 65535
            
            pcs.append((x, y, z))
            
            for _ in 0..<deviceCoords {
                device.append(Double(try data.decode(BEUInt16.self).representingValue) / 65535)
            }
        }
    }
    
}
