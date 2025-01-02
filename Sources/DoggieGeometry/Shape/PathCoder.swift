//
//  PathCoder.swift
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

extension Shape {
    
    public init?(data: Data) {
        self.init()
        
        var data = data
        var last = Point()
        var last_control = Point()
        
        func decode_point(_ data: inout Data) -> Point? {
            guard let x = try? data.decode(BEUInt64.self) else { return nil }
            guard let y = try? data.decode(BEUInt64.self) else { return nil }
            return Point(x: Double(bitPattern: UInt64(x)), y: Double(bitPattern: UInt64(y)))
        }
        
        while let command = data.popFirst() {
            switch command {
            case 0: self.close()
            case 1:
                
                guard let p0 = decode_point(&data) else { return nil }
                
                self.move(to: p0)
                last = p0
                last_control = p0
                
            case 2:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p1 = decode_point(&data) else { return nil }
                    
                    self.line(to: p1)
                    last = p1
                    last_control = p1
                }
                
            case 3:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p2 = decode_point(&data) else { return nil }
                    
                    let p1 = 2 * last - last_control
                    
                    self.quad(to: p2, control: p1)
                    last = p2
                    last_control = p1
                }
                
            case 4:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p1 = decode_point(&data) else { return nil }
                    guard let p2 = decode_point(&data) else { return nil }
                    
                    self.quad(to: p2, control: p1)
                    last = p2
                    last_control = p1
                }
                
            case 5:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p3 = decode_point(&data) else { return nil }
                    
                    let p1 = 2 * last - last_control
                    let p2 = p1
                    
