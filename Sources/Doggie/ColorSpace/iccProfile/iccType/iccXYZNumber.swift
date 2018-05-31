//
//  iccXYZNumber.swift
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

struct iccXYZNumber : ByteCodable {
    
    var x: Fixed16Number<BEInt32>
    var y: Fixed16Number<BEInt32>
    var z: Fixed16Number<BEInt32>
    
    init(x: Fixed16Number<BEInt32>, y: Fixed16Number<BEInt32>, z: Fixed16Number<BEInt32>) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(_ xyz: XYZColorModel) {
        self.x = Fixed16Number(xyz.x)
        self.y = Fixed16Number(xyz.y)
        self.z = Fixed16Number(xyz.z)
    }
    
    init(from data: inout Data) throws {
        self.x = try data.decode(Fixed16Number.self)
        self.y = try data.decode(Fixed16Number.self)
        self.z = try data.decode(Fixed16Number.self)
    }
    
    func encode(to stream: inout ByteOutputStream) {
        stream.write(x, y, z)
    }
}
