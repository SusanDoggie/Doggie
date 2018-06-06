//
//  JPEGDecoder.swift
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

struct JPEGDecoder : ImageRepDecoder {
    
    var APP0: JPEGAPP0
    
    var frame: [JPEGFrame] = []
    
    init?(data: Data) throws {
        
        var data = data
        
        guard (try? data.decode(JPEGSegment.self).marker) == .SOI else { return nil }
        
        guard let _APP0 = try? data.decode(JPEGSegment.self) else { return nil }
        guard _APP0.marker == .APP0, let APP0 = try? JPEGAPP0(_APP0) else { return nil }
        
        self.APP0 = APP0
        
        var tables: [JPEGSegment.Marker: JPEGSegment] = [:]
        
        while let segment = try? data.decode(JPEGSegment.self) {
            
            switch segment.marker {
            case .SOF0 ... .SOF3, .SOF5 ... .SOF7, .SOF9 ... .SOF11, .SOF13 ... .SOF15: // Start Of Frame
                
                self.frame.append(JPEGFrame(SOF: try JPEGSOF(segment), tables: tables, scan: []))
                
            case .SOS: // Start Of Scan
                
                guard self.frame.count != 0 else { return nil }
                
                self.frame.mutableLast.scan.append(JPEGScan(SOS: try JPEGSOS(segment), tables: tables, ECS: []))
                tables = self.frame.last!.tables
                
                fallthrough
                
            case .RST0 ... .RST7: // Restart
                
                guard self.frame.count != 0 && self.frame.mutableLast.scan.count != 0 else { return nil }
                guard let count = zip(data, data.dropFirst()).enumerated().first(where: { $0.1.0 == 0xFF && $0.1.1 != 0x00 })?.offset else { return nil }
                
                self.frame.mutableLast.scan.mutableLast.ECS.append(data.popFirst(count))
                
            case .DHT, .DQT:
                
                tables[segment.marker] = segment
                
            default: break
            }
        }
        
        guard frame.count == 1 else { return nil }
        // guard frame.count != 0 else { return nil }
        
    }
    
    var width: Int {
        return Int(self.frame[0].SOF.samplesPerLine)
    }
    
    var height: Int {
        return Int(self.frame[0].SOF.lines)
    }
    
    var resolution: Resolution {
        let _x = APP0.Xdensity.representingValue == 0 ? 0 : 1 / Double(APP0.Xdensity)
        let _y = APP0.Ydensity.representingValue == 0 ? 0 : 1 / Double(APP0.Ydensity)
        switch APP0.units {
        case 0: return Resolution(horizontal: _x, vertical: _y, unit: .point)
        case 1: return Resolution(horizontal: _x, vertical: _y, unit: .inch)
        case 2: return Resolution(horizontal: _x, vertical: _y, unit: .centimeter)
        default: return Resolution(resolution: 1, unit: .point)
        }
    }
    
    var colorSpace: AnyColorSpace {
        return AnyColorSpace(ColorSpace.sRGB)
    }
    
    var mediaType: ImageRep.MediaType {
        return .jpeg
    }
    
    func image(option: MappedBufferOption) -> AnyImage {
        
        return AnyImage(Image<ARGB32ColorPixel>(width: 0, height: 0, colorSpace: ColorSpace.sRGB, option: option))
    }
}

struct JPEGHuffmanTable : ByteCodable {
    
    var info: UInt8
    
    var table: [Key: UInt8] = [:]
    
    init(from data: inout Data) throws {
        
        self.info = try data.decode(UInt8.self)
        
        var _b: [Int] = []
        
        for _ in 0..<16 {
            _b.append(Int(try data.decode(UInt8.self)))
        }
        
        guard _b.reduce(0, +) <= 256 else { throw ImageRep.Error.InvalidFormat("Invalid Huffman table.") }
        
        var code: UInt16 = 0
        
        for (i, _count) in _b.enumerated() {
            for _ in 0..<_count {
                table[Key(length: UInt8(i + 1), code: code)] = try data.decode(UInt8.self)
                code += 1
            }
            code <<= 1
        }
    }
    
