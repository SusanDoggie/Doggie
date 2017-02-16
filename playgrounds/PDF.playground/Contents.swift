//: Playground - noun: a place where people can play

import Cocoa
import Doggie

extension PDFDocument {
    
    public enum ParserError: Error {
        case invalidFormat(String)
    }
    
    public static func Parse(data: Data) throws -> PDFDocument {
        
        guard equals(data.prefix(5), [37, 80, 68, 70, 45]) else {
            throw ParserError.invalidFormat("'%PDF-' not find.")
        }
        
        let _version = try version(data: data)
        
        var trailer: PDFDocument.Dictionary = [:]
        var xref: [[PDFDocument.Value?]] = []
        
        let _xrefPosition = try xrefPosition(data: data)
        
        return PDFDocument(version: _version, trailer: trailer, xref: PDFDocument.Xref(xref))
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
    
    private static func version(data: Data) throws -> (Int, Int) {
        
        var major = 0
        var minor = 0
        var flag = true
        
        for d in data.dropFirst(5) {
            if 48...57 ~= d {
                if flag {
                    major = major * 10 + Int(d - 48)
                } else {
                    minor = minor * 10 + Int(d - 48)
                }
            } else if flag && d == 46 {
                flag = false
            } else if flag {
                throw ParserError.invalidFormat("invalid version number.")
            } else if d == 10 || d == 13 {
                break
            } else {
                throw ParserError.invalidFormat("invalid version number.")
            }
        }
        
        return (major, minor)
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
    
    private static func eofPosition(data: Data) throws -> Int {
        let _lineEndPosition = lineEndPosition(data: data, position: data.count - 1)
        if equals(data.prefix(upTo: _lineEndPosition).suffix(5), [37, 37, 69, 79, 70]) {
            return _lineEndPosition - 5
        }
        throw ParserError.invalidFormat("'%%EOF' not find.")
    }
    
    private static func xrefPosition(data: Data) throws -> Int {
        
        let _eofPosition = try eofPosition(data: data)
        
        let _xrefEndPosition = lineEndPosition(data: data, position: _eofPosition - 1)
        let _xrefStartPosition = lineStartPosition(data: data, position: _xrefEndPosition - 1)
        
        let _startxref_flag_end = lineEndPosition(data: data, position: _xrefStartPosition - 1)
        if !equals(data.prefix(upTo: _startxref_flag_end).suffix(9), [115, 116, 97, 114, 116, 120, 114, 101, 102]) {
            throw ParserError.invalidFormat("'startxref' not find.")
        }
        
        var offset = 0
        for d in data[_xrefStartPosition..<_xrefEndPosition] {
            if 48...57 ~= d {
                offset = offset * 10 + Int(d - 48)
            } else {
                throw ParserError.invalidFormat("invalid xref position.")
            }
        }
        return offset
    }
}

if let url = Bundle.main.url(forResource: "test", withExtension: "pdf"), let data = try? Data(contentsOf: url) {
    
    print(String(data: data, encoding: .ascii) ?? "")
    
    try PDFDocument.Parse(data: data)
    
}

