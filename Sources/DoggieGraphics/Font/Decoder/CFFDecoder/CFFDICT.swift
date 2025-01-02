//
//  CFFDICT.swift
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

struct CFFDICT: ByteDecodable {
    
    var dict: [Int: [Operand]] = [:]
    
    init(from data: inout Data) throws {
        var operands = [Operand]()
        while let byte = data.popFirst() {
            if byte <= 21 {
                if byte == 12 {
                    guard let op = data.popFirst() else { throw ByteDecodeError.endOfData }
                    dict[1200 + Int(op)] = operands
                } else {
                    dict[Int(byte)] = operands
                }
                operands = []
            } else {
                
                switch byte {
                case 28:
                    
                    guard let b1 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    guard let b2 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    operands.append(.integer(b1 << 8 | b2))
                    
                case 29:
                    
                    guard let b1 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    guard let b2 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    guard let b3 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    guard let b4 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    operands.append(.integer(b1 << 24 | b2 << 16 | b3 << 8 | b4))
                    
                case 30:
                    
                    var numberStr = ""
                    
                    loop: while true {
                        
                        guard let b1 = data.popFirst() else { throw ByteDecodeError.endOfData }
                        
                        switch b1 >> 4 {
                        case 0x0: numberStr.append("0")
                        case 0x1: numberStr.append("1")
                        case 0x2: numberStr.append("2")
                        case 0x3: numberStr.append("3")
                        case 0x4: numberStr.append("4")
                        case 0x5: numberStr.append("5")
                        case 0x6: numberStr.append("6")
                        case 0x7: numberStr.append("7")
                        case 0x8: numberStr.append("8")
                        case 0x9: numberStr.append("9")
                        case 0xA: numberStr.append(".")
                        case 0xB: numberStr.append("E")
                        case 0xC:
                            numberStr.append("E")
                            numberStr.append("-")
                        case 0xE: numberStr.append("-")
                        case 0xF: break loop
                        default: break
                        }
                        switch b1 & 0x0F {
                        case 0x0: numberStr.append("0")
                        case 0x1: numberStr.append("1")
                        case 0x2: numberStr.append("2")
                        case 0x3: numberStr.append("3")
                        case 0x4: numberStr.append("4")
                        case 0x5: numberStr.append("5")
                        case 0x6: numberStr.append("6")
                        case 0x7: numberStr.append("7")
                        case 0x8: numberStr.append("8")
                        case 0x9: numberStr.append("9")
                        case 0xA: numberStr.append(".")
                        case 0xB: numberStr.append("E")
                        case 0xC:
                            numberStr.append("E")
                            numberStr.append("-")
                        case 0xE: numberStr.append("-")
                        case 0xF: break loop
                        default: break
                        }
                    }
                    
                    guard let number = Double(numberStr) else { throw FontCollection.Error.InvalidFormat("Invalid CFF DICT operand.") }
                    
                    operands.append(.number(number))
                    
                case 32...246:
                    
                    operands.append(.integer(Int(byte) - 139))
                    
                case 247...250:
                    
                    guard let b1 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    operands.append(.integer((Int(byte) - 247) << 8 + b1 + 108))
                    
                case 251...254:
                    
                    guard let b1 = data.popFirst().map(Int.init) else { throw ByteDecodeError.endOfData }
                    operands.append(.integer(-(Int(byte) - 251) << 8 - b1 - 108))
                    
                default: throw FontCollection.Error.InvalidFormat("Invalid CFF DICT operand.")
                }
            }
        }
    }
    
    enum Operand {
        case integer(Int)
        case number(Double)
    }
}

extension CFFDICT {
    
    var fdArrayOffset: Int? {
        if case let .integer(offset) = dict[1236]?.first, offset != 0 {
            return offset
        }
        return nil
    }
    var fdSelectOffset: Int? {
        if case let .integer(offset) = dict[1237]?.first, offset != 0 {
            return offset
        }
        return nil
    }
    
    var pDICTRange: Range<Int>? {
        if let operands = dict[18], operands.count == 2, case let .integer(size) = operands[0], case let .integer(offset) = operands[1], size != 0 && offset != 0 {
            return offset..<offset + size
        }
        return nil
    }
    
    var subrsOffset: Int? {
        if case let .integer(offset) = dict[19]?.first, offset != 0 {
            return offset
        }
        return nil
    }
    
    var charstringType: Int {
        if case let .integer(type) = dict[1206]?.first {
            return type
        }
        return 2
    }
    
    var charStringsOffset: Int? {
        if case let .integer(offset) = dict[17]?.first, offset != 0 {
            return offset
        }
        return nil
    }
    
    var encodingOffset: Int? {
        if case let .integer(offset) = dict[16]?.first, offset != 0 {
            return offset
        }
        return nil
    }
}

