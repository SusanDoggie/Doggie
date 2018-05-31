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
        
        guard (try? data.decode(JPEGSegment.self).marker) == 0xD8 else { return nil }
        
        guard let _APP0 = try? data.decode(JPEGSegment.self) else { return nil }
        guard _APP0.marker == 0xE0, let APP0 = try? JPEGAPP0(_APP0) else { return nil }
        
        self.APP0 = APP0
        
        var segment = try data.decode(JPEGSegment.self)
        
        var quantization = [JPEGQuantizationTable]()
        var huffman = [JPEGHuffmanTable]()
        
        while segment.marker != 0xDA {
            
            switch segment.marker {
            case 0xC0, 0xC2: // Start Of Frame
                
                self.frame.append(JPEGFrame(SOF: try JPEGSOF(segment), quantization: quantization, scan: []))
                
                quantization = []
                
            case 0xDA: // Start Of Scan
                
                guard self.frame.count != 0 else { return nil }
                
                self.frame[self.frame.count - 1].scan.append(JPEGScan(SOS: try JPEGSOS(segment), huffman: huffman))
                
                huffman = []
                
            case 0xC4: // Huffman Table
                
                var table = segment.data
                huffman.append(try table.decode(JPEGHuffmanTable.self))
                
            case 0xDB: // Quantization Table
                
                var table = segment.data
                quantization.append(try table.decode(JPEGQuantizationTable.self))
                
            default: break
            }
            
            segment = try data.decode(JPEGSegment.self)
        }
        
        guard frame.count != 0 else { return nil }
        
    }
    
    var width: Int {
        return Int(self.frame[0].SOF.samplesPerLine)
    }
    
    var height: Int {
        return Int(self.frame[0].SOF.lines)
    }
    
    var resolution: Resolution {
        let _x = APP0.Xdensity.representingValue == 0 ? 0 : 1 / Double(APP0.Xdensity.representingValue)
        let _y = APP0.Ydensity.representingValue == 0 ? 0 : 1 / Double(APP0.Ydensity.representingValue)
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
    
    func encode(to stream: inout ByteOutputStream) {
        
        stream.write(info)
        
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
        
        stream.write(UInt8(b1.count))
        stream.write(UInt8(b2.count))
        stream.write(UInt8(b3.count))
        stream.write(UInt8(b4.count))
        stream.write(UInt8(b5.count))
        stream.write(UInt8(b6.count))
        stream.write(UInt8(b7.count))
        stream.write(UInt8(b8.count))
        stream.write(UInt8(b9.count))
        stream.write(UInt8(b10.count))
        stream.write(UInt8(b11.count))
        stream.write(UInt8(b12.count))
        stream.write(UInt8(b13.count))
        stream.write(UInt8(b14.count))
        stream.write(UInt8(b15.count))
        stream.write(UInt8(b16.count))
        
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

struct JPEGQuantizationTable : ByteCodable {
    
    var destination: UInt8
    
    var table: (
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )
    
    init(from data: inout Data) throws {
        
        self.destination = try data.decode(UInt8.self)
        
        self.table = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                      try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
    }
    
    func encode(to stream: inout ByteOutputStream) {
        
        stream.write(destination)
        stream.write(table.0, table.1, table.2, table.3, table.4, table.5, table.6, table.7)
        stream.write(table.8, table.9, table.10, table.11, table.12, table.13, table.14, table.15)
        stream.write(table.16, table.17, table.18, table.19, table.20, table.21, table.22, table.23)
        stream.write(table.24, table.25, table.26, table.27, table.28, table.29, table.30, table.31)
        stream.write(table.32, table.33, table.34, table.35, table.36, table.37, table.38, table.39)
        stream.write(table.40, table.41, table.42, table.43, table.44, table.45, table.46, table.47)
        stream.write(table.48, table.49, table.50, table.51, table.52, table.53, table.54, table.55)
        stream.write(table.56, table.57, table.58, table.59, table.60, table.61, table.62, table.63)
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
    var quantization: [JPEGQuantizationTable]
    var scan: [JPEGScan]
}

struct JPEGScan {
    
    var SOS: JPEGSOS
    var huffman: [JPEGHuffmanTable]
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
    
    var marker: UInt8
    var data: Data
    
    init(from data: inout Data) throws {
        var byte = try data.decode(UInt8.self)
        guard byte == 0xFF else { throw ImageRep.Error.InvalidFormat("Invalid marker.") }
        while byte == 0xFF {
            byte = try data.decode(UInt8.self)
        }
        self.marker = byte
        switch marker {
        case 0xD0...0xD9: self.data = Data()
        default: self.data = data.popFirst(Int(try data.decode(BEUInt16.self)) - 2)
        }
    }
    
    func encode(to stream: inout ByteOutputStream) {
        stream.write(0xFF as UInt8)
        stream.write(marker)
        switch marker {
        case 0xD0...0xD9: break
        default:
            stream.write(BEUInt16(data.count + 2))
            stream.write(data)
        }
    }
}

extension JPEGSegment : CustomStringConvertible {
    
    var description: String {
        return "JPEGSegment(marker: \(String(marker, radix: 16)), data: \(data))"
    }
}