    func write(to stream: ByteOutputStream) {
        
        stream.encode(info)
        
        let group = Dictionary(grouping: table) { $0.key.length }
        
        let b1 = group[1]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b2 = group[2]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b3 = group[3]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b4 = group[4]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b5 = group[5]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b6 = group[6]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b7 = group[7]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b8 = group[8]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b9 = group[9]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b10 = group[10]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b11 = group[11]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b12 = group[12]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b13 = group[13]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b14 = group[14]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b15 = group[15]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        let b16 = group[16]?.sorted(by: { $0.key.code }).map { $0.value } ?? []
        
        stream.encode(UInt8(b1.count))
        stream.encode(UInt8(b2.count))
        stream.encode(UInt8(b3.count))
        stream.encode(UInt8(b4.count))
        stream.encode(UInt8(b5.count))
        stream.encode(UInt8(b6.count))
        stream.encode(UInt8(b7.count))
        stream.encode(UInt8(b8.count))
        stream.encode(UInt8(b9.count))
        stream.encode(UInt8(b10.count))
        stream.encode(UInt8(b11.count))
        stream.encode(UInt8(b12.count))
        stream.encode(UInt8(b13.count))
        stream.encode(UInt8(b14.count))
        stream.encode(UInt8(b15.count))
        stream.encode(UInt8(b16.count))
        
        stream.write(b1)
        stream.write(b2)
        stream.write(b3)
        stream.write(b4)
        stream.write(b5)
        stream.write(b6)
        stream.write(b7)
        stream.write(b8)
        stream.write(b9)
        stream.write(b10)
        stream.write(b11)
        stream.write(b12)
        stream.write(b13)
        stream.write(b14)
        stream.write(b15)
        stream.write(b16)
        
    }
}

extension JPEGHuffmanTable {
    
    struct Key : Hashable {
        
        var length: UInt8
        var code: UInt16
    }
}

extension JPEGHuffmanTable.Key : CustomStringConvertible {
    
    var description: String {
        let str = String(code, radix: 2)
        return repeatElement("0", count: Int(length) - str.count).joined() + str
    }
}

extension JPEGHuffmanTable : CustomStringConvertible {
    
    var description: String {
        return "JPEGHuffmanTable(info: \(info), table: [\(table.map { "\($0): \(String($1, radix: 16))" }.joined(separator: ", "))])"
    }
}

struct JPEGAPP0 {
    
    var version: (UInt8, UInt8)
    var units: UInt8
    var Xdensity: BEUInt16
    var Ydensity: BEUInt16
    var Xthumbnail: UInt8
    var Ythumbnail: UInt8
    
    init(_ segment: JPEGSegment) throws {
        
        var data = segment.data
        
        let i0 = try data.decode(UInt8.self)
        let i1 = try data.decode(UInt8.self)
        let i2 = try data.decode(UInt8.self)
        let i3 = try data.decode(UInt8.self)
        let i4 = try data.decode(UInt8.self)
        
        guard (i0, i1, i2, i3, i4) == (0x4A, 0x46, 0x49, 0x46, 0x00) else { throw ImageRep.Error.InvalidFormat("Invalid header.") }
        
        self.version = (try data.decode(UInt8.self), try data.decode(UInt8.self))
        self.units = try data.decode(UInt8.self)
        self.Xdensity = try data.decode(BEUInt16.self)
        self.Ydensity = try data.decode(BEUInt16.self)
        self.Xthumbnail = try data.decode(UInt8.self)
        self.Ythumbnail = try data.decode(UInt8.self)
    }
    
}

struct JPEGFrame {
    
    var SOF: JPEGSOF
    var tables: [JPEGSegment.Marker: JPEGSegment]
    var scan: [JPEGScan]
}

struct JPEGScan {
    
    var SOS: JPEGSOS
    var tables: [JPEGSegment.Marker: JPEGSegment]
    var ECS: [Data]
}

struct JPEGSOF {
    
    var precision: UInt8
    var lines: BEUInt16
    var samplesPerLine: BEUInt16
    var components: UInt8
    var sampling: [(UInt8, UInt8, UInt8)] = []
    
    init(_ segment: JPEGSegment) throws {
        
        var data = segment.data
        
        self.precision = try data.decode(UInt8.self)
        self.lines = try data.decode(BEUInt16.self)
        self.samplesPerLine = try data.decode(BEUInt16.self)
        self.components = try data.decode(UInt8.self)
        
        guard components == 1 || components == 3 else { throw ImageRep.Error.InvalidFormat("Invalid components count.") }
        
        for _ in 0..<components {
            self.sampling.append((try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self)))
        }
    }
}

struct JPEGSOS {
    
    var components: UInt8
    var selector: [(UInt8, UInt8)]
    var spectralSelection: (UInt8, UInt8)
    var successiveApproximation: UInt8
    
    init(_ segment: JPEGSegment) throws {
        
        var data = segment.data
        
        self.components = try data.decode(UInt8.self)
        
        self.selector = []
        for _ in 0..<self.components {
            self.selector.append((try data.decode(UInt8.self), try data.decode(UInt8.self)))
        }
        
        self.spectralSelection = (try data.decode(UInt8.self), try data.decode(UInt8.self))
        self.successiveApproximation = try data.decode(UInt8.self)
    }
}

struct JPEGSegment : ByteCodable {
    
    var marker: Marker
    var data: Data
    
