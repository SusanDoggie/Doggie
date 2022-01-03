//
//  SFNTGLYF.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

struct SFNTGLYF {
    
    var format: Int
    var loca: Data
    var glyf: Data
    
    init(format: Int, numberOfGlyphs: Int, loca: Data, glyf: Data) throws {
        let locaSize = format == 0 ? (numberOfGlyphs + 1) << 1 : (numberOfGlyphs + 1) << 2
        guard loca.count >= locaSize else { throw ByteDecodeError.endOfData }
        self.format = format
        self.loca = loca
        self.glyf = glyf
    }
    
}

extension SFNTGLYF {
    
    private func _glyfData(glyph: Int) -> Data? {
        
        let startIndex: Int
        let endIndex: Int
        
        if format == 0 {
            startIndex = Int(loca.typed(as: BEUInt16.self)[glyph]) << 1
            endIndex = Int(loca.typed(as: BEUInt16.self)[glyph + 1]) << 1
        } else {
            startIndex = Int(loca.typed(as: BEUInt32.self)[glyph])
            endIndex = Int(loca.typed(as: BEUInt32.self)[glyph + 1])
        }
        
        return endIndex > startIndex ? glyf.dropFirst(startIndex).prefix(endIndex - startIndex) : nil
    }
    
    func outline(glyph: Int, tracing: Set<Int> = []) -> ([Point], [Shape.Component])? {
        
        guard var data = _glyfData(glyph: glyph) else { return nil }
        
        guard let numberOfContours = try? data.decode(BEInt16.self), numberOfContours != 0 else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        guard let _ = try? data.decode(BEInt16.self) else { return nil }
        
        if numberOfContours > 0 {
            
            guard let endPtsOfContours = try? (0..<Int(numberOfContours)).map({ _ in try data.decode(BEUInt16.self) }) else { return nil }
            
            guard zip(endPtsOfContours, endPtsOfContours.dropFirst()).allSatisfy({ $0 < $1 }) else { return nil }
            
            guard let instructionLength = try? data.decode(BEUInt16.self) else { return nil }
            
            guard (try? (0..<Int(instructionLength)).map({ _ in try data.decode(UInt8.self) })) != nil else { return nil }
            
            let numberOfCoordinates = Int(endPtsOfContours.last!) + 1
            
            var flags = [UInt8]()
            flags.reserveCapacity(numberOfCoordinates)
            while flags.count < numberOfCoordinates {
                guard let flag = try? data.decode(UInt8.self) else { return nil }
                flags.append(flag)
                if flag & 8 != 0 {
                    guard let _repeat = try? data.decode(UInt8.self) else { return nil }
                    for _ in 0..<_repeat {
                        flags.append(flag)
                    }
                }
            }
            guard flags.count == numberOfCoordinates else { return nil }
            
            func coordinate(_ flag: UInt8, _ previousValue: Int16, _ bitMask: (UInt8, UInt8)) throws -> Int16 {
                let code: Int16
                if flag & bitMask.0 != 0 {
                    if flag & bitMask.1 == 0 {
                        code = previousValue - Int16(try data.decode(UInt8.self))
                    } else {
                        code = previousValue + Int16(try data.decode(UInt8.self))
                    }
                } else {
                    if flag & bitMask.1 != 0 {
                        code = previousValue
                    } else {
                        code = previousValue + Int16(try data.decode(BEInt16.self))
                    }
                }
                return code
            }
            
            var x_coordinate: [Int16] = []
            var y_coordinate: [Int16] = []
            x_coordinate.reserveCapacity(numberOfCoordinates)
            y_coordinate.reserveCapacity(numberOfCoordinates)
            
            for flag in flags {
                guard let _x = try? coordinate(flag, x_coordinate.last ?? 0, (2, 16)) else { return nil }
                x_coordinate.append(_x)
            }
            
            for flag in flags {
                guard let _y = try? coordinate(flag, y_coordinate.last ?? 0, (4, 32)) else { return nil }
                y_coordinate.append(_y)
            }
            
            let points = zip(x_coordinate, y_coordinate).map { Point(x: Double($0), y: Double($1)) }
            
            var components: [Shape.Component] = []
            components.reserveCapacity(endPtsOfContours.count)
            
            var startIndex = 0
            for _endIndex in endPtsOfContours {
                
                let endIndex = Int(_endIndex)
                
                let range = startIndex...endIndex
                let flags = flags[range]
                let points = points[range]
                
                var component = Shape.Component(start: Point(), closed: true, segments: [])
                var record: (UInt8, Point)?
                var rotate = 0
                
                if flags[endIndex] & 1 == 1 {
                    component.start = points[endIndex]
                    record = (flags[endIndex], component.start)
                } else if flags[startIndex] & 1 == 1 {
                    component.start = points[startIndex]
                    record = (flags[startIndex], component.start)
                    rotate = 1
                } else {
                    component.start = 0.5 * (points[endIndex] + points[startIndex])
                }
                
                for (flag, point) in zip(flags.rotated(rotate), points.rotated(rotate)) {
                    if let record = record {
                        if record.0 & 1 == 1 {
                            if flag & 1 == 1 {
                                component.append(.line(point))
                            }
                        } else {
                            if flag & 1 == 1 {
                                component.append(.quad(record.1, point))
                            } else {
                                component.append(.quad(record.1, 0.5 * (record.1 + point)))
                            }
                        }
                    } else if flag & 1 == 1 {
                        component.append(.line(point))
                    }
                    record = (flag, point)
                }
                
                if let record = record, record.0 & 1 == 0 {
                    component.append(.quad(record.1, component.start))
                }
                
                components.append(component)
                
                startIndex = endIndex + 1
            }
            
            return (points, components)
            
        } else {
            
            var components = [Shape.Component]()
            
            var _continue = true
            
            var points = [Point]()
            
            var tracing = tracing
            tracing.insert(glyph)
            
            while _continue {
                
                guard let flags = try? data.decode(BEUInt16.self) else { return nil }
                guard let glyphIndex = try? data.decode(BEUInt16.self), !tracing.contains(Int(glyphIndex)) else { return nil }
                
                guard let (_points, _components) = self.outline(glyph: Int(glyphIndex), tracing: tracing) else { return nil }
                
                var transform = SDTransform.identity
                
                if flags & 1 != 0 {
                    
                    if flags & 2 != 0 {
                        
                        guard let dx = try? data.decode(BEInt16.self) else { return nil }
                        guard let dy = try? data.decode(BEInt16.self) else { return nil }
                        
                        transform.c = Double(dx)
                        transform.f = Double(dy)
                        
                    } else {
                        
                        guard let m0 = try? data.decode(BEUInt16.self), m0 < points.count else { return nil }
                        guard let m1 = try? data.decode(BEUInt16.self), m1 < _points.count else { return nil }
                        
                        let offset = points[Int(m0)] - _points[Int(m1)]
                        
                        transform.c = offset.x
                        transform.f = offset.y
                    }
                } else {
                    
                    if flags & 2 != 0 {
                        
                        guard let dx = try? data.decode(Int8.self) else { return nil }
                        guard let dy = try? data.decode(Int8.self) else { return nil }
                        
                        transform.c = Double(dx)
                        transform.f = Double(dy)
                        
                    } else {
                        
                        guard let m0 = try? data.decode(UInt8.self), m0 < points.count else { return nil }
                        guard let m1 = try? data.decode(UInt8.self), m1 < _points.count else { return nil }
                        
                        let offset = points[Int(m0)] - _points[Int(m1)]
                        
                        transform.c = offset.x
                        transform.f = offset.y
                    }
                }
                
                if flags & 8 != 0 {
                    
                    guard let scale = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    
                    transform.a = scale.representingValue
                    transform.e = scale.representingValue
                    
                } else if flags & 64 != 0 {
                    
                    guard let x_scale = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    guard let y_scale = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    
                    transform.a = x_scale.representingValue
                    transform.e = y_scale.representingValue
                    
                } else if flags & 128 != 0 {
                    
                    guard let m00 = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    guard let m01 = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    guard let m10 = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    guard let m11 = try? data.decode(Fixed14Number<BEInt16>.self) else { return nil }
                    
                    transform.a = m00.representingValue
                    transform.b = m01.representingValue
                    transform.d = m10.representingValue
                    transform.e = m11.representingValue
                }
                
                points.append(contentsOf: _points)
                components.append(contentsOf: _components.map { $0 * transform })
                _continue = flags & 32 != 0
            }
            
            return (points, components)
        }
    }
}
