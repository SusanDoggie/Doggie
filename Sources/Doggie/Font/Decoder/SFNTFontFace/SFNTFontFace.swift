//
//  SFNTFontFace.swift
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

struct SFNTFontFace : FontFaceBase {
    
    let table: [Signature<BEUInt32>: Data]
    
    let head: SFNTHEAD
    let cmap: SFNTCMAP
    let post: SFNTPOST
    let os2: SFNTOS2
    
    init(table: [Signature<BEUInt32>: Data]) throws {
        
        guard let head = try table["head"].map({ try SFNTHEAD($0) }) else { throw Font.Error.InvalidFormat("head not found.") }
        guard let cmap = try table["cmap"].map({ try SFNTCMAP($0) }) else { throw Font.Error.InvalidFormat("cmap not found.") }
        guard let post = try table["post"].map({ try SFNTPOST($0) }) else { throw Font.Error.InvalidFormat("post not found.") }
        guard let os2 = try table["OS/2"].map({ try SFNTOS2($0) }) else { throw Font.Error.InvalidFormat("OS/2 not found.") }
        
        self.table = table
        self.head = head
        self.cmap = cmap
        self.post = post
        self.os2 = os2
    }
}