                    self.curve(to: p3, control1: p1, control2: p2)
                    last = p3
                    last_control = p2
                }
                
            case 6:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p2 = decode_point(&data) else { return nil }
                    guard let p3 = decode_point(&data) else { return nil }
                    
                    let p1 = 2 * last - last_control
                    
                    self.curve(to: p3, control1: p1, control2: p2)
                    last = p3
                    last_control = p2
                }
                
            case 7:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let m = try? data.decode(BEUInt64.self) else { return nil }
                    guard let p3 = decode_point(&data) else { return nil }
                    
                    let p1 = Double(bitPattern: UInt64(m)) * (last - last_control).unit + last
                    let p2 = p1
                    
                    self.curve(to: p3, control1: p1, control2: p2)
                    last = p3
                    last_control = p2
                }
                
            case 8:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let m = try? data.decode(BEUInt64.self) else { return nil }
                    guard let p2 = decode_point(&data) else { return nil }
                    guard let p3 = decode_point(&data) else { return nil }
                    
                    let p1 = Double(bitPattern: UInt64(m)) * (last - last_control).unit + last
                    
                    self.curve(to: p3, control1: p1, control2: p2)
                    last = p3
                    last_control = p2
                }
                
            case 9:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p1 = decode_point(&data) else { return nil }
                    guard let p3 = decode_point(&data) else { return nil }
                    
                    let p2 = p1
                    
                    self.curve(to: p3, control1: p1, control2: p2)
                    last = p3
                    last_control = p2
                }
                
            case 10:
                
                guard let count = try? data.decode(UInt8.self) else { return nil }
                
                for _ in 0..<count {
                    
                    guard let p1 = decode_point(&data) else { return nil }
                    guard let p2 = decode_point(&data) else { return nil }
                    guard let p3 = decode_point(&data) else { return nil }
                    
                    self.curve(to: p3, control1: p1, control2: p2)
                    last = p3
                    last_control = p2
                }
                
            default: return nil
            }
        }
    }
    
    public var data: Data {
        
        var data = Data()
        var buffer = Data()
        
        for component in self {
            
            data.append(1)
            data.encode(BEUInt64(component.start.x.bitPattern))
            data.encode(BEUInt64(component.start.y.bitPattern))
            
            var last = component.start
            var last_control = component.start
            var last_command: UInt8 = 1
            var counter: UInt8 = 0
            
            buffer.removeAll(keepingCapacity: true)
            
            func encode_command(_ c: UInt8) {
                guard last_command != c || counter == .max else { return }
                if counter != 0 {
                    data.append(last_command)
                    data.append(counter)
                    data.append(buffer)
                }
                last_command = c
                counter = 0
                buffer.removeAll(keepingCapacity: true)
            }
            
            for segment in component {
                switch segment {
                case let .line(p1):
                    
                    encode_command(2)
                    buffer.encode(BEUInt64(p1.x.bitPattern))
                    buffer.encode(BEUInt64(p1.y.bitPattern))
                    
                    last = p1
                    last_control = p1
                    counter += 1
                    
                case let .quad(p1, p2):
                    
                    if p1.almostEqual(2 * last - last_control) {
                        encode_command(3)
                        buffer.encode(BEUInt64(p2.x.bitPattern))
                        buffer.encode(BEUInt64(p2.y.bitPattern))
                    } else {
                        encode_command(4)
                        buffer.encode(BEUInt64(p1.x.bitPattern))
                        buffer.encode(BEUInt64(p1.y.bitPattern))
                        buffer.encode(BEUInt64(p2.x.bitPattern))
                        buffer.encode(BEUInt64(p2.y.bitPattern))
                    }
                    
                    last = p2
                    last_control = p1
                    counter += 1
                    
                case let .cubic(p1, p2, p3):
                    
                    if p1.almostEqual(2 * last - last_control) {
                        
                        if p1.almostEqual(p2) {
                            
                            encode_command(5)
                            buffer.encode(BEUInt64(p3.x.bitPattern))
                            buffer.encode(BEUInt64(p3.y.bitPattern))
                            
                        } else {
                            
                            encode_command(6)
                            buffer.encode(BEUInt64(p2.x.bitPattern))
                            buffer.encode(BEUInt64(p2.y.bitPattern))
                            buffer.encode(BEUInt64(p3.x.bitPattern))
                            buffer.encode(BEUInt64(p3.y.bitPattern))
                        }
                        
                    } else if (p1 - last).unit.almostEqual((last - last_control).unit) {
                        
                        if p1.almostEqual(p2) {
                            
                            encode_command(7)
                            buffer.encode(BEUInt64(p1.distance(to: last).bitPattern))
                            buffer.encode(BEUInt64(p3.x.bitPattern))
                            buffer.encode(BEUInt64(p3.y.bitPattern))
                            
                        } else {
                            
                            encode_command(8)
                            buffer.encode(BEUInt64(p1.distance(to: last).bitPattern))
                            buffer.encode(BEUInt64(p2.x.bitPattern))
                            buffer.encode(BEUInt64(p2.y.bitPattern))
                            buffer.encode(BEUInt64(p3.x.bitPattern))
                            buffer.encode(BEUInt64(p3.y.bitPattern))
                        }
                        
                    } else {
                        
                        if p1.almostEqual(p2) {
                            
                            encode_command(9)
                            buffer.encode(BEUInt64(p1.x.bitPattern))
                            buffer.encode(BEUInt64(p1.y.bitPattern))
                            buffer.encode(BEUInt64(p3.x.bitPattern))
                            buffer.encode(BEUInt64(p3.y.bitPattern))
                            
                        } else {
                            
                            encode_command(10)
                            buffer.encode(BEUInt64(p1.x.bitPattern))
                            buffer.encode(BEUInt64(p1.y.bitPattern))
                            buffer.encode(BEUInt64(p2.x.bitPattern))
                            buffer.encode(BEUInt64(p2.y.bitPattern))
                            buffer.encode(BEUInt64(p3.x.bitPattern))
                            buffer.encode(BEUInt64(p3.y.bitPattern))
                        }
                    }
                    
                    last = p3
                    last_control = p2
                    counter += 1
                }
            }
            
            if counter != 0 {
                data.append(last_command)
                data.append(counter)
                data.append(buffer)
            }
            
            if component.isClosed {
                data.append(0)
            }
        }
        
        return data
    }
}