    init(from data: inout Data) throws {
        var byte = try data.decode(UInt8.self)
        guard byte == 0xFF else { throw ImageRep.Error.InvalidFormat("Invalid marker.") }
        while byte == 0xFF {
            byte = try data.decode(UInt8.self)
        }
        self.marker = Marker(rawValue: byte)
        switch marker {
        case 0xD0...0xD9: self.data = Data()
        default: self.data = data.popFirst(Int(try data.decode(BEUInt16.self)) - 2)
        }
    }
    
    func write(to stream: ByteOutputStream) {
        stream.encode(0xFF as UInt8)
        stream.encode(marker)
        switch marker.rawValue {
        case 0xD0...0xD9: break
        default:
            stream.encode(BEUInt16(data.count + 2))
            stream.write(data)
        }
    }
}

extension JPEGSegment {
    
    struct Marker: RawRepresentable, Hashable, Comparable, ExpressibleByIntegerLiteral {
        
        var rawValue: UInt8
        
        init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        init(integerLiteral value: UInt8) {
            self.init(rawValue: value)
        }
        
        static func < (lhs: Marker, rhs: Marker) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        static var SOF0: Marker { return 0xC0 }
        static var SOF1: Marker { return 0xC1 }
        static var SOF2: Marker { return 0xC2 }
        static var SOF3: Marker { return 0xC3 }
        static var SOF5: Marker { return 0xC5 }
        static var SOF6: Marker { return 0xC6 }
        static var SOF7: Marker { return 0xC7 }
        static var SOF9: Marker { return 0xC9 }
        static var SOF10: Marker { return 0xCA }
        static var SOF11: Marker { return 0xCB }
        static var SOF13: Marker { return 0xCD }
        static var SOF14: Marker { return 0xCE }
        static var SOF15: Marker { return 0xCF }
        static var DHT: Marker { return 0xC4 }
        static var DAC: Marker { return 0xCC }
        static var RST0: Marker { return 0xD0 }
        static var RST1: Marker { return 0xD1 }
        static var RST2: Marker { return 0xD2 }
        static var RST3: Marker { return 0xD3 }
        static var RST4: Marker { return 0xD4 }
        static var RST5: Marker { return 0xD5 }
        static var RST6: Marker { return 0xD6 }
        static var RST7: Marker { return 0xD7 }
        static var SOI: Marker { return 0xD8 }
        static var EOI: Marker { return 0xD9 }
        static var SOS: Marker { return 0xDA }
        static var DQT: Marker { return 0xDB }
        static var DNL: Marker { return 0xDC }
        static var DRI: Marker { return 0xDD }
        static var DHP: Marker { return 0xDE }
        static var EXP: Marker { return 0xDF }
        static var APP0: Marker { return 0xE0 }
        static var APP1: Marker { return 0xE1 }
        static var APP2: Marker { return 0xE2 }
        static var APP3: Marker { return 0xE3 }
        static var APP4: Marker { return 0xE4 }
        static var APP5: Marker { return 0xE5 }
        static var APP6: Marker { return 0xE6 }
        static var APP7: Marker { return 0xE7 }
        static var APP8: Marker { return 0xE8 }
        static var APP9: Marker { return 0xE9 }
        static var APP10: Marker { return 0xEA }
        static var APP11: Marker { return 0xEB }
        static var APP12: Marker { return 0xEC }
        static var APP13: Marker { return 0xED }
        static var APP14: Marker { return 0xEE }
        static var APP15: Marker { return 0xEF }
        static var JPG0: Marker { return 0xF0 }
        static var JPG1: Marker { return 0xF1 }
        static var JPG2: Marker { return 0xF2 }
        static var JPG3: Marker { return 0xF3 }
        static var JPG4: Marker { return 0xF4 }
        static var JPG5: Marker { return 0xF5 }
        static var JPG6: Marker { return 0xF6 }
        static var JPG7: Marker { return 0xF7 }
        static var JPG8: Marker { return 0xF8 }
        static var JPG9: Marker { return 0xF9 }
        static var JPG10: Marker { return 0xFA }
        static var JPG11: Marker { return 0xFB }
        static var JPG12: Marker { return 0xFC }
        static var JPG13: Marker { return 0xFD }
        static var COM: Marker { return 0xFE }
    }
}

extension JPEGSegment.Marker: ByteCodable {
    
    init(from data: inout Data) throws {
        self.init(rawValue: try data.decode(UInt8.self))
    }
    
    func write(to stream: ByteOutputStream) {
        stream.encode(rawValue)
    }
}

extension JPEGSegment : CustomStringConvertible {
    
    var description: String {
        return "JPEGSegment(marker: \(String(marker.rawValue, radix: 16)), data: \(data))"
    }
}
