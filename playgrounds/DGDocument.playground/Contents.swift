//: Playground - noun: a place where people can play

import Cocoa
import Doggie

extension DGDocument {
    
    public enum ParserError: Error {
        case invalidFormat(String)
    }
    
    public static func Parse(data: Data) throws -> DGDocument {
        
        guard equals(data.prefix(4), [37, 68, 79, 71]) else {
            throw ParserError.invalidFormat("'%DOG' not find.")
        }
        
        let (root, xref) = try xrefTable(data: data)
        var table: [Int: DGDocument.Value] = [:]
        
        return DGDocument(root: root, table: table)
    }
    
    private static func equals<S1 : Sequence, S2 : Sequence>(_ lhs: S1, _ rhs: S2) -> Bool where S1.Iterator.Element : Equatable, S1.Iterator.Element == S2.Iterator.Element {
        var i1 = lhs.makeIterator()
        var i2 = rhs.makeIterator()
        while true {
            let e1 = i1.next()
            let e2 = i2.next()
            if e1 == nil && e2 == nil {
                return true
            } else if e1 != e2 {
                return false
            }
        }
    }
    
    private static func lineStartPosition(data: Data, position: Int) -> Int {
        if position == 0 {
            return 0
        }
        let _1 = data[position - 1]
        let _2 = data[position]
        var index = position
        if (_1 == 10 && _2 == 13) || (_1 == 13 && _2 == 10) {
            index -= 2
        } else if _2 == 10 || _2 == 13 {
            index -= 1
        }
        while index != 0 {
            switch data[index] {
            case 10, 13: return index + 1
            default: index -= 1
            }
        }
        return index
    }
    private static func lineEndPosition(data: Data, position: Int) -> Int {
        if position == 0 {
            return 0
        }
        let _1 = data[position - 1]
        let _2 = data[position]
        if (_1 == 10 && _2 == 13) || (_1 == 13 && _2 == 10) {
            return position - 1
        } else if _2 == 10 || _2 == 13 {
            return position
        }
        var index = position
        while index != data.count {
            switch data[index] {
            case 10, 13: return index
            default: index += 1
            }
        }
        return index
    }
    
    private static func xrefTable(data: Data) throws -> (Int, [Int: Int]) {
        
        var root = 0
        var table: [Int: Int] = [:]
        
        let _eofPosition = try eofPosition(data: data)
        
        let _rootIdEndPosition = lineEndPosition(data: data, position: _eofPosition - 1)
        let _rootIdStartPosition = lineStartPosition(data: data, position: _rootIdEndPosition - 1)
        
        var flag = 0
        for d in data[_rootIdStartPosition..<_rootIdEndPosition] {
            if 48...57 ~= d {
                switch flag {
                case 0: root = root * 10 + Int(d - 48)
                default: throw ParserError.invalidFormat("invalid file format.")
                }
            } else if d == 32 {
                flag += 1
            } else {
                throw ParserError.invalidFormat("invalid file format.")
            }
        }
        var offset = _rootIdStartPosition - 1
        while let next = try xrefDecode(data: data, position: offset, table: &table) {
            offset = next - 1
        }
        return (root, table)
    }
    
    private static func xrefDecode(data: Data, position: Int, table: inout [Int: Int]) throws -> Int? {
        
        var _lineStart = lineStartPosition(data: data, position: position)
        var _lineEnd = lineEndPosition(data: data, position: position)
        
        while true {
            let line = data[_lineStart..<_lineEnd]
            if line.count > 5 && equals(line.prefix(6), [37, 88, 82, 69, 70, 32]) {
                var offset = 0
                for d in line.dropFirst(6) {
                    if 48...57 ~= d {
                        offset = offset * 10 + Int(d - 48)
                    } else {
                        throw ParserError.invalidFormat("invalid file format.")
                    }
                }
                return offset
            } else if line.count == 5 && equals(line, [37, 88, 82, 69, 70]) {
                return nil
            }
            try xrefDecodeLine(line: line, table: &table)
            _lineEnd = lineEndPosition(data: data, position: _lineStart - 1)
            _lineStart = lineStartPosition(data: data, position: _lineStart - 1)
        }
    }
    
    private static func xrefDecodeLine(line: MutableRandomAccessSlice<Data>, table: inout [Int: Int]) throws {
        
        var numList = [0]
        for d in line {
            if 48...57 ~= d {
                let _last = numList.endIndex - 1
                numList[_last] = numList[_last] * 10 + Int(d - 48)
            } else if d == 32 {
                numList.append(0)
            } else {
                throw ParserError.invalidFormat("invalid file format.")
            }
        }
        if numList.count > 1 {
            var counter = numList[0]
            for d in numList.dropFirst() {
                if table[counter] == nil {
                    table[counter] = d
                }
                counter += 1
            }
        }
    }
    
    private static func eofPosition(data: Data) throws -> Int {
        let _lineEndPosition = lineEndPosition(data: data, position: data.count - 1)
        if equals(data.prefix(upTo: _lineEndPosition).suffix(5), [37, 37, 69, 79, 70]) {
            return _lineEndPosition - 5
        }
        throw ParserError.invalidFormat("'%%EOF' not find.")
    }
}

Array("%XREF ".utf8)

let test = "%DOG\n{@2 a\0 /1}\n[]\n%XREF\n0 5 16\n0\n%%EOF\n{@2 b\0 /1}\n%XREF 32\n0 39\n0\n%%EOF"

print(Array(test.utf8))
let data = Data(bytes: Array(test.utf8))

do {
    
    let document = try DGDocument.Parse(data: data)
    
    document

} catch let DGDocument.ParserError.invalidFormat(msg) {
    print(msg)
}
