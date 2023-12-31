//
//  CFFCharStrings.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

extension CFFFontFace {
    
    func fontDICT(glyph: UInt16) -> CFFFontDICT? {
        guard let fdSelect = self.fdSelect, let fontDICTArray = self.fontDICTArray else { return self.DICT }
        guard let index = fdSelect.fdIndex(glyph: glyph), index < fontDICTArray.count else { return nil }
        guard let _dict = try? CFFDICT(fontDICTArray[Int(index)]) else { return nil }
        return try? CFFFontDICT(self.data, _dict)
    }
    
    func subroutineBias(_ subroutine: CFFINDEX) -> Int {
        if self.charstringType == 1 {
            return 0
        } else if subroutine.count < 1240 {
            return 107
        } else if subroutine.count < 33900 {
            return 1131
        } else {
            return 32768
        }
    }
    
    func shape(glyph: Int) -> [Shape.Component] {
        
        guard glyph < charStrings.count else { return [] }
        guard let fontDICT = self.fontDICT(glyph: UInt16(glyph)) else { return [] }
        
        let subroutine = self.subroutine
        let subroutineBias = self.subroutineBias(subroutine)
        
        let pSubroutine = fontDICT.pSubroutine
        let pSubroutineBias = pSubroutine.map { self.subroutineBias($0) }
        
        var components: [Shape.Component] = []
        var component = Shape.Component(start: Point(), closed: true, segments: [])
        
        var stack: ArraySlice<Fixed16Number<Int32>> = []
        var _stems_count = 0
        var point = Point()
        var flag = false
        
        struct ParserError: Error {
            
        }
        
        func _stems() {
            
            if stack.count & 1 != 0 && !flag {
                stack.removeFirst()
            }
            
            _stems_count += stack.count >> 1
            stack.removeAll(keepingCapacity: true)
            flag = true
        }
        
        func _parser(_ data: Data, tracing: (Set<Int>, Set<Int>)) throws {
            
            var data = data
            
            while let code = try? data.decode(UInt8.self) {
                
                switch code {
                    
                case 11, 14:
                    
                    return
                    
                case 1, 3, 18, 23:
                    
                    _stems()
                    
                case 19, 20:
                    
                    _stems()
                    data.removeFirst((_stems_count + 7) >> 3)
                    
                case 29:
                    
                    guard let code = stack.popLast()?.bitPattern else { throw ParserError() }
                    
                    let codeIndex = Int(code >> 16) + subroutineBias
                    
                    guard subroutine.indices ~= codeIndex else { throw ParserError() }
                    guard !tracing.0.contains(codeIndex) else { throw ParserError() }
                    
                    var tracing = tracing
                    tracing.0.insert(codeIndex)
                    
                    try _parser(subroutine[codeIndex], tracing: tracing)
                    
                case 10:
                    
                    guard let code = stack.popLast()?.bitPattern else { throw ParserError() }
                    guard let pSubroutine = pSubroutine else { throw ParserError() }
                    guard let pSubroutineBias = pSubroutineBias else { throw ParserError() }
                    
                    let codeIndex = Int(code >> 16) + pSubroutineBias
                    
                    guard pSubroutine.indices ~= codeIndex else { throw ParserError() }
                    guard !tracing.1.contains(codeIndex) else { throw ParserError() }
                    
                    var tracing = tracing
                    tracing.1.insert(codeIndex)
                    
                    try _parser(pSubroutine[codeIndex], tracing: tracing)
                    
                case 22:
                    
                    if stack.count > 1 && !flag {
                        stack.removeFirst()
                        flag = true
                    }
                    
                    guard let dx = stack.popLast()?.representingValue else { throw ParserError() }
                    
                    point.x += dx
                    
                    components.append(component)
                    component.removeAll(keepingCapacity: true)
                    component.start = point
                    
                case 4:
                    
                    if stack.count > 1 && !flag {
                        stack.removeFirst()
                        flag = true
                    }
                    
                    guard let dy = stack.popLast()?.representingValue else { throw ParserError() }
                    
                    point.y += dy
                    
                    components.append(component)
                    component.removeAll(keepingCapacity: true)
                    component.start = point
                    
                case 21:
                    
                    if stack.count > 2 && !flag {
                        stack.removeFirst()
                        flag = true
                    }
                    
                    guard let dy = stack.popLast()?.representingValue else { throw ParserError() }
                    guard let dx = stack.popLast()?.representingValue else { throw ParserError() }
                    
                    point.x += dx
                    point.y += dy
                    
                    components.append(component)
                    component.removeAll(keepingCapacity: true)
                    component.start = point
                    
                case 6:
                    
                    while let dx = stack.popFirst()?.representingValue {
                        
                        point.x += dx
                        component.append(.line(point))
                        
                        if let dy = stack.popFirst()?.representingValue {
                            point.y += dy
                            component.append(.line(point))
                        }
                    }
                    
                case 7:
                    
                    while let dy = stack.popFirst()?.representingValue {
                        
                        point.y += dy
                        component.append(.line(point))
                        
                        if let dx = stack.popFirst()?.representingValue {
                            point.x += dx
                            component.append(.line(point))
                        }
                    }
                    
                case 5:
                    
                    while let dx = stack.popFirst()?.representingValue {
                        
                        guard let dy = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        point.x += dx
                        point.y += dy
                        component.append(.line(point))
                    }
                    
                case 8:
                    
                    while let dx1 = stack.popFirst()?.representingValue {
                        
                        guard let dy1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        point = c2 + Point(x: dx3, y: dy3)
                        component.append(.cubic(c1, c2, point))
                    }
                    
                case 24:
                    
                    while stack.count > 2 {
                        
                        guard let dx1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        point = c2 + Point(x: dx3, y: dy3)
                        component.append(.cubic(c1, c2, point))
                    }
                    
                    guard let dx = stack.popFirst()?.representingValue else { throw ParserError() }
                    guard let dy = stack.popFirst()?.representingValue else { throw ParserError() }
                    
                    point.x += dx
                    point.y += dy
                    component.append(.line(point))
                    
                case 25:
                    
                    while stack.count > 6 {
                        
                        guard let dx = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        point.x += dx
                        point.y += dy
                        component.append(.line(point))
                    }
                    
                    guard let dx1 = stack.popFirst()?.representingValue else { throw ParserError() }
                    guard let dy1 = stack.popFirst()?.representingValue else { throw ParserError() }
                    guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                    guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                    guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                    guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                    
                    let c1 = point + Point(x: dx1, y: dy1)
                    let c2 = c1 + Point(x: dx2, y: dy2)
                    point = c2 + Point(x: dx3, y: dy3)
                    component.append(.cubic(c1, c2, point))
                    
                case 26:
                    
                    if stack.count & 1 == 1 {
                        guard let dx = stack.popFirst()?.representingValue else { throw ParserError() }
                        point.x += dx
                    }
                    
                    while let dy1 = stack.popFirst()?.representingValue {
                        
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: 0, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        point = c2 + Point(x: 0, y: dy3)
                        component.append(.cubic(c1, c2, point))
                    }
                    
                case 27:
                    
                    if stack.count & 1 == 1 {
                        guard let dy = stack.popFirst()?.representingValue else { throw ParserError() }
                        point.y += dy
                    }
                    
                    while let dx1 = stack.popFirst()?.representingValue {
                        
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: 0)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        point = c2 + Point(x: dx3, y: 0)
                        component.append(.cubic(c1, c2, point))
                    }
                    
                case 30:
                    
                    while let dy1 = stack.popFirst()?.representingValue {
                        
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        let dy3 = stack.count == 1 ? stack.popFirst()!.representingValue : 0
                        
                        let c1 = point + Point(x: 0, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        point = c2 + Point(x: dx3, y: dy3)
                        component.append(.cubic(c1, c2, point))
                        
                        if let dx1 = stack.popFirst()?.representingValue {
                            
                            guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                            guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                            guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                            let dx3 = stack.count == 1 ? stack.popFirst()!.representingValue : 0
                            
                            let c1 = point + Point(x: dx1, y: 0)
                            let c2 = c1 + Point(x: dx2, y: dy2)
                            point = c2 + Point(x: dx3, y: dy3)
                            component.append(.cubic(c1, c2, point))
                        }
                    }
                    
                case 31:
                    
                    while let dx1 = stack.popFirst()?.representingValue {
                        
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        let dx3 = stack.count == 1 ? stack.popFirst()!.representingValue : 0
                        
                        let c1 = point + Point(x: dx1, y: 0)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        point = c2 + Point(x: dx3, y: dy3)
                        component.append(.cubic(c1, c2, point))
                        
                        if let dy1 = stack.popFirst()?.representingValue {
                            
                            guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                            guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                            guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                            let dy3 = stack.count == 1 ? stack.popFirst()!.representingValue : 0
                            
                            let c1 = point + Point(x: 0, y: dy1)
                            let c2 = c1 + Point(x: dx2, y: dy2)
                            point = c2 + Point(x: dx3, y: dy3)
                            component.append(.cubic(c1, c2, point))
                        }
                    }
                    
                case 12:
                    
                    let code = try data.decode(UInt8.self)
                    
                    switch code {
                        
                    case 34:
                        
                        guard let dx1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx4 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx6 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: 0)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        let md = c2 + Point(x: dx3, y: 0)
                        let c3 = md + Point(x: dx4, y: 0)
                        let c4 = c3 + Point(x: dx5, y: 0)
                        point.x = c4.x + dx6
                        
                        component.append(.cubic(c1, c2, md))
                        component.append(.cubic(c3, c4, point))
                        
                    case 35:
                        
                        guard let dx1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx4 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy4 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx6 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy6 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        let md = c2 + Point(x: dx3, y: dy3)
                        let c3 = md + Point(x: dx4, y: dy4)
                        let c4 = c3 + Point(x: dx5, y: dy5)
                        point = c4 + Point(x: dx6, y: dy6)
                        
                        stack.removeFirst()
                        
                        component.append(.cubic(c1, c2, md))
                        component.append(.cubic(c3, c4, point))
                        
                    case 36:
                        
                        guard let dx1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx4 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx6 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        let md = c2 + Point(x: dx3, y: 0)
                        let c3 = md + Point(x: dx4, y: 0)
                        let c4 = c3 + Point(x: dx5, y: dy5)
                        point.x = c4.x + dx6
                        
                        component.append(.cubic(c1, c2, md))
                        component.append(.cubic(c3, c4, point))
                        
                    case 37:
                        
                        guard let dx1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy1 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy2 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy3 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx4 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy4 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dx5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let dy5 = stack.popFirst()?.representingValue else { throw ParserError() }
                        guard let d6 = stack.popFirst()?.representingValue else { throw ParserError() }
                        
                        let c1 = point + Point(x: dx1, y: dy1)
                        let c2 = c1 + Point(x: dx2, y: dy2)
                        let md = c2 + Point(x: dx3, y: dy3)
                        let c3 = md + Point(x: dx4, y: dy4)
                        let c4 = c3 + Point(x: dx5, y: dy5)
                        if abs(c4.x - point.x) > abs(c4.y - point.y) {
                            point.x = c4.x + d6
                        } else {
                            point.y = c4.y + d6
                        }
                        
                        component.append(.cubic(c1, c2, md))
                        component.append(.cubic(c3, c4, point))
                        
                    default: throw ParserError()
                    }
                    
                case 28:
                    
                    stack.append(Fixed16Number(bitPattern: Int32(try data.decode(BEInt16.self)) << 16))
                    
                case 32...246:
                    
                    stack.append(Fixed16Number(bitPattern: (Int32(code) - 139) << 16))
                    
                case 247...250:
                    
                    let b1 = try data.decode(UInt8.self)
                    let b2 = (Int32(code) - 247) << 8 + Int32(b1) + 108
                    
                    stack.append(Fixed16Number(bitPattern: b2 << 16))
                    
                case 251...254:
                    
                    let b1 = try data.decode(UInt8.self)
                    let b2 = -(Int32(code) - 251) << 8 - Int32(b1) - 108
                    
                    stack.append(Fixed16Number(bitPattern: b2 << 16))
                    
                case 255:
                    
                    stack.append(Fixed16Number(bitPattern: try data.decode(BEInt32.self).representingValue))
                    
                default: throw ParserError()
                }
            }
        }
        
        do {
            
            try _parser(charStrings[glyph], tracing: ([], []))
            
            if !component.isEmpty {
                components.append(component)
            }
            
            return components
            
        } catch {
            return []
        }
    }
}

