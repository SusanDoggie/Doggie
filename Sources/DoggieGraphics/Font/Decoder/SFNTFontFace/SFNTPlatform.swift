//
//  SFNTPlatform.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

struct SFNTPlatform: ByteDecodable {
    
    var platform: BEUInt16
    var specific: BEUInt16
    
    init(from data: inout Data) throws {
        self.platform = try data.decode(BEUInt16.self)
        self.specific = try data.decode(BEUInt16.self)
    }
}

extension SFNTPlatform {
    
    var encoding: String.Encoding? {
        switch Int(platform) {
        case 0: return .utf16BigEndian
        case 1:
            switch Int(specific) {
            case 0: return .macOSRoman
            default: return nil
            }
        case 3:
            switch Int(specific) {
            case 0: return .symbol
            case 1: return .utf16BigEndian
            case 2: return .shiftJIS
            case 10: return .utf16BigEndian
            default: return nil
            }
        default: return nil
        }
    }
}
