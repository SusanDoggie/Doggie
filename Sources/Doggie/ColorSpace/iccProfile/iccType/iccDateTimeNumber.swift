//
//  iccDateTimeNumber.swift
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

@frozen
@usableFromInline
struct iccDateTimeNumber : ByteCodable {
    
    var year: BEUInt16
    var month: BEUInt16
    var day: BEUInt16
    var hours: BEUInt16
    var minutes: BEUInt16
    var seconds: BEUInt16
    
    init(year: BEUInt16, month: BEUInt16, day: BEUInt16, hours: BEUInt16, minutes: BEUInt16, seconds: BEUInt16) {
        self.year = year
        self.month = month
        self.day = day
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    @usableFromInline
    init(from data: inout Data) throws {
        self.year = try data.decode(BEUInt16.self)
        self.month = try data.decode(BEUInt16.self)
        self.day = try data.decode(BEUInt16.self)
        self.hours = try data.decode(BEUInt16.self)
        self.minutes = try data.decode(BEUInt16.self)
        self.seconds = try data.decode(BEUInt16.self)
    }
    
    @usableFromInline
    func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(year)
        stream.encode(month)
        stream.encode(day)
        stream.encode(hours)
        stream.encode(minutes)
        stream.encode(seconds)
    }
}
